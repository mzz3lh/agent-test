/*====================================================================
    Layercake.usp_load_silv_daily_count
    Silver layer - loads one table
====================================================================*/

/*====================================================================
    13. Layercake.silv_daily_count_detail + Layercake.silv_daily_count
        (FORWARD ONLY - two tables, one module: see the file header)
    ------------------------------------------------------------------
    WHAT THIS MODULE LOADS: every spine date from 2020-10-01 to today
    that is NOT already recorded in Layercake.etl_daily_count_loaded.
    Nothing else. Historical dates already marked loaded are never
    rebuilt by a daily run.

    That single rule delivers all three required behaviours:
      * new days are loaded (never marked before);
      * a run that failed part-way is RESUMED - the chunks that
        committed are marked, the chunk that died is not, so it is
        still in the work list next run and is re-done in full;
      * history is left alone.

    THE CURRENT DAY IS NEVER MARKED. Today's counts depend on
    open-ended ranges ("count through today") and on source data that is
    still landing, so today is rebuilt on every run and only becomes
    final on the first run after midnight.

    GRANULARITY: the work list is walked in @DailyCountBatchDays-day
    chunks (default 31). Each chunk is ONE transaction: delete +
    re-insert the DETAIL rows for those dates (the expensive join),
    delete + re-derive the MAIN rows from that same detail, then mark
    the chunk's past dates loaded. Data and marker commit together, so
    the marker can never lie in either direction.

    RETROSPECTIVE CHANGES ARE LOGGED BY THE PRODUCING MODULES, NOT
    APPLIED HERE. Use @RebuildFrom (or @FullRebuild) to apply them.

    COUNT DERIVATION: ONE expensive join builds the DETAIL table at
    [date] x region x country x gender x grade x status, and the main
    silv_daily_count is a plain SUM over it. A contact occupies exactly
    one detail cell per day, so the counts are additive and the two
    tables reconcile by construction.

    COUNT RULE: a member counts in the LATEST state they held on any
    given day. The half-open interval join [valid_from, valid_to)
    implements this: a same-day transition leaves a zero-length range
    (matches no date), so the day lands on the last state opened that
    day - state_seq guarantees that is the last event in the
    enrolment -> election -> lapse order.

    STATUS RULE: 'election' rows split by day-level status - Retired
    from the retirement date onward, else Practising (a null retirement
    date -> Practising). 'enrolment' and 'lapse' rows carry status N/A.

    v2-parity: open-ended ranges count through today; lapsed members
    never count as Active.

    ------------------------------------------------------------------
    TWO PAID MEASURES, SIDE BY SIDE
    ------------------------------------------------------------------
    Both are counts of DISTINCT contacts, both are gated by the same
    state-range join as the active count (so every driver exclusion on
    the active side removes the contact from both paid numbers too), and
    both are attributed to the cell the contact occupies on the day.
    They are NOT expected to agree - carrying both is the point.

    paid_count (PAYMENT-driven, the original, unchanged)
      A payment event for the day's campaign year whose adjusted renewal
      date is on or before the day. Reads silv_payment_events, i.e. the
      subs invoice position.

    paid_count_event (EVENT-driven, added alongside)
      Reads silv_membership_events instead: joins + renewals +
      readmissions. A contact is PAID IN from the earliest Join /
      Renewal / Readmission event in the campaign year (step c picks
      exactly one - they are already mutually exclusive per contact per
      year, since module 9 excludes the Join year and the Readmission
      years from Renewal; the tie-break only makes that deterministic),
      and stays counted for the rest of that year. Keyed on campaign
      year, so the measure resets to zero on each 1 October and builds
      through the year: on any day it is how many members have paid so
      far this campaign year.

      LAPSING DOES NOT DEDUCT. A member who paid and then lapsed still
      paid, and this measure is a count of that. Lapses are still
      derived and still reported - event_lapse_count below - they just
      do not come back off the number. That makes paid_count_event
      monotonic within a campaign year, and it is the one place it parts
      company with every other count in this module (the active count,
      and paid_count through its state-range gate, both stop at a
      lapse).

      Join here is the Join EVENT (enrolment-dated for Candidates,
      election-dated for RPQ direct entries), not a payment - which is
      the substantive difference from paid_count and the reason the two
      diverge in a member's first year.

    event_join_count / event_renewal_count / event_readmission_count are
    the daily FLOWS behind paid_count_event: the contacts whose paid-in
    fell on that day. They reconcile with the stock by construction - a
    running total of (join + renewal + readmission) from the campaign
    year start reproduces paid_count_event exactly, at the day level.
    That holds on the TOTAL, not cell by cell: the stock is attributed
    to the cell the contact sits in on the day being counted, the flow
    to the cell they sat in on the event day, and a member who moves
    country or is elected moves cell in between.

    event_lapse_count sits alongside them as a FOURTH flow, reported but
    NOT part of that identity - it is the contacts who had paid in this
    campaign year and then lapsed on that day. Two things it is not: it
    is not deducted from paid_count_event (see above), and it is not
    every lapse - a member bulk-lapsed on 1 June for never paying at all
    has no paid-in behind them and does not appear. fact_membership_
    events carries every Lapse event if the unfiltered number is wanted.

    Parameters:
      @FullRebuild         - 1 clears the loaded markers for the WHOLE
                             spine (from 2020-10-01).
      @RebuildFrom         - clear the loaded markers from this date
                             forward and re-do those dates. The
                             deliberate way to apply a retrospective
                             correction flagged in
                             etl_daily_count_pending_rebuild. Ignored
                             when @FullRebuild = 1.
      @DailyCountBatchDays - chunk size, and the resume granularity
                             (default 31; minimum 1).
====================================================================*/
create or alter procedure Layercake.usp_load_silv_daily_count
    @run_id              uniqueidentifier = null,
    @FullRebuild         bit  = 0,
    @RebuildFrom         date = null,
    @DailyCountBatchDays int  = 31
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();
    -- null-safe: the chunked walk is driven by a work list, so a null/zero
    -- batch size would select no dates and never make progress
    if isnull(@DailyCountBatchDays, 0) < 1 set @DailyCountBatchDays = 31;

    declare @log_id       bigint,
            @ins          int,
            @upd          int,
            @del          int,
            @rc           int,
            @note         nvarchar(256),
            @substep_ts   datetime2(3),
            @err          nvarchar(4000),
            @today        date = cast(getdate() as date),
            @rebuild_from date = null,
            @win_from     date,
            @win_to       date,
            @marked       int,
            @todo_days    int,
            @todo_min     date,
            @todo_max     date;

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'silver', 'silv_daily_count', @log_id output;
        set @substep_ts = sysdatetime();

        select @ins = 0, @del = 0;

        /* ---- a. deliberate rebuild request ----------------------------
           @FullRebuild / @RebuildFrom clear the loaded markers, which is
           all it takes to put those dates back in the work list below.
           ------------------------------------------------------------- */
        if @FullRebuild = 1
            set @rebuild_from = '20201001';
        else if @RebuildFrom is not null
            set @rebuild_from = @RebuildFrom;

        if @rebuild_from < '20201001'
            set @rebuild_from = '20201001';

        if @rebuild_from is not null
        begin
            begin tran;

            delete from Layercake.etl_daily_count_loaded where [date] >= @rebuild_from;
            set @rc = @@rowcount;

            commit;

            -- NOTE: the pending-rebuild rows this covers are stamped applied
            -- only AFTER the walk completes (step e) - stamping them here
            -- would claim the history was re-derived while the walk could
            -- still die half way through it.

            set @note = concat(N'rebuild requested from ', convert(nvarchar(10), @rebuild_from, 23),
                               N' - ', @rc, N' loaded marker(s) cleared');
            exec Layercake.usp_etl_log_progress @log_id, @note, @rc, @substep_ts output;
        end

        /* ---- b. the work list ----------------------------------------- */
        select s.[date]
        into #dc_todo
        from Layercake.ref_date_spine s
        where s.[date] >= '20201001'
          and s.[date] <= @today
          and not exists (select 1 from Layercake.etl_daily_count_loaded l
                          where l.[date] = s.[date]);
        set @todo_days = @@rowcount;

        create unique clustered index cx_dc_todo on #dc_todo ([date]);
        select @todo_min = min([date]), @todo_max = max([date]) from #dc_todo;

        set @note = case when @todo_days = 0
                         then N'nothing to load - every date up to today is already marked loaded'
                         else concat(N'to load: ', @todo_days, N' date(s) ',
                                     convert(nvarchar(10), @todo_min, 23), N' -> ',
                                     convert(nvarchar(10), @todo_max, 23),
                                     N' in ', @DailyCountBatchDays, N'-day chunks',
                                     -- a gap means an earlier run left dates behind
                                     iif(@todo_days < 1 + datediff(day, @todo_min, @todo_max),
                                         N' (includes a gap from an earlier incomplete run)', N''))
                    end;
        exec Layercake.usp_etl_log_progress @log_id, @note, @todo_days, @substep_ts output;

        -- housekeeping: the spine runs two years ahead, so make sure nothing
        -- beyond today survives from an earlier run (and no marker with it)
        begin tran;
        delete from Layercake.silv_daily_count_detail where [date] > @today;
        set @del = @del + @@rowcount;
        delete from Layercake.silv_daily_count        where [date] > @today;
        set @del = @del + @@rowcount;
        delete from Layercake.etl_daily_count_loaded  where [date] > @today;
        commit;

        /* ---- c. event-driven paid: per-contact staging -----------------
           Built ONCE for the whole run and read by every chunk. Two work
           tables: #ev_paid is the STOCK (one row per contact per campaign
           year: the date they became paid, plus the date they later
           lapsed if they did), and #ev_day is those same two dates
           re-shaped as the daily FLOW. See the module header for the rule
           they implement - note in particular that the lapse date is
           carried for REPORTING only and never deducts from the stock.
           ------------------------------------------------------------- */

        -- c1. the paid-in event: the earliest Join / Renewal / Readmission
        -- in the campaign year. Ties on the same date break
        -- Join -> Readmission -> Renewal so the winner is deterministic
        -- across runs; in practice module 9 already makes the three
        -- mutually exclusive per contact per year.
        select v.contact_no,
               v.campaign_year,
               v.event_type,
               -- clamped to the campaign year start: a Renewal event falls
               -- back to the cash transaction date when renewal_date_adj is
               -- null, and that date can sit outside the year the subs
               -- position assigns it to. Clamping lands the FLOW on 1 October
               -- rather than in the previous campaign year; it cannot change
               -- the stock, which already counts such a contact from day one.
               iif(v.event_date < cfg.campaign_year_start, cfg.campaign_year_start, v.event_date) as paid_in_date
        into #ev_paid_in
        from (
            select e.contact_no,
                   e.campaign_year,
                   e.event_type,
                   e.event_date,
                   row_number() over (partition by e.contact_no, e.campaign_year
                                      order by e.event_date,
                                               case e.event_type
                                                   when 'Join'        then 1
                                                   when 'Readmission' then 2
                                                   else 3                       -- Renewal
                                               end,
                                               e.event_id) as rn
            from Layercake.silv_membership_events e
            where e.event_type in ('Join', 'Renewal', 'Readmission')
        ) v
        -- left joined: campaign years before the spine (CY2021) have no config
        -- row, and both tests below are written to pass when it is missing
        left join Layercake.ref_campaign_year_config cfg
            on  cfg.campaign_year = v.campaign_year
        where v.rn = 1
          -- an event dated after the campaign year ended cannot be that year's
          -- paid-in. Dropped from stock AND flow together, so the two still
          -- reconcile.
          and (cfg.campaign_year_end is null or v.event_date <= cfg.campaign_year_end);
        set @rc = @@rowcount;

        create unique clustered index cx_ev_paid_in on #ev_paid_in (contact_no, campaign_year);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #ev_paid_in (event-driven paid: paid-in events)', @rc, @substep_ts output;

        -- c2. the lapse that follows it. Feeds event_lapse_count only - it does
        -- not end the paid count. Module 9 keys Lapse events 'LA:' + contact_no,
        -- so there is at most one per contact - aggregated anyway so the join
        -- below stays 1:1 whatever the source does.
        select e.contact_no,
               e.campaign_year,
               min(e.event_date) as lapse_date
        into #ev_lapse
        from Layercake.silv_membership_events e
        where e.event_type = 'Lapse'
        group by e.contact_no, e.campaign_year;
        set @rc = @@rowcount;

        create unique clustered index cx_ev_lapse on #ev_lapse (contact_no, campaign_year);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #ev_lapse (event-driven paid: lapse events)', @rc, @substep_ts output;

        -- c3. the STOCK table the day-by-day count reads.
        select i.contact_no,
               i.campaign_year,
               i.event_type,
               i.paid_in_date,
               -- REPORTED, NOT DEDUCTED (see the module header): a lapse in the
               -- same campaign year dated on or after the paid-in event. The
               -- ordering test is what makes this "paid, then lapsed" rather
               -- than any lapse at all - a member bulk-lapsed for never paying
               -- has no paid-in behind them and nulls out here. A CASE, not a
               -- join predicate: the contact row has to survive either way.
               case when l.lapse_date >= i.paid_in_date then l.lapse_date end as lapse_date
        into #ev_paid
        from #ev_paid_in i
        left join #ev_lapse l
            on  l.contact_no    = i.contact_no
            and l.campaign_year = i.campaign_year;

        create unique clustered index cx_ev_paid on #ev_paid (contact_no, campaign_year);

        -- c4. the FLOW table: those same two dates as one row per contact per
        -- day. Derived from #ev_paid rather than re-read from the events, so
        -- the components can only ever describe the stock above. A contact who
        -- paid in and lapsed on the same day collapses into a single row
        -- carrying both flags - paid-in and lapse are reported independently,
        -- so neither cancels the other.
        select f.contact_no,
               f.event_date,
               max(f.join_flag)        as join_flag,
               max(f.renewal_flag)     as renewal_flag,
               max(f.readmission_flag) as readmission_flag,
               max(f.lapse_flag)       as lapse_flag
        into #ev_day
        from (
            select p.contact_no,
                   p.paid_in_date as event_date,
                   iif(p.event_type = 'Join', 1, 0)        as join_flag,
                   iif(p.event_type = 'Renewal', 1, 0)     as renewal_flag,
                   iif(p.event_type = 'Readmission', 1, 0) as readmission_flag,
                   0                                       as lapse_flag
            from #ev_paid p
            union all
            select p.contact_no, p.lapse_date, 0, 0, 0, 1
            from #ev_paid p
            where p.lapse_date is not null
        ) f
        group by f.contact_no, f.event_date;
        set @rc = @@rowcount;

        create unique clustered index cx_ev_day on #ev_day (contact_no, event_date);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #ev_paid + #ev_day (event-driven paid: stock and daily flow)', @rc, @substep_ts output;

        /* ---- d. the chunked walk -------------------------------------- */
        create table #dc_chunk ([date] date not null primary key clustered);

        while exists (select 1 from #dc_todo)
        begin
            delete from #dc_chunk;

            insert into #dc_chunk ([date])
            select top (@DailyCountBatchDays) [date]
            from #dc_todo
            order by [date];

            -- forward-progress guard: a chunk that picked up nothing would
            -- delete nothing from #dc_todo and spin forever
            if @@rowcount = 0 break;

            select @win_from = min([date]), @win_to = max([date]) from #dc_chunk;

            begin tran;

            -- ---- detail chunk: delete + re-insert -----------------------
            -- restricted to the chunk's OWN dates (not the from/to range), so
            -- a loaded date sitting inside a gap is never touched
            delete d
            from Layercake.silv_daily_count_detail d
            where d.[date] between @win_from and @win_to
              and exists (select 1 from #dc_chunk c where c.[date] = d.[date]);
            set @del = @del + @@rowcount;

            -- the chunk's dates drive one row per day per populated cell,
            -- joining the state ranges active on that day (set-based - no
            -- cursor). Profile left-joined: every ranged contact has a
            -- profile row (both derive from silv_member_base), the isnulls
            -- are belt and braces for a mid-deploy state.
            insert into Layercake.silv_daily_count_detail
            ([date], campaign_year, campaign_quarter, region, country_id, gender_id, grade, membership_status_id,
             active_count, paid_count, paid_count_event,
             event_join_count, event_renewal_count, event_readmission_count, event_lapse_count)
            select
                s.[date],
                s.campaign_year,
                s.campaign_quarter,
                r.region,
                isnull(pr.country_id, 0)  as country_id,
                isnull(pr.gender_id, 0)   as gender_id,
                r.grade,
                isnull(ms.id, 0)          as membership_status_id,
                -- v2 parity: lapsed members NEVER count as active - the lapse
                -- rows remain (carrying paid counts) but contribute 0 to
                -- the active count from the lapse date onward
                count(distinct case when r.grade = 'lapse'
                                    then null else r.contact_no end) as active_count,
                -- PAYMENT-driven paid: a payment event exists for the campaign
                -- year with an adjusted renewal date on or before this date (the
                -- adjusted date is always inside the campaign year, which is
                -- what makes day-by-day processing valid)
                count(distinct case when p.renewal_date_adj <= s.[date]
                                    then p.contact_no else null end) as paid_count,
                -- EVENT-driven paid (STOCK): paid from the campaign year's
                -- paid-in event, and counted for the rest of that year. A later
                -- lapse does NOT take it back off - the lapse date staged in
                -- step c reaches event_lapse_count below and nothing else. See
                -- the module header.
                count(distinct case when ep.paid_in_date <= s.[date]
                                    then r.contact_no else null end) as paid_count_event,
                -- ...and the daily FLOWS it is built from. Counted as distinct
                -- CONTACTS, like the stock they reconcile to, so a duplicate
                -- state range could never inflate them.
                count(distinct case when ed.join_flag        = 1 then r.contact_no else null end) as event_join_count,
                count(distinct case when ed.renewal_flag     = 1 then r.contact_no else null end) as event_renewal_count,
                count(distinct case when ed.readmission_flag = 1 then r.contact_no else null end) as event_readmission_count,
                -- reported, but deliberately NOT part of the stock above
                count(distinct case when ed.lapse_flag       = 1 then r.contact_no else null end) as event_lapse_count
            from #dc_chunk c
            inner join Layercake.ref_date_spine s
                on  s.[date] = c.[date]
            inner join Layercake.silv_member_state_ranges r
                -- LATEST-STATE-PER-DAY rule: half-open interval
                -- [valid_from, valid_to). Open-ended ranges (valid_to null,
                -- i.e. currently-active members) count through today.
                -- Zero-length ranges (same-day transitions, ordered by
                -- state_seq) match no date at all.
                on  s.[date] >= r.valid_from
                and s.[date] <  isnull(r.valid_to, dateadd(day, 1, @today))
            left join Layercake.silv_member_profile pr
                on  pr.contact_no = r.contact_no
            -- day-level status: Qualified members are Retired from the
            -- retirement date onward, else Practising (null retirement ->
            -- Practising via the IIF); Candidate/Lapsed rows are N/A (id 0)
            left join Layercake.silv_ref_membership_status ms
                on  ms.status_name = case when r.grade = 'election'
                                          then iif(pr.retirement_date <= s.[date], 'Retired', 'Practising')
                                          else 'N/A' end
            left join Layercake.silv_payment_events p
                on  r.contact_no = p.contact_no
                and s.campaign_year = p.campaign_year
            -- event-driven paid, both halves keyed 1:1 against the range row
            -- (step c indexes them uniquely), so neither can fan the join out
            left join #ev_paid ep
                on  ep.contact_no    = r.contact_no
                and ep.campaign_year = s.campaign_year
            left join #ev_day ed
                on  ed.contact_no = r.contact_no
                and ed.event_date = s.[date]
            group by
                s.[date], s.campaign_year, s.campaign_quarter,
                r.region, isnull(pr.country_id, 0), isnull(pr.gender_id, 0),
                r.grade, isnull(ms.id, 0);
            set @rc = @@rowcount;
            set @ins = @ins + @rc;

            -- ---- main chunk: plain aggregate of the chunk's detail -------
            -- (additive: one detail cell per contact per day - see header)
            delete t
            from Layercake.silv_daily_count t
            where t.[date] between @win_from and @win_to
              and exists (select 1 from #dc_chunk c where c.[date] = t.[date]);
            set @del = @del + @@rowcount;

            insert into Layercake.silv_daily_count
            ([date], campaign_year, campaign_quarter, region, grade,
             active_count, paid_count, paid_count_event,
             event_join_count, event_renewal_count, event_readmission_count, event_lapse_count)
            select
                d.[date], d.campaign_year, d.campaign_quarter, d.region, d.grade,
                sum(d.active_count), sum(d.paid_count), sum(d.paid_count_event),
                sum(d.event_join_count), sum(d.event_renewal_count),
                sum(d.event_readmission_count), sum(d.event_lapse_count)
            from Layercake.silv_daily_count_detail d
            inner join #dc_chunk c on c.[date] = d.[date]
            where d.[date] between @win_from and @win_to
            group by d.[date], d.campaign_year, d.campaign_quarter, d.region, d.grade;
            set @ins = @ins + @@rowcount;

            -- ---- mark the chunk loaded (ATOMIC with its data) -----------
            -- today is deliberately excluded: it is rebuilt every run and is
            -- only marked once it is in the past
            insert into Layercake.etl_daily_count_loaded ([date], run_id, batch_from, batch_to)
            select c.[date], @run_id, @win_from, @win_to
            from #dc_chunk c
            where c.[date] < @today;
            set @marked = @@rowcount;

            commit;    -- one transaction per chunk: small, quick, resumable

            set @note = concat(N'chunk ', convert(nvarchar(10), @win_from, 23),
                               N' -> ',   convert(nvarchar(10), @win_to,  23),
                               N' (', @rc, N' detail rows, ', @marked, N' date(s) marked loaded',
                               iif(@win_to = @today, N', today left unmarked - rebuilt next run', N''), N')');
            exec Layercake.usp_etl_log_progress @log_id, @note, @rc, @substep_ts output;

            -- done with these dates
            delete t
            from #dc_todo t
            where exists (select 1 from #dc_chunk c where c.[date] = t.[date]);
        end

        /* ---- e. close off any pending rebuild this walk satisfied ------
           Stamped only now: the whole requested range has been re-derived
           and committed. A run that died mid-walk leaves the pending row
           OPEN (and its markers cleared), so the next run finishes the walk
           and stamps it then - the audit trail never claims a rebuild that
           didn't finish.
           ------------------------------------------------------------- */
        if @rebuild_from is not null
        begin
            begin tran;

            update Layercake.etl_daily_count_pending_rebuild
            set applied_at = sysdatetime()
            where applied_at is null
              and affected_from >= @rebuild_from;
            set @upd = @@rowcount;

            commit;

            if @upd > 0
            begin
                set @note = concat(N'rebuild complete from ', convert(nvarchar(10), @rebuild_from, 23),
                                   N' - ', @upd, N' pending row(s) stamped applied');
                exec Layercake.usp_etl_log_progress @log_id, @note, @upd, @substep_ts output;
            end
        end

        exec Layercake.usp_etl_log_end @log_id, 'Success', @ins, 0, @del;
    end try
    begin catch
        if xact_state() <> 0 rollback;
        set @err = concat(error_message(), ' (error ', error_number(), ', line ', error_line(), ')');
        if @log_id is not null
            exec Layercake.usp_etl_log_end @log_id, 'Failed', @ins, 0, @del, @err;
        throw;
    end catch
end
go

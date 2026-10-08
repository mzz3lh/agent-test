/*====================================================================
    Layercake.usp_load_ref_enrolment_exception
    Silver layer - loads one table
====================================================================*/

/*====================================================================
    8a. Layercake.ref_enrolment_exception
    ------------------------------------------------------------------
    Gap-fill dates for contacts who have been PAYING members but have no
    qualifying Enrolled / Elected row on the enrolments table (believed
    to stem from an old system migration - a cohort with no enrolment
    row at all, and a larger one whose rows exist but fail the
    qualifying rules).

    THIS MODULE IS THE ONLY THING THAT WRITES TO THAT TABLE. It runs on
    every silver load, between silv_payment_events (module 7, which
    supplies the driver) and silv_member_base (module 8, which consumes
    the result). Before 20260928_02 the capture was a phase 03 seed
    guarded on the table being empty, and nothing in usp_run_daily_load
    ever touched it again.

    ------------------------------------------------------------------
    WHY IT MOVED INTO THE PIPELINE
    ------------------------------------------------------------------
    The frozen snapshot made a daily load and a from-scratch reload
    disagree, by a small and slowly growing amount, on the most recent
    day's active and paid member counts.

    A reload truncates the table and re-derives it against today's
    source, so it captured every contact who had started paying since
    the original snapshot. A daily load did not. And an uncaptured
    contact of this kind is not simply missing a date - it falls out of
    the counts entirely:

      * no qualifying row in Layercake.vw_enrolment_base, and no
        exception row, so module 8 gives the contact a null enrolment
        date AND a null election date;
      * both Join branches in module 9 require one of those dates, so no
        Join event is emitted;
      * no Join means no state range, and the active count and BOTH paid
        counts are gated by the state-range join - so the contact is in
        neither.

    Give the same contact an exception row and the Join fires, the range
    opens and they count. That was the whole of the variance. (A subset
    of the cohort already slipped in through the payment-derived
    Readmission in module 9 - the one event that opens a range with no
    member-base date behind it - which is why the difference was a
    handful of contacts rather than the whole cohort.)

    ------------------------------------------------------------------
    THE LIFECYCLE - AND WHAT IT DELIBERATELY DOES NOT DO
    ------------------------------------------------------------------
    CAPTURE IS INSERT-ONLY. A contact captured once keeps the dates they
    were captured with, for ever. No run re-derives an existing row, so
    a date a count has already been built on can never move underneath
    it. That is the snapshot guarantee the phase 03 guard was
    protecting, kept intact while the capture itself became continuous.

    A NEW CAPTURE IS STILL A RETROSPECTIVE CHANGE. The derived date is
    usually years old, so it reaches back into dates the daily-count
    walk has already marked loaded. Those are NOT rebuilt here - the
    module logs the earliest affected date to
    Layercake.etl_daily_count_pending_rebuild under source
    'enrol_exception' and carries on, exactly as the state-range and
    payment modules do. Today's count corrects itself on this run
    (module 13 never marks today); history moves only when an operator
    asks for it:

        select * from Layercake.etl_daily_count_pending_rebuild
        where applied_at is null;
        exec Layercake.usp_load_silver @RebuildFrom = '<that date>';

    SUPERSESSION IS A FLAG, NOT A DELETE. When a captured contact gains
    a qualifying vw_enrolment_base row - the upstream data anomaly
    having been corrected - the row is stamped superseded_at /
    superseded_reason and left in place. Three reasons:
      * it is already inert wherever the real data covers it. Module 8
        coalesces PER DATE with the real row winning, so a qualifying
        enrolment row supersedes derived_enrolment_date by itself.
      * it is still doing work wherever the real data does NOT cover it.
        A contact who gains a qualifying ELECTION row but still has no
        part-1 enrolment row keeps the derived enrolment date, and
        deleting the row would reopen the gap.
      * the row is the audit trail of what the counts were built on.
        Deleting it would leave no record of why a member was ever
        counted from a date the source does not hold.
    The stamp is CLEARED if the contact stops qualifying again, the same
    way usp_load_silv_data_anomaly re-opens a resolved row. Neither
    stamping nor clearing logs a pending rebuild: neither changes a
    derived date. The real rows arriving DO change module 8's output,
    and the state-range module logs that for itself.

    NOTHING IS EVER HARD-DELETED HERE. rows_deleted is always 0. To
    remove a row, do it by hand - it is still a curated table.

    ------------------------------------------------------------------
    THE DRIVER, AND WHERE EACH RULE LIVES
    ------------------------------------------------------------------
    Every rule this module applies is READ from the object that owns it.
    The retired phase 03 seed and the superseded top-up script both had
    to carry hand-copied duplicates of the route-id and
    application-type lists, because at phase 03 bronze is still empty
    and they read the source views directly. This module runs after
    bronze, so it has no copy of anything:

      WHO IS A PAYING MEMBER      Layercake.silv_payment_events
        The paid subs invoice positions, already the single definition
        of "paid" in the pipeline. Campaign years LATER than the current
        one are ignored - an advance payment for next year says nothing
        about today. Campaign year Y = 01 Oct (Y-1) .. 30 Sep (Y).
        active = paid that campaign year, OR paid the one before (they
        may simply not have paid yet). A contact is in the driver if it
        was active in ANY campaign year, so the capture serves
        historical counts and not just today's.

      WHO IS MISSING AN ENROLMENT Layercake.vw_enrolment_base
        A driver contact with NO ROW AT ALL in that view. Part 1 of the
        view is the valid-enrolment rules and part 2 the election rules,
        so "no row" is exactly the seed's "no qualifying enrolment AND
        no qualifying election". The same view decides supersession, so
        the capture test and the retirement test cannot drift apart.

      WHICH SIDE QUALIFIES        the view's own documented invariant:
        election_date is always NULL on a part-1 row and always NOT NULL
        on a part-2 row. That is what splits has_qual_enrolment from
        has_qual_election below, and it is only used to word
        superseded_reason.

    DERIVATION RULES - the dates on a new row. Carried over unchanged
    from the retired seed:
      1. Look at EVERY brnz_enrolment row for the contact, qualifying or
         not (rows rejected for status, route, end date or cool-off still
         carry real dates), and take the EARLIEST enrolment date and the
         EARLIEST election date found. Enrolment dates are clamped to
         1980-01-01 as vw_enrolment_base does.
         Student application rows are the one exclusion: both halves of
         the qualifying rule reject them and module 8's driver drops
         Student-grade contacts, so a Student row's date is not a
         professional enrolment.
      2. Elected or Enrolled?
           Elected  = an election date exists on any enrolment row, OR
                      the contact grade is anything other than Candidate.
           Enrolled = otherwise (Candidate grade, no election evidence).
      3. Elected contacts:
           derived_election_date  = earliest election date on an
                                    enrolment row, else Rics_ElectionDate
                                    on the contact, else the contact
                                    created date (flagged in
                                    election_date_source for review).
           derived_enrolment_date = earliest enrolment date on an
                                    enrolment row where one exists, else
                                    null - module 8's own aggregate
                                    carries the enrolment date riding on
                                    an election row.
         Enrolled contacts:
           derived_enrolment_date = earliest enrolment date on an
                                    enrolment row, else the contact
                                    created date (best available proxy).
      4. A row must fill at least one of the two dates or it does
         nothing, so rows deriving neither are dropped
         (ck_ref_enr_exc_has_date says the same thing).
      5. ONE contact row per contact NUMBER, the table being keyed on
         contact_no: live record first (StateCode = 0), then oldest
         CreatedOn, then ContactId. Test records are removed. A driver
         contact number with no brnz_contact row cannot be captured -
         contact_id is required, and module 8's driver needs the contact
         anyway. The count is logged.

    These members are then treated as active from the derived date
    across all campaign years - module 11's open-ended state range does
    that naturally, and the contact's lapse date closes it. Module 8 may
    still MOVE the derived date to the first paid campaign year under
    the subs-history rules, and reports it as
    ENROLMENT_AFTER_FIRST_PAID / ELECTION_AFTER_FIRST_PAID etc. The
    curated date on this row is the date it moved FROM, not the date the
    events use.

    ------------------------------------------------------------------
    WORTH REVIEWING AFTER A RUN THAT CAPTURED ANYTHING
    ------------------------------------------------------------------
        -- what this run captured, and why
        select _capture_source, enrolment_date_source, election_date_source,
               count(*) as contacts,
               sum(iif(source_enrolment_rows = 0, 1, 0)) as no_enrolment_rows_at_all,
               sum(iif(is_paid_current = 1, 1, 0))       as paid_current_cy,
               min(coalesce(derived_election_date, derived_enrolment_date)) as earliest_derived,
               max(coalesce(derived_election_date, derived_enrolment_date)) as latest_derived
        from Layercake.ref_enrolment_exception
        where cast(_captured_at as date) = cast(getdate() as date)
        group by _capture_source, enrolment_date_source, election_date_source;

        -- captured but not active in the current campaign year and with no
        -- lapse date on the contact: nothing closes their state range, so
        -- they count as active in every year since the derived date
        select x.*
        from Layercake.ref_enrolment_exception x
        join Layercake.brnz_contact c on c.ContactId = x.contact_id
        where x.is_active_current = 0
          and c.Rics_LapsedDate is null;

        -- created-date fallbacks on elected members, newest first. A 2026
        -- created date on a long-standing member says the CE record was
        -- recreated, not that they joined in 2026.
        select top (50) *
        from Layercake.ref_enrolment_exception
        where election_date_source = 'Contact CreatedOn (no election date)'
        order by derived_election_date desc;

        -- retired rows: the source caught up
        select superseded_reason, count(*) as contacts, max(superseded_at) as latest
        from Layercake.ref_enrolment_exception
        where superseded_at is not null
        group by superseded_reason;

    Depends on silv_payment_events (module 7), vw_enrolment_base,
    brnz_enrolment, brnz_contact and brnz_contact_test_record. Requires
    migrations 20260928_01 (brnz_contact.CreatedOn / StateCode) and
    20260928_02 (the lifecycle columns).
====================================================================*/
create or alter procedure Layercake.usp_load_ref_enrolment_exception
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id        bigint,
            @ins           int = 0,
            @upd           int = 0,
            @rc            int,
            @superseded    int = 0,
            @reopened      int = 0,
            @substep_ts    datetime2(3),
            @err           nvarchar(4000),
            @today         date = cast(getdate() as date),
            @current_cy    int,
            @affected_from date,
            @logged        int,
            @step          nvarchar(128);

    -- campaign year Y = 01 Oct (Y-1) .. 30 Sep (Y)
    set @current_cy = year(@today) + iif(month(@today) >= 10, 1, 0);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'silver', 'ref_enrolment_exception', @log_id output;
        set @substep_ts = sysdatetime();

        /*------------------------------------------------------------------
            1. THE QUALIFYING-ROW TEST
               Per contact, whether a part-1 (enrolment) and/or part-2
               (election) row exists. Staged first because it is read by
               BOTH halves of the module: the capture test below, and the
               supersession pass over rows already captured.
               election_date null <-> part 1, not null <-> part 2 - the
               view's own invariant, see its header.
        ------------------------------------------------------------------*/
        select
            v.[Contact No]                                           as contact_no,
            cast(max(iif(v.election_date is null, 1, 0)) as bit)     as has_qual_enrolment,
            cast(max(iif(v.election_date is not null, 1, 0)) as bit) as has_qual_election
        into #qual
        from Layercake.vw_enrolment_base v
        where v.[Contact No] is not null
        group by v.[Contact No];
        set @rc = @@rowcount;

        create unique clustered index cx_qual on #qual (contact_no);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #qual (contacts with a qualifying enrolment/election)', @rc, @substep_ts output;

        /*------------------------------------------------------------------
            2. THE DRIVER
               a. every (contact, campaign year) with a paid position, as
                  far back as the subs history reaches, up to the current
                  campaign year
        ------------------------------------------------------------------*/
        select distinct
            p.contact_no,
            p.campaign_year
        into #paid_year
        from Layercake.silv_payment_events p
        where p.campaign_year <= @current_cy;
        set @rc = @@rowcount;

        create unique clustered index cx_paid_year on #paid_year (contact_no, campaign_year);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #paid_year (paid contact x campaign year)', @rc, @substep_ts output;

        --     b. the per-year grid: a row = the contact is ACTIVE in that
        --        campaign year (paid it, or paid the one before)
        select
            y.contact_no,
            y.campaign_year,
            cast(iif(p.contact_no is null, 0, 1) as bit) as is_paid
        into #contact_year
        from (
            select contact_no, campaign_year     from #paid_year
            union
            select contact_no, campaign_year + 1 from #paid_year
            where campaign_year + 1 <= @current_cy
        ) y
        left join #paid_year p
            on  p.contact_no    = y.contact_no
            and p.campaign_year = y.campaign_year;
        set @rc = @@rowcount;

        create unique clustered index cx_contact_year on #contact_year (contact_no, campaign_year);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #contact_year (active contact x campaign year)', @rc, @substep_ts output;

        --     c. condensed to one row per contact - the audit columns that
        --        record WHY a contact was captured and the span of
        --        membership the subs history shows
        select
            contact_no,
            min(campaign_year)                                                        as first_active_campaign_year,
            max(campaign_year)                                                        as last_active_campaign_year,
            min(iif(is_paid = 1, campaign_year, null))                                as first_paid_campaign_year,
            max(iif(is_paid = 1, campaign_year, null))                                as last_paid_campaign_year,
            count(*)                                                                  as active_campaign_years,
            sum(iif(is_paid = 1, 1, 0))                                               as paid_campaign_years,
            cast(max(iif(campaign_year = @current_cy, 1, 0)) as bit)                  as is_active_current,
            cast(max(iif(campaign_year = @current_cy and is_paid = 1, 1, 0)) as bit)  as is_paid_current
        into #active
        from #contact_year
        group by contact_no;
        set @rc = @@rowcount;

        create unique clustered index cx_active on #active (contact_no);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #active (one row per driver contact)', @rc, @substep_ts output;

        /*------------------------------------------------------------------
            3. THE CAPTURE COHORT
               A driver contact with no qualifying row AND no row already
               in the table. The second test is what makes the capture
               insert-only: a contact captured under earlier rules is
               never reconsidered.
        ------------------------------------------------------------------*/
        select a.*
        into #candidate
        from #active a
        where not exists (select 1 from #qual q
                          where q.contact_no = a.contact_no)
          and not exists (select 1 from Layercake.ref_enrolment_exception x
                          where x.contact_no = a.contact_no);
        set @rc = @@rowcount;

        create unique clustered index cx_candidate on #candidate (contact_no);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #candidate (driver contacts not yet captured, no qualifying row)', @rc, @substep_ts output;

        /*------------------------------------------------------------------
            4. EVERY enrolment row for the cohort, qualifying or not -
               a rejected row still carries real dates. Student rows
               supply none (rule 1). Enrolment dates clamped as
               vw_enrolment_base clamps them.
        ------------------------------------------------------------------*/
        select
            e.[Contact No]                                                                as contact_no,
            count(*)                                                                      as source_enrolment_rows,
            min(iif(isnull(e.[Application Type], '') <> 'Student',
                    cast(iif(e.[Enrolment Date] < '19800101', '19800101', e.[Enrolment Date]) as date),
                    null))                                                                as earliest_enrolment_date,
            min(iif(isnull(e.[Application Type], '') <> 'Student',
                    cast(e.[Election Date] as date),
                    null))                                                                as earliest_election_date
        into #enr_all
        from Layercake.brnz_enrolment e
        where e._is_deleted = 0
          and e.[Contact No] is not null
          and exists (select 1 from #candidate k where k.contact_no = e.[Contact No])
        group by e.[Contact No];
        set @rc = @@rowcount;

        create unique clustered index cx_enr_all on #enr_all (contact_no);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #enr_all (all enrolment rows for the cohort)', @rc, @substep_ts output;

        /*------------------------------------------------------------------
            5. ONE contact row per contact NUMBER (rule 5)
        ------------------------------------------------------------------*/
        select v.contact_no, v.ContactId, v.MemberGrade_Description,
               v.election_date_on_contact, v.contact_created_date
        into #contact
        from (
            select
                c.Rics_contactno                  as contact_no,
                c.ContactId,
                c.MemberGrade_Description,
                cast(c.Rics_ElectionDate as date) as election_date_on_contact,
                cast(c.CreatedOn as date)         as contact_created_date,
                row_number() over (partition by c.Rics_contactno
                                   order by iif(c.StateCode = 0, 0, 1), c.CreatedOn, c.ContactId) as rn
            from Layercake.brnz_contact c
            where c._is_deleted = 0
              and c.Rics_contactno is not null
              and exists (select 1 from #candidate k where k.contact_no = c.Rics_contactno)
              and not exists (select 1
                              from Layercake.brnz_contact_test_record tst
                              where tst.contactid = c.ContactId
                                and tst._is_deleted = 0)
        ) v
        where v.rn = 1;
        set @rc = @@rowcount;

        create unique clustered index cx_contact on #contact (contact_no);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #contact (one contact row per cohort contact number)', @rc, @substep_ts output;

        -- driver contacts #contact could not supply: no brnz_contact row at all,
        -- or every row for the contact number belongs to a test record. Neither
        -- can be captured (contact_id is required), and a test record should not
        -- be. Logged rather than swallowed silently.
        select @rc = count(*)
        from #candidate k
        where not exists (select 1 from #contact c where c.contact_no = k.contact_no);
        exec Layercake.usp_etl_log_progress @log_id, N'cohort contacts with no usable brnz_contact row (test record, or none at all)', @rc, @substep_ts output;

        /*------------------------------------------------------------------
            6. DERIVE the new rows (rules 2-4). Staged rather than
               inserted straight away so the earliest affected date can be
               taken from the same row set that is inserted.
        ------------------------------------------------------------------*/
        select
            k.contact_no,
            c.ContactId                        as contact_id,
            c.MemberGrade_Description          as member_grade,
            d.derived_enrolment_date,
            d.derived_election_date,
            d.enrolment_date_source,
            d.election_date_source,
            k.first_active_campaign_year,
            k.last_active_campaign_year,
            k.first_paid_campaign_year,
            k.last_paid_campaign_year,
            k.active_campaign_years,
            k.paid_campaign_years,
            k.is_active_current,
            k.is_paid_current,
            isnull(e.source_enrolment_rows, 0) as source_enrolment_rows
        into #new_capture
        from #candidate k
        join #contact c
            on c.contact_no = k.contact_no
        left join #enr_all e
            on e.contact_no = k.contact_no
        -- rule 2: Elected or Enrolled
        cross apply (select
            iif(e.earliest_election_date is not null
                or isnull(c.MemberGrade_Description, '') <> 'Candidate', 1, 0) as is_elected
        ) g
        -- rule 3: the dates, and where each came from
        cross apply (select
            coalesce(e.earliest_enrolment_date,
                     iif(g.is_elected = 0, c.contact_created_date, null))                as derived_enrolment_date,
            case when e.earliest_enrolment_date is not null then 'Enrolment row (non-qualifying)'
                 when g.is_elected = 0                     then 'Contact CreatedOn' end  as enrolment_date_source,
            case when g.is_elected = 1
                 then coalesce(e.earliest_election_date, c.election_date_on_contact, c.contact_created_date) end
                                                                                         as derived_election_date,
            case when g.is_elected = 0                       then null
                 when e.earliest_election_date is not null   then 'Enrolment row (non-qualifying)'
                 when c.election_date_on_contact is not null then 'Rics_ElectionDate'
                 else 'Contact CreatedOn (no election date)' end                         as election_date_source
        ) d
        -- rule 4: a row must fill at least one date or it does nothing
        where d.derived_enrolment_date is not null
           or d.derived_election_date  is not null;
        set @rc = @@rowcount;

        create unique clustered index cx_new_capture on #new_capture (contact_no);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #new_capture (derived rows to insert)', @rc, @substep_ts output;

        begin tran;

        /*------------------------------------------------------------------
            7. INSERT - the only write that adds a derived date.
               has_subs_history is 1 by construction: the driver IS the
               paid subs history.
        ------------------------------------------------------------------*/
        insert into Layercake.ref_enrolment_exception
        (contact_no, contact_id, member_grade,
         derived_enrolment_date, derived_election_date,
         enrolment_date_source, election_date_source,
         has_subs_history,
         first_active_campaign_year, last_active_campaign_year,
         first_paid_campaign_year, last_paid_campaign_year,
         active_campaign_years, paid_campaign_years,
         is_active_current, is_paid_current,
         source_enrolment_rows, _capture_source)
        select
            n.contact_no, n.contact_id, n.member_grade,
            n.derived_enrolment_date, n.derived_election_date,
            n.enrolment_date_source, n.election_date_source,
            1,
            n.first_active_campaign_year, n.last_active_campaign_year,
            n.first_paid_campaign_year, n.last_paid_campaign_year,
            n.active_campaign_years, n.paid_campaign_years,
            n.is_active_current, n.is_paid_current,
            n.source_enrolment_rows, 'daily-load'
        from #new_capture n;
        set @ins = @@rowcount;

        exec Layercake.usp_etl_log_progress @log_id, N'capture new exception rows (insert-only)', @ins, @substep_ts output;

        /*------------------------------------------------------------------
            8. SUPERSEDE - a captured contact that now has a qualifying
               row. Flag, never delete: see the header.
        ------------------------------------------------------------------*/
        update x
        set superseded_at     = sysdatetime(),
            superseded_reason = case when q.has_qual_enrolment = 1 and q.has_qual_election = 1
                                     then 'Qualifying enrolment + election row'
                                     when q.has_qual_enrolment = 1
                                     then 'Qualifying enrolment row'
                                     else 'Qualifying election row' end
        from Layercake.ref_enrolment_exception x
        join #qual q
            on q.contact_no = x.contact_no
        where x.superseded_at is null;
        set @superseded = @@rowcount;

        exec Layercake.usp_etl_log_progress @log_id, N'supersede rows whose contact gained a qualifying row', @superseded, @substep_ts output;

        /*------------------------------------------------------------------
            9. RE-OPEN - a superseded contact whose qualifying row has
               gone again (a correction reversed upstream, or a row that
               has stopped passing the rules). Mirrors the way
               silv_data_anomaly re-opens a resolved row: the gap-fill is
               load-bearing again, so the stamp comes off.
        ------------------------------------------------------------------*/
        update x
        set superseded_at     = null,
            superseded_reason = null
        from Layercake.ref_enrolment_exception x
        where x.superseded_at is not null
          and not exists (select 1 from #qual q where q.contact_no = x.contact_no);
        set @reopened = @@rowcount;

        exec Layercake.usp_etl_log_progress @log_id, N're-open rows whose qualifying row has gone again', @reopened, @substep_ts output;

        /*------------------------------------------------------------------
            10. TOUCH _last_seen_at on every row still filling a real gap.
                Not an accounted update - it records that the contact was
                seen again WITHOUT a qualifying row, which is what makes a
                stale row identifiable later.
        ------------------------------------------------------------------*/
        update x
        set _last_seen_at = sysdatetime()
        from Layercake.ref_enrolment_exception x
        where not exists (select 1 from #qual q where q.contact_no = x.contact_no);
        set @rc = @@rowcount;

        exec Layercake.usp_etl_log_progress @log_id, N'touch _last_seen_at (rows still filling a gap)', @rc, @substep_ts output;

        /*------------------------------------------------------------------
            11. RETRO-CHANGE LOG. A new capture gives the contact an
                enrolment/election date that is usually years old, so it
                changes what every already-loaded date SHOULD say. The
                daily-count walk will not rebuild those dates; record the
                earliest one and let an operator apply it.
                Inside this transaction, so the capture and its log entry
                commit together.
                Supersession and re-opening are NOT logged - neither
                changes a derived date. The real rows arriving do change
                module 8's output, and module 11 logs that for itself.
        ------------------------------------------------------------------*/
        if @ins > 0
        begin
            select @affected_from = min(z.d)
            from (
                select derived_enrolment_date as d from #new_capture
                union all
                select derived_election_date       from #new_capture
            ) z;

            exec Layercake.usp_etl_log_pending_rebuild @run_id, 'enrol_exception', @affected_from, @logged output;

            set @step = concat(N'retro-change log: earliest affected date ',
                               isnull(convert(nvarchar(10), @affected_from, 23), N'(none)'),
                               iif(isnull(@logged, 0) = 0, N' - no loaded date affected', N' - pending rebuild logged'));
            exec Layercake.usp_etl_log_progress @log_id, @step, null, @substep_ts output;
        end

        commit;

        set @upd = @superseded + @reopened;
        exec Layercake.usp_etl_log_end @log_id, 'Success', @ins, @upd, 0;
    end try
    begin catch
        if xact_state() <> 0 rollback;
        set @err = concat(error_message(), ' (error ', error_number(), ', line ', error_line(), ')');
        if @log_id is not null
            exec Layercake.usp_etl_log_end @log_id, 'Failed', @ins, @upd, 0, @err;
        throw;
    end catch
end
go

/*====================================================================
    Layercake.usp_load_fact_daily_member_count_detail
    Gold layer - loads one table
====================================================================*/

/*====================================================================
    11. Layercake.fact_daily_member_count_detail
    ------------------------------------------------------------------
    BATCHED star sync from silv_daily_count_detail.

    Key mapping (all resolved through the dims, no strings on the fact):
      grade 'enrolment' -> membership_grade 'Candidate'
      grade 'election'  -> membership_grade 'Qualified'
                           (status carried from silver: Practising /
                            Retired)
      grade 'lapse'     -> grade 'N/A' (0) + status 'N/A' (0) - lapsing
                           is purely an EVENT (see the Lapse rows of
                           fact_membership_events); the rows stay only
                           so their PAID counts keep reconciling (active
                           is 0 anyway)
      anything else     -> grade 0 / status 0 (defensive)

    The silver grain includes the range region; the star grain does not,
    so the SUM/GROUP BY here also collapses region - region reporting
    rolls up from dim_country.

    MEASURES: every one is a straight SUM of its silver column, renamed
    to the star's PascalCase. The two paid readings travel together -
    PaidMembers (payment-driven) and PaidMembersEvent (event-driven:
    Join + Renewal + Readmission, resetting each 1 October, with lapsing
    NOT deducting) - plus JoinEvents / RenewalEvents / ReadmissionEvents
    carrying the daily flows the second is built from and LapseEvents
    reported alongside them. The rules behind all six live in
    usp_load_silv_daily_count; nothing is re-derived here.

    BATCHING: the silver date span is walked in @DetailBatchDays
    windows. Per window: stage the silver aggregate, find the date_ids
    where gold differs in either direction, delete + re-insert only
    those dates, COMMIT. Small transactions, small scans, steady
    progress in etl_progress_log - built for Azure SQL. Windows already
    in sync cost one indexed comparison and write nothing.
    First run after deploy: the fact is empty, every window backfills -
    one-off, expected.
====================================================================*/
create or alter procedure Layercake.usp_load_fact_daily_member_count_detail
    @run_id          uniqueidentifier = null,
    @DetailBatchDays int = 31              -- date-window size for the batched load
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();
    if @DetailBatchDays < 1 set @DetailBatchDays = 1;

    declare @log_id     bigint,
            @ins        int,
            @del        int,
            @rc         int,
            @note       nvarchar(128),
            @substep_ts datetime2(3),
            @src_count  bigint,
            @tgt_count  bigint,
            @err        nvarchar(4000);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'gold', 'fact_daily_member_count_detail', @log_id output;
        set @substep_ts = sysdatetime();

        declare @grade_candidate_id int = (select id from Layercake.dim_membership_grade where grade_name = 'Candidate'),
                @grade_qualified_id int = (select id from Layercake.dim_membership_grade where grade_name = 'Qualified');

        if @grade_candidate_id is null or @grade_qualified_id is null
            raiserror('dim_membership_grade is missing the Candidate/Qualified members - run usp_load_dim_membership_grade (and deploy the baseline DDL) before this module.', 16, 1);

        declare @span_from date = (select min([date]) from Layercake.silv_daily_count_detail),
                @span_to   date = (select max([date]) from Layercake.silv_daily_count_detail),
                @win_from  date,
                @win_to    date;

        select @ins = 0, @del = 0, @src_count = 0;

        -- gold rows for dates silver no longer covers at all (span moved, or
        -- silver emptied) - outside the window walk, so trimmed up front
        begin tran;
        delete tgt
        from Layercake.fact_daily_member_count_detail tgt
        join Layercake.dim_date d on d.id = tgt.date_id
        where @span_from is null
           or d.[date] < @span_from
           or d.[date] > @span_to;
        set @rc = @@rowcount;
        set @del = @del + @rc;
        commit;
        exec Layercake.usp_etl_log_progress @log_id, N'trim rows outside the silver date span', @rc, @substep_ts output;

        -- window work tables, created once, truncated per window
        create table #det_stage
        (
            date_id              int not null,
            country_id           int not null,
            gender_id            int not null,
            membership_grade_id  int not null,
            membership_status_id int not null,
            ActiveMembers        int not null,
            PaidMembers          int not null,
            PaidMembersEvent     int not null,
            JoinEvents           int not null,
            RenewalEvents        int not null,
            ReadmissionEvents    int not null,
            LapseEvents          int not null,
            primary key clustered (date_id, country_id, gender_id, membership_grade_id, membership_status_id)
        );
        create table #det_affected (date_id int not null primary key clustered);

        set @win_from = @span_from;
        while @win_from is not null and @win_from <= @span_to
        begin
            set @win_to = dateadd(day, @DetailBatchDays - 1, @win_from);
            if @win_to > @span_to set @win_to = @span_to;

            truncate table #det_stage;
            truncate table #det_affected;

            begin tran;

            -- stage this window's silver aggregate at the star grain
            insert into #det_stage
            (date_id, country_id, gender_id, membership_grade_id, membership_status_id,
             ActiveMembers, PaidMembers, PaidMembersEvent,
             JoinEvents, RenewalEvents, ReadmissionEvents, LapseEvents)
            select
                dd.id,
                dc.country_id,
                dc.gender_id,
                case dc.grade
                    when 'enrolment' then @grade_candidate_id
                    when 'election'  then @grade_qualified_id
                    else 0                                   -- lapse (and any unknown state) -> N/A grade
                end,
                case when dc.grade = 'election' then dc.membership_status_id
                     else 0                                  -- lapse is event-only: N/A status
                end,
                sum(dc.active_count),
                sum(dc.paid_count),
                sum(dc.paid_count_event),
                sum(dc.event_join_count),
                sum(dc.event_renewal_count),
                sum(dc.event_readmission_count),
                sum(dc.event_lapse_count)
            from Layercake.silv_daily_count_detail dc
            join Layercake.dim_date dd on dd.[date] = dc.[date]
            where dc.[date] between @win_from and @win_to
            group by
                dd.id,
                dc.country_id,
                dc.gender_id,
                case dc.grade
                    when 'enrolment' then @grade_candidate_id
                    when 'election'  then @grade_qualified_id
                    else 0
                end,
                case when dc.grade = 'election' then dc.membership_status_id
                     else 0
                end;
            set @rc = @@rowcount;
            set @src_count = @src_count + @rc;

            -- date_ids where gold differs from silver in either direction
            -- (covers new dates, changed cells, and rows that should disappear)
            insert into #det_affected (date_id)
            select date_id
            from (
                select date_id from (
                    select date_id, country_id, gender_id, membership_grade_id, membership_status_id,
                           ActiveMembers, PaidMembers, PaidMembersEvent,
                           JoinEvents, RenewalEvents, ReadmissionEvents, LapseEvents
                    from #det_stage
                    except
                    select f.date_id, f.country_id, f.gender_id, f.membership_grade_id, f.membership_status_id,
                           f.ActiveMembers, f.PaidMembers, f.PaidMembersEvent,
                           f.JoinEvents, f.RenewalEvents, f.ReadmissionEvents, f.LapseEvents
                    from Layercake.fact_daily_member_count_detail f
                    join Layercake.dim_date d on d.id = f.date_id
                    where d.[date] between @win_from and @win_to
                ) a
                union
                select date_id from (
                    select f.date_id, f.country_id, f.gender_id, f.membership_grade_id, f.membership_status_id,
                           f.ActiveMembers, f.PaidMembers, f.PaidMembersEvent,
                           f.JoinEvents, f.RenewalEvents, f.ReadmissionEvents, f.LapseEvents
                    from Layercake.fact_daily_member_count_detail f
                    join Layercake.dim_date d on d.id = f.date_id
                    where d.[date] between @win_from and @win_to
                    except
                    select date_id, country_id, gender_id, membership_grade_id, membership_status_id,
                           ActiveMembers, PaidMembers, PaidMembersEvent,
                           JoinEvents, RenewalEvents, ReadmissionEvents, LapseEvents
                    from #det_stage
                ) b
            ) v;

            delete tgt
            from Layercake.fact_daily_member_count_detail tgt
            join #det_affected a on a.date_id = tgt.date_id;
            set @del = @del + @@rowcount;

            insert into Layercake.fact_daily_member_count_detail
            (date_id, country_id, gender_id, membership_grade_id, membership_status_id,
             ActiveMembers, PaidMembers, PaidMembersEvent,
             JoinEvents, RenewalEvents, ReadmissionEvents, LapseEvents)
            select s.date_id, s.country_id, s.gender_id, s.membership_grade_id, s.membership_status_id,
                   s.ActiveMembers, s.PaidMembers, s.PaidMembersEvent,
                   s.JoinEvents, s.RenewalEvents, s.ReadmissionEvents, s.LapseEvents
            from #det_stage s
            join #det_affected a on a.date_id = s.date_id;
            set @ins = @ins + @@rowcount;

            commit;    -- one transaction per window: small, quick, self-healing

            set @note = concat(N'window ', convert(nvarchar(10), @win_from, 23),
                               N' -> ',    convert(nvarchar(10), @win_to,  23),
                               N' (', (select count(*) from #det_affected), N' dates resynced)');
            exec Layercake.usp_etl_log_progress @log_id, @note, @rc, @substep_ts output;

            set @win_from = dateadd(day, 1, @win_to);
        end

        drop table #det_stage;
        drop table #det_affected;

        -- gold should reconcile exactly back to silver: the accumulated stage
        -- rowcount across all windows is the full silver aggregate at the
        -- star grain, and the windows partition the span
        select @tgt_count = count(*) from Layercake.fact_daily_member_count_detail;
        if @src_count <> @tgt_count
            raiserror('Row count mismatch after sync of Layercake.fact_daily_member_count_detail vs silv_daily_count_detail aggregate: %I64d vs %I64d.', 16, 1, @src_count, @tgt_count);

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

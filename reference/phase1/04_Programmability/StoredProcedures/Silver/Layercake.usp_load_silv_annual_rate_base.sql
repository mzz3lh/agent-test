/*====================================================================
    Layercake.usp_load_silv_annual_rate_base
    Silver layer - loads one table
====================================================================*/

/*====================================================================
    14. Layercake.silv_annual_rate_base
    ------------------------------------------------------------------
    Segment-level annual counts for the DAX rate measures. Full
    re-derive into #rate_stage, then diff-sync on the 5-column key.
    Cheap: the table is small and sparse. Reads silv_member_base
    (boundary headcounts) and silv_membership_events (event counts).

    NOTE: this module is a FULL re-derive, so unlike the daily count it
    does pick up retrospective corrections immediately. That is
    deliberate - it is cheap, and the annual rate base is a segment
    summary rather than a day-by-day history. Expect it to move for old
    campaign years when source is corrected, while the daily count holds
    its loaded values until a @RebuildFrom run.

    members_start/end are member-grade snapshots (Candidate/Qualified)
    using the same active rule as the daily count; they are a distinct
    view from the daily fact's region/grade Lapsed bucket, so reconcile
    at the 30 Sep boundary as a validation step (tests T-06 / T-09)
    rather than expecting an identical total.
====================================================================*/
create or alter procedure Layercake.usp_load_silv_annual_rate_base
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id     bigint,
            @ins        int,
            @upd        int,
            @del        int,
            @rc         int,
            @substep_ts datetime2(3),
            @err        nvarchar(4000),
            @today      date = cast(getdate() as date);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'silver', 'silv_annual_rate_base', @log_id output;
        set @substep_ts = sysdatetime();
        begin tran;

        ;with cys as (
            -- start boundary = 30 Sep of the prior campaign year;
            -- end boundary   = 30 Sep of the current one (capped at today).
            -- Only campaign years whose start boundary has occurred are computed.
            select campaign_year,
                   datefromparts(campaign_year - 1, 9, 30) as boundary_date,
                   cast('start' as varchar(5)) as boundary
            from Layercake.ref_campaign_year_config
            where datefromparts(campaign_year - 1, 9, 30) <= @today
            union all
            select campaign_year,
                   iif(campaign_year_end > @today, @today, campaign_year_end),
                   'end'
            from Layercake.ref_campaign_year_config
            where datefromparts(campaign_year - 1, 9, 30) <= @today
        ),
        active_members as (
            -- same active rule as the daily count (v2 parity): started on/
            -- before the boundary and not lapsed on/before it - a lapsed
            -- member stops counting from the lapse date, with no
            -- current-campaign-year grace
            select
                c.campaign_year,
                c.boundary,
                b.country_id,
                b.gender_id,
                case when b.election_date <= c.boundary_date then 'Qualified'
                     when b.enrolment_date <= c.boundary_date then 'Candidate'
                     else 'N/A' end as grade_name,
                case when b.election_date <= c.boundary_date and b.retirement_date <= c.boundary_date then 'Retired'
                     when b.election_date <= c.boundary_date then 'Practising'
                     else 'N/A' end as status_name
            from cys c
            inner join Layercake.silv_member_base b
                on (b.enrolment_date <= c.boundary_date or b.election_date <= c.boundary_date)
            where b.lapsed_date is null
               or b.lapsed_date > c.boundary_date
        ),
        boundary_counts as (
            select am.campaign_year, mg.id as grade_id, ms.id as membership_status_id,
                   am.country_id, am.gender_id,
                   sum(iif(am.boundary = 'start', 1, 0)) as members_start,
                   sum(iif(am.boundary = 'end',   1, 0)) as members_end
            from active_members am
            inner join Layercake.silv_ref_membership_grade mg  on mg.grade_name = am.grade_name
            inner join Layercake.silv_ref_membership_status ms on ms.status_name = am.status_name
            group by am.campaign_year, mg.id, ms.id, am.country_id, am.gender_id
        ),
        event_counts as (
            select campaign_year, grade_id, membership_status_id, country_id, gender_id,
                   sum(iif(event_type = 'Join',        1, 0)) as members_joined,
                   sum(iif(event_type = 'Readmission', 1, 0)) as members_readmitted,
                   sum(iif(event_type = 'Lapse',       1, 0)) as members_lapsed,
                   -- includes the In-Year Readmission renewal subtype by design.
                   -- NOTE: module 9 no longer requires a payment in the PREVIOUS
                   -- campaign year for a Renewal - every payment event renews
                   -- except one in the contact's Join year (and one already
                   -- claimed by a Readmission). This count is materially higher
                   -- than it was, and is a truer count of payments: the old rule
                   -- dropped any renewal whose payment history had a gap.
                   sum(iif(event_type = 'Renewal',     1, 0)) as members_renewed
            from Layercake.silv_membership_events
            group by campaign_year, grade_id, membership_status_id, country_id, gender_id
        )
        select
            u.campaign_year, u.grade_id, u.membership_status_id, u.country_id, u.gender_id,
            sum(u.members_start)      as members_start,
            sum(u.members_end)        as members_end,
            sum(u.members_joined)     as members_joined,
            sum(u.members_readmitted) as members_readmitted,
            sum(u.members_lapsed)     as members_lapsed,
            sum(u.members_renewed)    as members_renewed
        into #rate_stage
        from (
            select campaign_year, grade_id, membership_status_id, country_id, gender_id,
                   members_start, members_end, 0 members_joined, 0 members_readmitted, 0 members_lapsed, 0 members_renewed
            from boundary_counts
            union all
            select campaign_year, grade_id, membership_status_id, country_id, gender_id,
                   0, 0, members_joined, members_readmitted, members_lapsed, members_renewed
            from event_counts
        ) u
        group by u.campaign_year, u.grade_id, u.membership_status_id, u.country_id, u.gender_id;
        set @rc = @@rowcount;

        create unique clustered index cx_rate_stage on #rate_stage
            (campaign_year, grade_id, membership_status_id, country_id, gender_id);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #rate_stage (boundary + event counts)', @rc, @substep_ts output;

        update tgt
        set members_start      = s.members_start,
            members_end        = s.members_end,
            members_joined     = s.members_joined,
            members_readmitted = s.members_readmitted,
            members_lapsed     = s.members_lapsed,
            members_renewed    = s.members_renewed
        from Layercake.silv_annual_rate_base tgt
        join #rate_stage s
          on  s.campaign_year = tgt.campaign_year
          and s.grade_id = tgt.grade_id
          and s.membership_status_id = tgt.membership_status_id
          and s.country_id = tgt.country_id
          and s.gender_id = tgt.gender_id
        where exists (select s.members_start, s.members_end, s.members_joined,
                             s.members_readmitted, s.members_lapsed, s.members_renewed
                      except
                      select tgt.members_start, tgt.members_end, tgt.members_joined,
                             tgt.members_readmitted, tgt.members_lapsed, tgt.members_renewed);
        set @upd = @@rowcount;

        insert into Layercake.silv_annual_rate_base
        (campaign_year, grade_id, membership_status_id, country_id, gender_id,
         members_start, members_end, members_joined, members_readmitted, members_lapsed, members_renewed)
        select s.campaign_year, s.grade_id, s.membership_status_id, s.country_id, s.gender_id,
               s.members_start, s.members_end, s.members_joined, s.members_readmitted, s.members_lapsed, s.members_renewed
        from #rate_stage s
        where not exists (select 1 from Layercake.silv_annual_rate_base t
                          where t.campaign_year = s.campaign_year
                            and t.grade_id = s.grade_id
                            and t.membership_status_id = s.membership_status_id
                            and t.country_id = s.country_id
                            and t.gender_id = s.gender_id);
        set @ins = @@rowcount;

        delete tgt
        from Layercake.silv_annual_rate_base tgt
        where not exists (select 1 from #rate_stage s
                          where s.campaign_year = tgt.campaign_year
                            and s.grade_id = tgt.grade_id
                            and s.membership_status_id = tgt.membership_status_id
                            and s.country_id = tgt.country_id
                            and s.gender_id = tgt.gender_id);
        set @del = @@rowcount;
        exec Layercake.usp_etl_log_progress @log_id, N'sync: update/insert/delete', null, @substep_ts output;

        commit;
        exec Layercake.usp_etl_log_end @log_id, 'Success', @ins, @upd, @del;
    end try
    begin catch
        if xact_state() <> 0 rollback;
        set @err = concat(error_message(), ' (error ', error_number(), ', line ', error_line(), ')');
        if @log_id is not null
            exec Layercake.usp_etl_log_end @log_id, 'Failed', @ins, @upd, @del, @err;
        throw;
    end catch
end
go

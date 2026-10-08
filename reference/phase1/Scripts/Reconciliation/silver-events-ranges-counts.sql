/*************************************************************************************
    Layercake SILVER events vs state ranges vs daily counts
    ---------------------------------------------------------------------------------
    PURPOSE
    A quick internal check that the three silver tables still agree with each other:

        silv_membership_events  ->  silv_member_state_ranges  ->  silv_daily_count

    The ranges are the events pivoted into from/to periods (module 11) and the counts
    are the ranges joined to the date spine (module 13), so all three should
    reconcile by construction. This script re-derives each step and shows where the
    stored tables disagree. It does NOT look at source, bronze or gold - use
    active-member-difference.sql / paid-member-difference.sql for that.

    Read-only, #temp tables only. Hand-run; never deployed.

    ---------------------------------------------------------------------------------
    RESULT SETS
      RS-1  Headline on @to - the same number read three ways, active and event-paid
      RS-2  Events -> ranges: stored range rows vs ranges re-derived from the events
            (expect no rows)
      RS-3  Ranges -> counts: stored active_count vs re-derived, per date/region/grade
            over the window (expect no rows)
      RS-4  Events -> counts: stored paid_count_event and the event flows vs
            re-derived, per date over the window (expect no rows)
      RS-5  Open pending rebuilds - the expected explanation for RS-3 / RS-4 rows on
            past dates

    ---------------------------------------------------------------------------------
    NOTES
    * silv_daily_count is FORWARD ONLY. A past date is a record of what the ranges
      said when it was first loaded, so a difference in RS-3 / RS-4 on a past date
      that RS-5 covers is drift, not a fault (remedy: @RebuildFrom). Today is rebuilt
      on every run, so a difference on today means the counts ran before the events
      or ranges last changed - re-run the silver load.
    * RS-1 'events only' is ungated for the paid line: the stored count only counts a
      paid-in contact while a state range covers the day, so events only >= the other
      two there and the gap is that gate, not an error. The active line has no such
      gate and all three should match.
    * Open-ended ranges count through TODAY, as in module 13, so keep @to <= today.
*************************************************************************************/
set nocount on;

declare @to    date = cast(getdate() as date);      -- headline date, and end of the window
declare @from  date = dateadd(day, -30, @to);       -- start of the window for RS-3 / RS-4
declare @today date = cast(getdate() as date);

declare @cy int = (select campaign_year from Layercake.ref_date_spine where [date] = @to);

/* ---------------------------------------------------------------------------------
   Ranges re-derived from the events - same rules as usp_load_silv_member_state_ranges
   --------------------------------------------------------------------------------- */
drop table if exists #rng;

with ev as (
    select e.contact_no,
           e.event_date,
           case when e.event_type = 'Join' and e.event_subtype = 'Candidate' then 'enrolment'
                -- payment-derived Join: grade N/A, so the non-qualified state
                when e.event_type = 'Join' and e.event_subtype = 'Subscription' then 'enrolment'
                when e.event_type in ('Join', 'Change')                      then 'election'
                when e.event_type = 'Readmission' then iif(mg.grade_name = 'Qualified', 'election', 'enrolment')
                when e.event_type = 'Lapse'                                  then 'lapse'
           end as grade,
           iif(e.country_id = 0, 'N/K', ctry.region_name) as region,
           case when e.event_type = 'Join'
                 and e.event_subtype in ('Candidate', 'Subscription')        then 1
                when e.event_type in ('Join', 'Change')                      then 2
                when e.event_type = 'Lapse'                                  then 3
                else 4
           end as ord
    from Layercake.silv_membership_events e
    inner join Layercake.silv_ref_country ctry        on ctry.id = e.country_id
    left  join Layercake.silv_ref_membership_grade mg on mg.id   = e.grade_id
    where e.event_type in ('Join', 'Change', 'Lapse', 'Readmission')
),
date_list as (
    select v.contact_no, v.event_date, v.grade, v.region,
           row_number() over (partition by v.contact_no order by v.event_date, v.ord) as id
    from (select distinct contact_no, event_date, grade, region, ord from ev) v
)
select a.contact_no,
       a.event_date as valid_from,
       b.event_date as valid_to,
       a.grade,
       a.region,
       a.id         as state_seq
into #rng
from date_list a
left join date_list b
    on  b.contact_no = a.contact_no
    and b.id = a.id + 1;

/* ---------------------------------------------------------------------------------
   Event-driven paid-in per contact per campaign year - same rules as module 13 step c
   --------------------------------------------------------------------------------- */
drop table if exists #paid_in;

select v.contact_no,
       v.campaign_year,
       v.event_type,
       iif(v.event_date < cfg.campaign_year_start, cfg.campaign_year_start, v.event_date) as paid_in_date
into #paid_in
from (
    select e.contact_no, e.campaign_year, e.event_type, e.event_date,
           row_number() over (partition by e.contact_no, e.campaign_year
                              order by e.event_date,
                                       case e.event_type when 'Join' then 1 when 'Readmission' then 2 else 3 end,
                                       e.event_id) as rn
    from Layercake.silv_membership_events e
    where e.event_type in ('Join', 'Renewal', 'Readmission')
) v
left join Layercake.ref_campaign_year_config cfg
    on cfg.campaign_year = v.campaign_year
where v.rn = 1
  and (cfg.campaign_year_end is null or v.event_date <= cfg.campaign_year_end);

create unique clustered index cx_paid_in on #paid_in (contact_no, campaign_year);

/* =================================================================================
   RS-1  Headline on @to
   ================================================================================= */
select 'RS-1 headline' as result_set, @to as as_of, v.measure,
       v.from_events, v.from_ranges, v.from_counts,
       v.from_events - v.from_ranges as events_minus_ranges,
       v.from_ranges - v.from_counts as ranges_minus_counts
from (
    select 'active' as measure,
           -- events only: the contact's latest state-changing event on or before
           -- @to is not a Lapse (same-day order as the ranges)
           (select count(*)
            from (select e.contact_no, e.event_type,
                         row_number() over (partition by e.contact_no
                                            order by e.event_date desc,
                                                     case when e.event_type = 'Join'
                                                           and e.event_subtype in ('Candidate', 'Subscription') then 1
                                                          when e.event_type in ('Join', 'Change') then 2
                                                          when e.event_type = 'Lapse' then 3
                                                          else 4 end desc) as rn
                  from Layercake.silv_membership_events e
                  where e.event_type in ('Join', 'Change', 'Lapse', 'Readmission')
                    and e.event_date <= @to) x
            where x.rn = 1 and x.event_type <> 'Lapse')                          as from_events,
           -- stored ranges: distinct contacts with a covering non-lapse range
           (select count(distinct r.contact_no)
            from Layercake.silv_member_state_ranges r
            where r.grade <> 'lapse'
              and @to >= r.valid_from
              and @to <  isnull(r.valid_to, dateadd(day, 1, @today)))            as from_ranges,
           (select isnull(sum(c.active_count), 0)
            from Layercake.silv_daily_count c where c.[date] = @to)              as from_counts
    union all
    select 'paid (event)',
           -- events only: UNGATED - see NOTES
           (select count(*) from #paid_in p
            where p.campaign_year = @cy and p.paid_in_date <= @to),
           -- gated by a covering stored range, as the daily count is
           (select count(distinct r.contact_no)
            from Layercake.silv_member_state_ranges r
            inner join #paid_in p
                on  p.contact_no = r.contact_no
                and p.campaign_year = @cy
                and p.paid_in_date <= @to
            where @to >= r.valid_from
              and @to <  isnull(r.valid_to, dateadd(day, 1, @today))),
           (select isnull(sum(c.paid_count_event), 0)
            from Layercake.silv_daily_count c where c.[date] = @to)
) v;

/* =================================================================================
   RS-2  Events -> ranges: row-level difference (expect no rows)
   ================================================================================= */
select 'RS-2 events vs ranges' as result_set, d.*
from (
    select 'IN_EVENTS_NOT_IN_RANGES' as side, v.*
    from (select contact_no, valid_from, valid_to, grade, region, state_seq from #rng
          except
          select contact_no, valid_from, valid_to, grade, region, state_seq from Layercake.silv_member_state_ranges) v
    union all
    select 'IN_RANGES_NOT_IN_EVENTS', v.*
    from (select contact_no, valid_from, valid_to, grade, region, state_seq from Layercake.silv_member_state_ranges
          except
          select contact_no, valid_from, valid_to, grade, region, state_seq from #rng) v
) d
order by d.contact_no, d.valid_from, d.state_seq, d.side;

/* =================================================================================
   RS-3  Ranges -> counts: active_count per date/region/grade (expect no rows)
   ================================================================================= */
drop table if exists #active_derived;

select s.[date], r.region, r.grade,
       count(distinct case when r.grade = 'lapse' then null else r.contact_no end) as active_count
into #active_derived
from Layercake.ref_date_spine s
inner join Layercake.silv_member_state_ranges r
    on  s.[date] >= r.valid_from
    and s.[date] <  isnull(r.valid_to, dateadd(day, 1, @today))
where s.[date] between @from and @to
group by s.[date], r.region, r.grade;

select 'RS-3 ranges vs counts' as result_set,
       isnull(d.[date], c.[date]) as [date],
       isnull(d.region, c.region) as region,
       isnull(d.grade,  c.grade)  as grade,
       isnull(d.active_count, 0)  as active_from_ranges,
       isnull(c.active_count, 0)  as active_in_counts,
       isnull(d.active_count, 0) - isnull(c.active_count, 0) as difference
from #active_derived d
full join (select [date], region, grade, active_count
           from Layercake.silv_daily_count
           where [date] between @from and @to) c
    on  c.[date] = d.[date] and c.region = d.region and c.grade = d.grade
where isnull(d.active_count, 0) <> isnull(c.active_count, 0)
order by 2, 3, 4;

/* =================================================================================
   RS-4  Events -> counts: event-driven paid stock and flows per date (expect no rows)
   Compared on the daily TOTAL - the flows only reconcile with the stock there.
   ================================================================================= */
drop table if exists #event_derived;

select s.[date],
       count(distinct case when p.paid_in_date <= s.[date] then r.contact_no end)                              as paid_count_event,
       count(distinct case when p.paid_in_date = s.[date] and p.event_type = 'Join'        then r.contact_no end) as event_join_count,
       count(distinct case when p.paid_in_date = s.[date] and p.event_type = 'Renewal'     then r.contact_no end) as event_renewal_count,
       count(distinct case when p.paid_in_date = s.[date] and p.event_type = 'Readmission' then r.contact_no end) as event_readmission_count
into #event_derived
from Layercake.ref_date_spine s
inner join Layercake.silv_member_state_ranges r
    on  s.[date] >= r.valid_from
    and s.[date] <  isnull(r.valid_to, dateadd(day, 1, @today))
left join #paid_in p
    on  p.contact_no    = r.contact_no
    and p.campaign_year = s.campaign_year
where s.[date] between @from and @to
group by s.[date];

select 'RS-4 events vs counts' as result_set,
       isnull(d.[date], c.[date]) as [date],
       isnull(d.paid_count_event, 0)        as paid_event_derived,  isnull(c.paid_count_event, 0)        as paid_event_in_counts,
       isnull(d.event_join_count, 0)        as join_derived,        isnull(c.event_join_count, 0)        as join_in_counts,
       isnull(d.event_renewal_count, 0)     as renewal_derived,     isnull(c.event_renewal_count, 0)     as renewal_in_counts,
       isnull(d.event_readmission_count, 0) as readmission_derived, isnull(c.event_readmission_count, 0) as readmission_in_counts
from #event_derived d
full join (select [date],
                  sum(paid_count_event)        as paid_count_event,
                  sum(event_join_count)        as event_join_count,
                  sum(event_renewal_count)     as event_renewal_count,
                  sum(event_readmission_count) as event_readmission_count
           from Layercake.silv_daily_count
           where [date] between @from and @to
           group by [date]) c
    on c.[date] = d.[date]
where isnull(d.paid_count_event, 0)        <> isnull(c.paid_count_event, 0)
   or isnull(d.event_join_count, 0)        <> isnull(c.event_join_count, 0)
   or isnull(d.event_renewal_count, 0)     <> isnull(c.event_renewal_count, 0)
   or isnull(d.event_readmission_count, 0) <> isnull(c.event_readmission_count, 0)
order by 2;

/* =================================================================================
   RS-5  Open pending rebuilds - expected drift on already-loaded dates
   ================================================================================= */
select 'RS-5 pending rebuilds' as result_set,
       affected_from, detection_count, first_detected_at, last_detected_at, detail
from Layercake.etl_daily_count_pending_rebuild
where applied_at is null
order by affected_from;

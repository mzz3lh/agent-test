/*************************************************************************************
    Layercake PIPELINE reconciliation report  (ad hoc, read-only)
    ---------------------------------------------------------------------------------
    Reconciles the numbers across every layer of the Layercake pipeline:

        SOURCE  (CE.vwContact / synapse_ce.vwEnrolments / synapse_ce.apuk_ricsrecord /
                 CE.vwLocalGroup / synapse_fo.custtrans / Subs.vwSubsMemberStatuses /
                 synapse_ce.GlobalOptionSetMetadata / synapse_ce.apuk_route /
                 ce.tblcontact_test_records)
          v
        BRONZE  (brnz_* mirrors, soft-delete aware)
          v
        SILVER  (silv_payment_events / silv_membership_events / silv_member_state_ranges /
                 silv_daily_count / silv_daily_count_detail / silv_annual_rate_base)
          v
        GOLD    (dim_* / fact_membership_events / fact_daily_member_count_detail /
                 fact_annual_rate_base)

    ...including the exception / anomaly tables:
        Layercake.ref_enrolment_exception   (07 curated backfill)
        Layercake.silv_data_anomaly         (v6 rule-mismatch log)

    STAR REWORK (31/07/2026): fact_daily_member_count is retired - the daily
    checks now run against the star-keyed fact_daily_member_count_detail
    (date_id / country_id / gender_id / membership_grade_id /
    membership_status_id). Grade/status names resolve through the dims.
    Lapsed is in NO dimension - it is purely a lifecycle EVENT
    (fact_membership_events Lapse rows); daily lapse rows sit under grade
    N/A + status N/A carrying paid counts only. D2 aggregates the FULL
    silver detail history once - fine for an ad hoc report, just expect it
    to be the slowest check in the script.

    OUTPUT (in order):
        RS-0   Run info (as-of dates, current campaign year, flags)
        RS-1   SUMMARY GRID - every check, one row, PASS / FAIL / WARN / INFO
        RS-2+  Detail sets - only the interesting ones (mismatched rows, exception
               and anomaly profiles, headline count walk)
        SPOT-* Individual-contact spot checks: boundary cohorts sampled and traced
               layer by layer (bronze snapshot -> silver events / ranges / payments
               -> as-of count status -> gold events)

    Every result set carries a leading [rs] label column so the grids are
    self-identifying in SSMS / sqlcmd output.

    STATUS semantics:
        PASS - the two sides agree exactly (or the rule holds with 0 violations)
        FAIL - a hard invariant is broken (layers out of step, rule violated)
        WARN - a soft expectation missed (documented drift / needs review)
        INFO - context numbers, no expectation attached

    NOTES / CAVEATS
      * Read-only: no writes outside #temp tables. Safe to run any time.
      * Source-vs-bronze checks compare LIVE source views against the bronze
        snapshot taken by the last 01 run. If run mid-day the source has moved
        since the sync, so small diffs there are timing, not corruption -
        re-run straight after the daily load to confirm. (Checks are flagged
        WARN, not FAIL, for exactly this reason.)
      * The headline SOURCE snapshot counts (active / paid today) use the agreed
        definitions from 'Queries to get current snapshot of active and paid
        member counts'. The pipeline's event-derived counts are a DIFFERENT
        definition by design (valid-enrolment rules, exceptions, stale-lapse
        handling), so equality is not expected - the report shows the diff and
        flags WARN only beyond @headline_tolerance_pct.
      * Set @check_source = 0 for a fast, self-contained Layercake-only run.

    HOW TO RUN
    Not deployed and not executed by Deploy-Database.ps1 - this is an ad hoc
    analysis script. Open it, set the knobs below, and run it by hand against a
    database where the daily load has completed:

        sqlcmd -S <server> -d <db> -U <user> -P <pwd> -i pipeline-reconciliation-report.sql -b -N -I

    Requires the database project deployed and at least one successful
    usp_run_daily_load. Degrades gracefully if ref_enrolment_exception or
    silv_data_anomaly are empty.
*************************************************************************************/

set nocount on;

------------------------------------------------------------------ configuration --
declare @check_source           bit           = 1;    -- 1 = compare live source views (slower, end-to-end)
declare @spot_sample            int           = 5;    -- contacts sampled per spot-check cohort
declare @headline_tolerance_pct decimal(5,2)  = 0.50; -- WARN threshold for source-vs-gold headline counts
declare @detail_rows            int           = 50;   -- max rows per mismatch detail set

------------------------------------------------------------------ run context ----
declare @today       date = cast(getdate() as date);
declare @current_cy  int  = (select campaign_year from Layercake.ref_date_spine where [date] = @today);
declare @asof        date = (select max([date]) from Layercake.silv_daily_count);          -- last loaded silver day
declare @gold_asof   date = (select max(d.[date])                                          -- last loaded gold day
                             from Layercake.fact_daily_member_count_detail f
                             join Layercake.dim_date d on d.id = f.date_id);
declare @bulk_lapse  date = (select bulk_lapse_date from Layercake.ref_campaign_year_config where campaign_year = @current_cy);
declare @cy_end      date = (select campaign_year_end from Layercake.ref_campaign_year_config where campaign_year = @current_cy);
declare @has_exc     bit  = iif(object_id('Layercake.ref_enrolment_exception') is not null, 1, 0);
declare @has_anom    bit  = iif(object_id('Layercake.silv_data_anomaly') is not null, 1, 0);
declare @a bigint, @b bigint, @c bigint, @d bigint;   -- scratch counters

-- star lookups (grade surrogate ids used by the daily-fact checks)
declare @g_cand int = (select id from Layercake.dim_membership_grade where grade_name = 'Candidate');
declare @g_qual int = (select id from Layercake.dim_membership_grade where grade_name = 'Qualified');

------------------------------------------------------------------ results store --
create table #recon
(
    seq        int identity primary key,
    section    varchar(60)   not null,
    check_id   varchar(12)   not null,
    check_name varchar(200)  not null,
    side_a     varchar(80)   null,
    value_a    bigint        null,
    side_b     varchar(80)   null,
    value_b    bigint        null,
    diff       bigint        null,
    status     varchar(4)    not null,   -- PASS / FAIL / WARN / INFO
    note       nvarchar(400) null
);

/*===================================================================================
    RS-0: run info
===================================================================================*/
select
    '[RS-0] run info'                       as [rs],
    sysdatetime()                           as run_at,
    @today                                  as today,
    @current_cy                             as current_campaign_year,
    @asof                                   as silver_loaded_through,
    @gold_asof                              as gold_loaded_through,
    @bulk_lapse                             as bulk_lapse_date_cy,
    @cy_end                                 as campaign_year_end,
    @check_source                           as check_source_flag,
    @has_exc                                as exception_table_present,
    @has_anom                               as anomaly_table_present,
    (select top (1) concat(convert(varchar(19), started_at, 120), '  ', layer, '/', step_name, '  ', status)
     from Layercake.etl_run_log order by log_id desc) as last_etl_step;

/*===================================================================================
    SECTION A - SOURCE vs BRONZE  (live reads; skipped when @check_source = 0)
    Bronze's own load already enforces these at sync time; re-checking here proves
    nothing has been touched since, and quantifies intra-day source drift.
===================================================================================*/
if @check_source = 1
begin
    -- A1 contact
    select @a = count(*) from CE.vwContact;
    select @b = count(*) from Layercake.brnz_contact where _is_deleted = 0;
    insert #recon (section, check_id, check_name, side_a, value_a, side_b, value_b, diff, status, note)
    values ('A. Source vs Bronze', 'A1', 'CE.vwContact vs brnz_contact (active)',
            'source', @a, 'bronze active', @b, @a - @b,
            iif(@a = @b, 'PASS', 'WARN'),
            iif(@a = @b, null, N'Diff can be intra-day source drift since the last 01 run - re-run after the daily load to confirm'));

    -- A2 enrolment
    select @a = count(*) from synapse_ce.vwEnrolments;
    select @b = count(*) from Layercake.brnz_enrolment where _is_deleted = 0;
    insert #recon values ('A. Source vs Bronze', 'A2', 'synapse_ce.vwEnrolments vs brnz_enrolment (active)',
            'source', @a, 'bronze active', @b, @a - @b, iif(@a = @b, 'PASS', 'WARN'),
            iif(@a = @b, null, N'Possible intra-day drift - see A1 note'));

    -- A3 rics record
    select @a = count(*) from synapse_ce.apuk_ricsrecord;
    select @b = count(*) from Layercake.brnz_rics_record where _is_deleted = 0;
    insert #recon values ('A. Source vs Bronze', 'A3', 'synapse_ce.apuk_ricsrecord vs brnz_rics_record (active)',
            'source', @a, 'bronze active', @b, @a - @b, iif(@a = @b, 'PASS', 'WARN'),
            iif(@a = @b, null, N'Possible intra-day drift - see A1 note'));

    -- A4 local group (bronze keeps ONE row per non-null country - mirror 01's dedupe)
    select @a = count(distinct apuk_countryid) from CE.vwLocalGroup where apuk_countryid is not null;
    select @b = count(*) from Layercake.brnz_local_group where _is_deleted = 0;
    insert #recon values ('A. Source vs Bronze', 'A4', 'CE.vwLocalGroup (distinct countries) vs brnz_local_group (active)',
            'source distinct', @a, 'bronze active', @b, @a - @b, iif(@a = @b, 'PASS', 'WARN'),
            iif(@a = @b, null, N'Possible intra-day drift - see A1 note'));

    -- A5 cust trans
    select @a = count(*) from synapse_fo.custtrans;
    select @b = count(*) from Layercake.brnz_cust_trans where _is_deleted = 0;
    insert #recon values ('A. Source vs Bronze', 'A5', 'synapse_fo.custtrans vs brnz_cust_trans (active)',
            'source', @a, 'bronze active', @b, @a - @b, iif(@a = @b, 'PASS', 'WARN'),
            iif(@a = @b, null, N'Possible intra-day drift - see A1 note'));

    -- A6 subs status (bronze keys on contact + campaign year, nulls skipped - mirror 01's dedupe)
    select @a = count(*)
    from (select distinct [Contact No.], [Campaign Year]
          from Subs.vwSubsMemberStatuses
          where [Contact No.] is not null and [Campaign Year] is not null) v;
    select @b = count(*) from Layercake.brnz_subs_status where _is_deleted = 0;
    insert #recon values ('A. Source vs Bronze', 'A6', 'Subs.vwSubsMemberStatuses (keyed) vs brnz_subs_status (active)',
            'source keyed', @a, 'bronze active', @b, @a - @b, iif(@a = @b, 'PASS', 'WARN'),
            iif(@a = @b, null, N'Possible intra-day drift - see A1 note'));

    -- A7 option set (keyed dedupe, mirror 01)
    select @a = count(*)
    from (select distinct OptionSetName, [Option]
          from synapse_ce.GlobalOptionSetMetadata
          where OptionSetName is not null and [Option] is not null) v;
    select @b = count(*) from Layercake.brnz_option_set where _is_deleted = 0;
    insert #recon values ('A. Source vs Bronze', 'A7', 'GlobalOptionSetMetadata (keyed) vs brnz_option_set (active)',
            'source keyed', @a, 'bronze active', @b, @a - @b, iif(@a = @b, 'PASS', 'WARN'),
            iif(@a = @b, null, N'Possible intra-day drift - see A1 note'));

    -- A8 route
    select @a = count(*) from synapse_ce.apuk_route;
    select @b = count(*) from Layercake.brnz_route where _is_deleted = 0;
    insert #recon values ('A. Source vs Bronze', 'A8', 'synapse_ce.apuk_route vs brnz_route (active)',
            'source', @a, 'bronze active', @b, @a - @b, iif(@a = @b, 'PASS', 'WARN'),
            iif(@a = @b, null, N'Possible intra-day drift - see A1 note'));

    -- A9 test records
    select @a = count(*) from ce.tblcontact_test_records;
    select @b = count(*) from Layercake.brnz_contact_test_record where _is_deleted = 0;
    insert #recon values ('A. Source vs Bronze', 'A9', 'ce.tblcontact_test_records vs brnz_contact_test_record (active)',
            'source', @a, 'bronze active', @b, @a - @b, iif(@a = @b, 'PASS', 'WARN'),
            iif(@a = @b, null, N'Possible intra-day drift - see A1 note'));
end
else
    insert #recon values ('A. Source vs Bronze', 'A0', 'Source checks skipped (@check_source = 0)',
            null, null, null, null, null, 'INFO', N'Layercake-only run');

/*===================================================================================
    SECTION B - BRONZE profile (soft-delete volumes: context, not a test)
===================================================================================*/
insert #recon (section, check_id, check_name, side_a, value_a, side_b, value_b, diff, status, note)
select 'B. Bronze profile', concat('B', row_number() over (order by t.tbl)),
       concat(t.tbl, ': active vs soft-deleted'),
       'active', t.active_rows, 'soft-deleted', t.deleted_rows, null, 'INFO', null
from (
    select 'brnz_contact' tbl,          sum(iif(_is_deleted = 0, 1, 0)) active_rows, sum(iif(_is_deleted = 1, 1, 0)) deleted_rows from Layercake.brnz_contact
    union all select 'brnz_enrolment',    sum(iif(_is_deleted = 0, 1, 0)), sum(iif(_is_deleted = 1, 1, 0)) from Layercake.brnz_enrolment
    union all select 'brnz_rics_record',  sum(iif(_is_deleted = 0, 1, 0)), sum(iif(_is_deleted = 1, 1, 0)) from Layercake.brnz_rics_record
    union all select 'brnz_cust_trans',   sum(iif(_is_deleted = 0, 1, 0)), sum(iif(_is_deleted = 1, 1, 0)) from Layercake.brnz_cust_trans
    union all select 'brnz_subs_status',  sum(iif(_is_deleted = 0, 1, 0)), sum(iif(_is_deleted = 1, 1, 0)) from Layercake.brnz_subs_status
) t;

/*===================================================================================
    SECTION C - BRONZE vs SILVER
===================================================================================*/

-- C1 payment events: silver derives one row per active bronze subs-status row in a
--    "paid" invoice position. Exact equality expected.
select @a = count(*)
from Layercake.brnz_subs_status
where _is_deleted = 0
  and [Member Invoice Position] in ('Full Concession', 'Fully Paid', 'Partially Paid', 'Pre-Subs Payment');
select @b = count(*) from Layercake.silv_payment_events;
insert #recon values ('C. Bronze vs Silver', 'C1', 'Paid subs-status rows vs silv_payment_events',
        'bronze paid positions', @a, 'silv_payment_events', @b, @a - @b, iif(@a = @b, 'PASS', 'FAIL'),
        iif(@a = @b, null, N'silv_payment_events out of step with bronze - re-run silver'));

-- C2 event-per-contact rules ('Rules to note' #1): max one Join / Change / Lapse per
--    contact; Renewal / Readmission unique per contact + campaign year; JC/JR
--    mutually exclusive.
select @a = count(*) from (
    select contact_no from Layercake.silv_membership_events
    where event_type in ('Join', 'Change', 'Lapse')
    group by contact_no, event_type having count(*) > 1) v;
insert #recon values ('C. Bronze vs Silver', 'C2a', 'Contacts with >1 Join/Change/Lapse event of the same type',
        'violations', @a, 'expected', 0, @a, iif(@a = 0, 'PASS', 'FAIL'),
        iif(@a = 0, null, N'Rules doc #1 broken - duplicate lifecycle events'));

select @a = count(*) from (
    select contact_no, campaign_year from Layercake.silv_membership_events
    where event_type in ('Renewal', 'Readmission')
    group by contact_no, campaign_year, event_type having count(*) > 1) v;
insert #recon values ('C. Bronze vs Silver', 'C2b', 'Contact+CY with >1 Renewal/Readmission event of the same type',
        'violations', @a, 'expected', 0, @a, iif(@a = 0, 'PASS', 'FAIL'), null);

select @a = count(*) from (
    select contact_no from Layercake.silv_membership_events
    where event_type = 'Join' group by contact_no having count(*) > 1) v;
insert #recon values ('C. Bronze vs Silver', 'C2c', 'Contacts with BOTH Join/Candidate and Join/RPQ',
        'violations', @a, 'expected', 0, @a, iif(@a = 0, 'PASS', 'FAIL'),
        iif(@a = 0, null, N'JC/JR should be mutually exclusive per contact'));

-- C3 excluded populations must produce no events
select @a = count(distinct e.contact_no)
from Layercake.silv_membership_events e
join Layercake.brnz_contact c on c.Rics_contactno = e.contact_no and c._is_deleted = 0
join Layercake.brnz_contact_test_record t on t.contactid = c.ContactId and t._is_deleted = 0;
insert #recon values ('C. Bronze vs Silver', 'C3a', 'Test-record contacts with membership events',
        'violations', @a, 'expected', 0, @a, iif(@a = 0, 'PASS', 'FAIL'),
        iif(@a = 0, null, N'Test-record exclusion leaking into silver'));

with latest_rics as (
    select apuk_ricsmembershipnumber, apuk_membergrade,
           row_number() over (partition by apuk_ricsmembershipnumber order by ModifiedOn desc) n
    from Layercake.brnz_rics_record
    where _is_deleted = 0 and apuk_ricsmembershipnumber is not null
)
select @a = count(distinct e.contact_no)
from Layercake.silv_membership_events e
join latest_rics r on r.apuk_ricsmembershipnumber = e.contact_no and r.n = 1
where r.apuk_membergrade = 200000003
  -- the driver's override: a superseded Student legitimately has events
  and not exists (select 1 from Layercake.vw_student_superseded ss
                  where ss.[Contact No] = e.contact_no);
insert #recon values ('C. Bronze vs Silver', 'C3b', 'Student-grade (200000003) contacts with membership events (Student not superseded)',
        'violations', @a, 'expected', 0, @a, iif(@a = 0, 'PASS', 'FAIL'),
        iif(@a = 0, null, N'Rules doc #2 broken - Student exclusion leaking'));

-- C3c the no-rics-record exclusion. A contact with no brnz_rics_record row is
-- dropped by the silv_member_base driver AND by the payment-derived
-- Readmission, so it can carry no RANGE-BUILDING event and therefore never
-- reaches the active count. Renewal events are deliberately out of scope: they
-- neither open nor close a state range, so the Renewal derivation keeps its
-- left join to the member base and can still emit for these contacts.
-- The nested test-record filter mirrors #rics_record in module 8 exactly - a
-- rics row whose own contact is test-flagged does not count as a record.
select @a = count(distinct e.contact_no)
from Layercake.silv_membership_events e
where e.event_type in ('Join', 'Change', 'Lapse', 'Readmission')
  and not exists (select 1
                  from Layercake.brnz_rics_record r
                  where r.apuk_ricsmembershipnumber = e.contact_no
                    and r._is_deleted = 0
                    and not exists (select 1
                                    from Layercake.brnz_contact_test_record t
                                    where t.contactid = r.apuk_contactid
                                      and t._is_deleted = 0));
insert #recon values ('C. Bronze vs Silver', 'C3c', 'Contacts with NO rics record holding range-building events',
        'violations', @a, 'expected', 0, @a, iif(@a = 0, 'PASS', 'FAIL'),
        iif(@a = 0, null, N'No-rics-record exclusion leaking - deploy phase 04 and re-run 02. Cohort: silv_data_anomaly where anomaly_type = ''NO_RICS_RECORD'''));

-- C3d the no-transaction exclusion, the same shape as C3c. A contact with no
-- brnz_cust_trans row has never transacted, so the silv_member_base driver AND
-- the payment-derived Readmission both drop it and it can carry no
-- range-building event. Renewal is out of scope for the same reason as above.
-- No approved/settled filter: the driver tests EXISTENCE of a transaction.
select @a = count(distinct e.contact_no)
from Layercake.silv_membership_events e
where e.event_type in ('Join', 'Change', 'Lapse', 'Readmission')
  and not exists (select 1
                  from Layercake.brnz_cust_trans t
                  where t.accountnum  = e.contact_no
                    and t._is_deleted = 0);
insert #recon values ('C. Bronze vs Silver', 'C3d', 'Contacts with NO transaction history holding range-building events',
        'violations', @a, 'expected', 0, @a, iif(@a = 0, 'PASS', 'FAIL'),
        iif(@a = 0, null, N'No-transaction exclusion leaking - deploy phase 04 and re-run 02. Cohort: silv_data_anomaly where anomaly_type = ''NO_TRANSACTIONS'''));

-- C4 event referential integrity: every dimension id must resolve (id 0 = N/A is valid)
select @a = count(*)
from Layercake.silv_membership_events e
where not exists (select 1 from Layercake.silv_ref_membership_grade  g where g.id = e.grade_id)
   or not exists (select 1 from Layercake.silv_ref_country            c where c.id = e.country_id)
   or not exists (select 1 from Layercake.silv_ref_gender             g where g.id = e.gender_id)
   or not exists (select 1 from Layercake.silv_ref_membership_status  s where s.id = e.membership_status_id)
   or not exists (select 1 from Layercake.silv_ref_assessment_route   r where r.id = e.assessment_route_id)
   or not exists (select 1 from Layercake.silv_ref_rpq_variant        v where v.id = e.rpq_variant_id);
insert #recon values ('C. Bronze vs Silver', 'C4', 'Events with unresolvable reference ids',
        'violations', @a, 'expected', 0, @a, iif(@a = 0, 'PASS', 'FAIL'), null);

select @a = count(*) from Layercake.silv_membership_events where campaign_quarter = 'NK';
insert #recon values ('C. Bronze vs Silver', 'C4b', 'Events with campaign_quarter = NK',
        'violations', @a, 'expected', 0, @a, iif(@a = 0, 'PASS', 'FAIL'), null);

-- C5 events -> state ranges (P2-14: ranges derive ENTIRELY from events)
select @a = count(distinct contact_no) from Layercake.silv_membership_events
where event_type in ('Join', 'Change', 'Lapse', 'Readmission');
select @b = count(distinct contact_no) from Layercake.silv_member_state_ranges;
insert #recon values ('C. Bronze vs Silver', 'C5a', 'Contacts with lifecycle events vs contacts with state ranges',
        'event contacts', @a, 'range contacts', @b, @a - @b, iif(@a = @b, 'PASS', 'FAIL'),
        iif(@a = @b, null, N'Ranges out of step with events - re-run silver'));

-- exactly one open-ended range per contact
select @a = count(*) from (
    select contact_no from Layercake.silv_member_state_ranges
    group by contact_no
    having sum(iif(valid_to is null, 1, 0)) <> 1) v;
insert #recon values ('C. Bronze vs Silver', 'C5b', 'Contacts without exactly one open-ended state range',
        'violations', @a, 'expected', 0, @a, iif(@a = 0, 'PASS', 'FAIL'), null);

-- chain integrity: each range's valid_to = the next range's valid_from (by state_seq)
select @a = count(*)
from Layercake.silv_member_state_ranges a
join Layercake.silv_member_state_ranges b
  on b.contact_no = a.contact_no and b.state_seq = a.state_seq + 1
where a.valid_to is null or a.valid_to <> b.valid_from;
insert #recon values ('C. Bronze vs Silver', 'C5c', 'Broken range chains (valid_to <> next valid_from by state_seq)',
        'violations', @a, 'expected', 0, @a, iif(@a = 0, 'PASS', 'FAIL'), null);

select @a = count(*) from Layercake.silv_member_state_ranges where state_seq is null;
insert #recon values ('C. Bronze vs Silver', 'C5d', 'Ranges with NULL state_seq (v6 backfill incomplete)',
        'violations', @a, 'expected', 0, @a, iif(@a = 0, 'PASS', 'FAIL'), null);

-- C6 daily count: spine coverage + independent single-day recompute
select @a = count(*)
from Layercake.ref_date_spine s
where s.[date] between '20201001' and @asof
  and not exists (select 1 from Layercake.silv_daily_count d where d.[date] = s.[date]);
insert #recon values ('C. Bronze vs Silver', 'C6a', 'Spine dates missing from silv_daily_count (2020-10-01 -> loaded-through)',
        'missing dates', @a, 'expected', 0, @a, iif(@a = 0, 'PASS', 'FAIL'), null);

-- independent recompute of the LAST loaded day from ranges + payments, using the
-- exact half-open join rule from 02 - proves the incremental machinery landed the
-- current numbers correctly
select @a = isnull(sum(x.active_count), 0), @b = isnull(sum(x.paid_count), 0)
from (
    select
        count(distinct iif(r.grade = 'lapse', null, r.contact_no)) as active_count,
        count(distinct iif(p.renewal_date_adj <= s.[date], p.contact_no, null)) as paid_count
    from Layercake.ref_date_spine s
    join Layercake.silv_member_state_ranges r
      on  s.[date] >= r.valid_from
      and s.[date] <  isnull(r.valid_to, dateadd(day, 1, @asof))
    left join Layercake.silv_payment_events p
      on  r.contact_no = p.contact_no
      and s.campaign_year = p.campaign_year
    where s.[date] = @asof
    group by r.region, r.grade
) x;
select @c = isnull(sum(active_count), 0), @d = isnull(sum(paid_count), 0)
from Layercake.silv_daily_count where [date] = @asof;
insert #recon values ('C. Bronze vs Silver', 'C6b', concat('Active on ', convert(varchar(10), @asof, 23), ': recomputed vs stored silv_daily_count'),
        'recomputed', @a, 'stored', @c, @a - @c, iif(@a = @c, 'PASS', 'FAIL'),
        iif(@a = @c, null, N'Incremental daily count out of step - run silver with @FullRebuild = 1'));
insert #recon values ('C. Bronze vs Silver', 'C6c', concat('Paid on ', convert(varchar(10), @asof, 23), ': recomputed vs stored silv_daily_count'),
        'recomputed', @b, 'stored', @d, @b - @d, iif(@b = @d, 'PASS', 'FAIL'), null);

-- C6d the same independent recompute for the EVENT-DRIVEN paid number, read
-- straight from silv_membership_events rather than from the temp tables module
-- 13 stages: paid from the campaign year's earliest Join / Renewal /
-- Readmission, counted for the rest of that year. NO lapse test - lapsing does
-- not deduct from this measure. Same state-range gate as every other count.
select @a = count(distinct r.contact_no)
from Layercake.ref_date_spine s
join Layercake.silv_member_state_ranges r
  on  s.[date] >= r.valid_from
  and s.[date] <  isnull(r.valid_to, dateadd(day, 1, @asof))
cross apply (
    select min(e.event_date) as paid_in_date
    from Layercake.silv_membership_events e
    where e.contact_no    = r.contact_no
      and e.campaign_year = s.campaign_year
      and e.event_type in ('Join', 'Renewal', 'Readmission')
) pin
where s.[date] = @asof
  and pin.paid_in_date <= @asof;
select @c = isnull(sum(paid_count_event), 0) from Layercake.silv_daily_count where [date] = @asof;
insert #recon values ('C. Bronze vs Silver', 'C6d', concat('Paid (event-driven) on ', convert(varchar(10), @asof, 23), ': recomputed vs stored silv_daily_count'),
        'recomputed', @a, 'stored', @c, @a - @c, iif(@a = @c, 'PASS', 'FAIL'),
        iif(@a = @c, null, N'Incremental daily count out of step - run silver with @FullRebuild = 1'));

-- C6e internal consistency of the event-driven measure: its paid-in components
-- are the FLOW behind the stock, so a running total of
-- (join + renewal + readmission) from the campaign year start has to land on
-- the stored stock. event_lapse_count is deliberately absent - it is reported
-- alongside, not netted off. WARN, not FAIL: the two are attributed through the
-- state range on their own day, so a contact whose paid-in event predates their
-- first state range contributes to the stock without ever having contributed a
-- flow. That is a data oddity worth seeing, not a broken load.
select @b = isnull(sum(d.event_join_count + d.event_renewal_count
                     + d.event_readmission_count), 0)
from Layercake.silv_daily_count d
where d.[date] <= @asof
  and d.campaign_year = (select max(x.campaign_year) from Layercake.silv_daily_count x where x.[date] = @asof);
insert #recon values ('C. Bronze vs Silver', 'C6e', concat('Paid (event-driven) on ', convert(varchar(10), @asof, 23), ': running component total vs stored stock'),
        'running components', @b, 'stored stock', @c, @b - @c, iif(@b = @c, 'PASS', 'WARN'),
        iif(@b = @c, null, N'Paid-in events outside the contact state ranges - see the module 13 header'));

-- C7 exception table (07)
if @has_exc = 1
begin
    select @a = count(*) from Layercake.ref_enrolment_exception;
    insert #recon values ('C. Exceptions & anomalies', 'C7a', 'ref_enrolment_exception rows (curated backfill)',
            'rows', @a, null, null, null, 'INFO', N'Detail in RS-4');

    -- every exception contact should surface in the events layer (Join or Change),
    -- unless since excluded as test / student / soft-deleted contact
    select @a = count(*)
    from Layercake.ref_enrolment_exception x
    where not exists (select 1 from Layercake.silv_membership_events e
                      where e.contact_no = x.contact_no and e.event_type in ('Join', 'Change'));
    insert #recon values ('C. Exceptions & anomalies', 'C7b', 'Exception contacts with NO Join/Change event in silver',
            'contacts', @a, 'expected', 0, @a, iif(@a = 0, 'PASS', 'WARN'),
            iif(@a = 0, null, N'Check: excluded since capture (test/student/deleted), or fallback not coalescing - see RS-4b'));

    -- fallback self-retirement: exception rows superseded by real enrolment data
    select @a = count(*)
    from Layercake.ref_enrolment_exception x
    where exists (select 1 from Layercake.silv_membership_events e
                  where e.contact_no = x.contact_no
                    and e.event_type = 'Join' and e.source_enr_id is not null);
    insert #recon values ('C. Exceptions & anomalies', 'C7c', 'Exception rows superseded by real enrolment rows (self-retired)',
            'contacts', @a, null, null, null, 'INFO', N'Real data now wins for these - expected behaviour');

    select @a = count(*) from Layercake.ref_enrolment_exception where has_subs_history = 0;
    insert #recon values ('C. Exceptions & anomalies', 'C7d', 'Exception contacts with NO subs history (Active but can never show Paid)',
            'contacts', @a, null, null, null, 'INFO', N'Documented cohort - see 07 header');
end
else
    insert #recon values ('C. Exceptions & anomalies', 'C7', 'ref_enrolment_exception not deployed',
            null, null, null, null, null, 'INFO', null);

-- C8 anomaly log (v6)
if @has_anom = 1
begin
    insert #recon (section, check_id, check_name, side_a, value_a, side_b, value_b, diff, status, note)
    select 'C. Exceptions & anomalies', concat('C8', char(96 + cast(row_number() over (order by anomaly_type) as int))),
           concat('Open anomalies: ', anomaly_type),
           'open', sum(iif(resolved_at is null, 1, 0)),
           'resolved', sum(iif(resolved_at is not null, 1, 0)),
           null, 'INFO', N'Detail in RS-5'
    from Layercake.silv_data_anomaly
    group by anomaly_type;

    if @@rowcount = 0
        insert #recon values ('C. Exceptions & anomalies', 'C8', 'silv_data_anomaly: no anomalies logged',
                'open', 0, null, null, null, 'INFO', null);
end
else
    insert #recon values ('C. Exceptions & anomalies', 'C8', 'silv_data_anomaly not deployed (pre-v6 silver)',
            null, null, null, null, null, 'INFO', null);

/*===================================================================================
    SECTION D - SILVER vs GOLD  (gold is a straight copy / aggregate: exact equality)
===================================================================================*/

-- D0 star lookups present (the daily checks below depend on them); lapsed
-- must appear in NEITHER dim - it is event-only
insert #recon values ('D. Silver vs Gold', 'D0', 'Star lookups resolve (Candidate/Qualified grades; no Lapsed grade/status members)',
        'found', iif(@g_cand is not null, 1, 0) + iif(@g_qual is not null, 1, 0),
        'expected', 2,
        2 - (iif(@g_cand is not null, 1, 0) + iif(@g_qual is not null, 1, 0))
          + (select count(*) from Layercake.dim_membership_grade  where grade_name  = 'Lapsed')
          + (select count(*) from Layercake.dim_membership_status where status_name = 'Lapsed'),
        iif(@g_cand is not null and @g_qual is not null
            and not exists (select 1 from Layercake.dim_membership_grade  where grade_name  = 'Lapsed')
            and not exists (select 1 from Layercake.dim_membership_status where status_name = 'Lapsed'), 'PASS', 'FAIL'),
        N'Lapsed is purely an event: any Lapsed dim member should have been removed by the 00 cleanup');

-- D1 events fact: counts + full payload comparison (incl. the star date_id)
select @a = count(*) from Layercake.silv_membership_events;
select @b = count(*) from Layercake.fact_membership_events;
insert #recon values ('D. Silver vs Gold', 'D1a', 'silv_membership_events vs fact_membership_events (row count)',
        'silver', @a, 'gold', @b, @a - @b, iif(@a = @b, 'PASS', 'FAIL'), null);

select @a = count(*) from (
    select e.event_id, e.event_type, e.event_subtype, e.event_date, isnull(dd.id, 0) as date_id, e.contact_no,
           e.grade_id, e.assessment_route_id, e.rpq_variant_id, e.hpb_id, e.country_id, e.gender_id,
           e.membership_status_id, e.campaign_year, e.campaign_quarter
    from Layercake.silv_membership_events e
    left join Layercake.dim_date dd on dd.[date] = e.event_date
    except
    select event_id, event_type, event_subtype, event_date, date_id, contact_no, grade_id, assessment_route_id,
           rpq_variant_id, hpb_id, country_id, gender_id, membership_status_id, campaign_year, campaign_quarter
    from Layercake.fact_membership_events) v;
select @b = count(*) from (
    select event_id, event_type, event_subtype, event_date, date_id, contact_no, grade_id, assessment_route_id,
           rpq_variant_id, hpb_id, country_id, gender_id, membership_status_id, campaign_year, campaign_quarter
    from Layercake.fact_membership_events
    except
    select e.event_id, e.event_type, e.event_subtype, e.event_date, isnull(dd.id, 0), e.contact_no,
           e.grade_id, e.assessment_route_id, e.rpq_variant_id, e.hpb_id, e.country_id, e.gender_id,
           e.membership_status_id, e.campaign_year, e.campaign_quarter
    from Layercake.silv_membership_events e
    left join Layercake.dim_date dd on dd.[date] = e.event_date) v;
insert #recon values ('D. Silver vs Gold', 'D1b', 'Event payload differences (EXCEPT, both directions, incl. date_id)',
        'silver-only rows', @a, 'gold-only rows', @b, @a + @b, iif(@a + @b = 0, 'PASS', 'FAIL'),
        iif(@a + @b = 0, null, N'Payload drift between silver and gold events - re-run gold'));

-- D2 daily detail fact: aggregate the silver detail to the star grain exactly
--    as 03 v3 does (grade names -> grade ids; lapse -> grade N/A + status N/A,
--    lapse is event-only; region collapsed - it rolls up from dim_country in
--    the model), then compare both directions. Full-history aggregate: the
--    slowest check in this script, still fine for an ad hoc run.
select
    d.id                                              as date_id,
    dc.country_id,
    dc.gender_id,
    case dc.grade
        when 'enrolment' then isnull(@g_cand, -1)
        when 'election'  then isnull(@g_qual, -1)
        else 0
    end                                               as membership_grade_id,
    case when dc.grade = 'election' then dc.membership_status_id
         else 0                                       -- lapse is event-only: N/A status
    end                                               as membership_status_id,
    sum(dc.active_count)                              as ActiveMembers,
    sum(dc.paid_count)                                as PaidMembers,
    sum(dc.paid_count_event)                          as PaidMembersEvent,
    sum(dc.event_join_count)                          as JoinEvents,
    sum(dc.event_renewal_count)                       as RenewalEvents,
    sum(dc.event_readmission_count)                   as ReadmissionEvents,
    sum(dc.event_lapse_count)                         as LapseEvents
into #gold_expected
from Layercake.silv_daily_count_detail dc
join Layercake.dim_date d on d.[date] = dc.[date]
group by
    d.id, dc.country_id, dc.gender_id,
    case dc.grade
        when 'enrolment' then isnull(@g_cand, -1)
        when 'election'  then isnull(@g_qual, -1)
        else 0
    end,
    case when dc.grade = 'election' then dc.membership_status_id
         else 0
    end;

select @a = count(*) from (
    select date_id, country_id, gender_id, membership_grade_id, membership_status_id, ActiveMembers, PaidMembers, PaidMembersEvent, JoinEvents, RenewalEvents, ReadmissionEvents, LapseEvents from #gold_expected
    except
    select date_id, country_id, gender_id, membership_grade_id, membership_status_id, ActiveMembers, PaidMembers, PaidMembersEvent, JoinEvents, RenewalEvents, ReadmissionEvents, LapseEvents from Layercake.fact_daily_member_count_detail) v;
select @b = count(*) from (
    select date_id, country_id, gender_id, membership_grade_id, membership_status_id, ActiveMembers, PaidMembers, PaidMembersEvent, JoinEvents, RenewalEvents, ReadmissionEvents, LapseEvents from Layercake.fact_daily_member_count_detail
    except
    select date_id, country_id, gender_id, membership_grade_id, membership_status_id, ActiveMembers, PaidMembers, PaidMembersEvent, JoinEvents, RenewalEvents, ReadmissionEvents, LapseEvents from #gold_expected) v;
insert #recon values ('D. Silver vs Gold', 'D2', 'silv_daily_count_detail (star-aggregated) vs fact_daily_member_count_detail (EXCEPT, both directions)',
        'silver-only rows', @a, 'gold-only rows', @b, @a + @b, iif(@a + @b = 0, 'PASS', 'FAIL'),
        iif(@a + @b = 0, null, N'Detail in RS-2'));

-- D3 annual rate base
select @a = count(*) from (
    select campaign_year, grade_id, membership_status_id, country_id, gender_id,
           members_start, members_end, members_joined, members_readmitted, members_lapsed, members_renewed
    from Layercake.silv_annual_rate_base
    except
    select campaign_year, grade_id, membership_status_id, country_id, gender_id,
           members_start, members_end, members_joined, members_readmitted, members_lapsed, members_renewed
    from Layercake.fact_annual_rate_base) v;
select @b = count(*) from (
    select campaign_year, grade_id, membership_status_id, country_id, gender_id,
           members_start, members_end, members_joined, members_readmitted, members_lapsed, members_renewed
    from Layercake.fact_annual_rate_base
    except
    select campaign_year, grade_id, membership_status_id, country_id, gender_id,
           members_start, members_end, members_joined, members_readmitted, members_lapsed, members_renewed
    from Layercake.silv_annual_rate_base) v;
insert #recon values ('D. Silver vs Gold', 'D3', 'silv_annual_rate_base vs fact_annual_rate_base (EXCEPT, both directions)',
        'silver-only rows', @a, 'gold-only rows', @b, @a + @b, iif(@a + @b = 0, 'PASS', 'FAIL'), null);

-- D4 dims cover their silver refs (dims may keep retired members; refs must be a subset)
select @a =
      (select count(*) from Layercake.silv_ref_membership_grade  s where not exists (select 1 from Layercake.dim_membership_grade  d where d.id = s.id and d.grade_name = s.grade_name))
    + (select count(*) from Layercake.silv_ref_assessment_route  s where not exists (select 1 from Layercake.dim_assessment_route  d where d.id = s.id and d.route_code = s.route_code and d.route_name = s.route_name))
    + (select count(*) from Layercake.silv_ref_rpq_variant       s where not exists (select 1 from Layercake.dim_rpq_variant       d where d.id = s.id and d.variant_id = s.variant_id and d.variant_name = s.variant_name))
    + (select count(*) from Layercake.silv_ref_country           s where not exists (select 1 from Layercake.dim_country           d where d.id = s.id and d.country_name = s.country_name and d.region_name = s.region_name and d.market_reporting_region = s.market_reporting_region))
    + (select count(*) from Layercake.silv_ref_gender            s where not exists (select 1 from Layercake.dim_gender            d where d.id = s.id and d.gender_code = s.gender_code and d.gender_name = s.gender_name))
    + (select count(*) from Layercake.silv_ref_membership_status s where not exists (select 1 from Layercake.dim_membership_status d where d.id = s.id and d.status_name = s.status_name))
    + (select count(*) from Layercake.silv_ref_lapse_reason      s where not exists (select 1 from Layercake.dim_lapse_reason      d where d.id = s.id and d.lapse_code = s.lapse_code and d.reason_name = s.reason_name))
    + (select count(*) from Layercake.ref_campaign_year_config   s where not exists (select 1 from Layercake.dim_campaign_year     d where d.campaign_year = s.campaign_year and d.bulk_lapse_date = s.bulk_lapse_date))
    + (select count(*) from Layercake.ref_date_spine             s where not exists (select 1 from Layercake.dim_date              d where d.[date] = s.[date]));
insert #recon values ('D. Silver vs Gold', 'D4', 'Silver ref/dim members missing or stale in gold dims (all dims)',
        'violations', @a, 'expected', 0, @a, iif(@a = 0, 'PASS', 'FAIL'), null);

-- D4b dim_date surrogate integrity: id 0 = the NA member, dates unique
select @a = iif(exists (select 1 from Layercake.dim_date where id = 0 and [date] = '19000101'), 0, 1)
          + (select count(*) from (select [date] from Layercake.dim_date group by [date] having count(*) > 1) v);
insert #recon values ('D. Silver vs Gold', 'D4b', 'dim_date surrogate checks (id-0 NA member present, [date] unique)',
        'violations', @a, 'expected', 0, @a, iif(@a = 0, 'PASS', 'FAIL'), null);

-- D5 fact FK integrity against the dims (star keys; date via date_id - the
--    id-0 NA member legitimately carries the pre-spine events)
select @a = count(*)
from Layercake.fact_membership_events f
where not exists (select 1 from Layercake.dim_membership_grade  d where d.id = f.grade_id)
   or not exists (select 1 from Layercake.dim_country            d where d.id = f.country_id)
   or not exists (select 1 from Layercake.dim_gender             d where d.id = f.gender_id)
   or not exists (select 1 from Layercake.dim_membership_status  d where d.id = f.membership_status_id)
   or not exists (select 1 from Layercake.dim_assessment_route   d where d.id = f.assessment_route_id)
   or not exists (select 1 from Layercake.dim_rpq_variant        d where d.id = f.rpq_variant_id)
   or not exists (select 1 from Layercake.dim_date               d where d.id = f.date_id);
insert #recon values ('D. Silver vs Gold', 'D5', 'fact_membership_events rows with unresolvable dim keys',
        'violations', @a, 'expected', 0, @a, iif(@a = 0, 'PASS', 'FAIL'), null);

-- D5b detail fact FK integrity against the dims
select @a = count(*)
from Layercake.fact_daily_member_count_detail f
where not exists (select 1 from Layercake.dim_date              d where d.id = f.date_id)
   or not exists (select 1 from Layercake.dim_country           d where d.id = f.country_id)
   or not exists (select 1 from Layercake.dim_gender            d where d.id = f.gender_id)
   or not exists (select 1 from Layercake.dim_membership_grade  d where d.id = f.membership_grade_id)
   or not exists (select 1 from Layercake.dim_membership_status d where d.id = f.membership_status_id);
insert #recon values ('D. Silver vs Gold', 'D5b', 'fact_daily_member_count_detail rows with unresolvable dim keys',
        'violations', @a, 'expected', 0, @a, iif(@a = 0, 'PASS', 'FAIL'), null);

-- silver and gold loaded through the same date?
insert #recon values ('D. Silver vs Gold', 'D6', 'Loaded-through dates aligned (silver vs gold daily)',
        'silver max date', datediff(day, '20000101', @asof), 'gold max date', datediff(day, '20000101', @gold_asof),
        datediff(day, @gold_asof, @asof), iif(@asof = @gold_asof, 'PASS', 'FAIL'),
        concat(N'silver -> ', convert(nvarchar(10), @asof, 23), N', gold -> ', convert(nvarchar(10), @gold_asof, 23)));

/*===================================================================================
    SECTION E - HEADLINE: source snapshot definitions vs the pipeline
    (Different definitions BY DESIGN - see header. WARN only beyond tolerance.)
===================================================================================*/
if @check_source = 1
begin
    -- E1 active today: agreed source snapshot vs gold active (grades Candidate +
    --    Qualified - daily lapse rows sit under grade N/A + status N/A and carry
    --    ActiveMembers = 0 anyway) on @gold_asof
    select @a = count(*)
    from CE.vwContact
    where MemberGrade_Description in ('Candidate', 'Qualified Professional', 'Qualified Professional - 2 Years')
      and Rics_LapsedCode is null
      and StateCode = 0;
    select @b = isnull(sum(f.ActiveMembers), 0)
    from Layercake.fact_daily_member_count_detail f
    join Layercake.dim_date d on d.id = f.date_id
    where d.[date] = @gold_asof
      and f.membership_grade_id in (@g_cand, @g_qual);
    insert #recon values ('E. Headline (source vs gold)', 'E1',
            concat('ACTIVE: source snapshot today vs gold on ', convert(varchar(10), @gold_asof, 23)),
            'source snapshot', @a, 'gold active', @b, @a - @b,
            case when @a = @b then 'PASS'
                 when abs(@a - @b) * 100.0 / nullif(@a, 0) <= @headline_tolerance_pct then 'INFO'
                 else 'WARN' end,
            concat(N'Definitions differ by design (valid-enrolment rules, exceptions, stale-lapse handling). Diff = ',
                   format(abs(@a - @b) * 100.0 / nullif(@a, 0), 'N2'), N'% vs tolerance ',
                   @headline_tolerance_pct, N'%. Walk-down in RS-3.'));

    -- E2 paid today: agreed source snapshot vs gold paid (all grades/statuses,
    --    including the N/A bucket that carries the lapsed members' paid counts)
    --    on @gold_asof
    select @a = count(*)
    from Subs.vwSubsMemberStatuses
    where [Campaign Year] = @current_cy
      and [Member Invoice Position] in ('Full Concession', 'Fully Paid', 'Partially Paid', 'Pre-Subs Payment');
    select @b = isnull(sum(f.PaidMembers), 0)
    from Layercake.fact_daily_member_count_detail f
    join Layercake.dim_date d on d.id = f.date_id
    where d.[date] = @gold_asof;
    insert #recon values ('E. Headline (source vs gold)', 'E2',
            concat('PAID: source snapshot (CY', @current_cy, ') vs gold on ', convert(varchar(10), @gold_asof, 23)),
            'source snapshot', @a, 'gold paid', @b, @a - @b,
            case when @a = @b then 'PASS'
                 when abs(@a - @b) * 100.0 / nullif(@a, 0) <= @headline_tolerance_pct then 'INFO'
                 else 'WARN' end,
            N'Gold requires renewal_date_adj <= date AND an active state range; the snapshot counts every paid-position row. Walk-down in RS-3.');
end

-- E3 annual rate base boundary sanity (T-06/T-09 style): members_end for the last
--    complete CY vs the daily count at its 30 Sep boundary (Candidate+Qualified).
--    Distinct views by design - reported as INFO with the diff.
declare @last_complete_cy int = (select max(campaign_year) from Layercake.ref_campaign_year_config
                                 where campaign_year_end <= @asof);
if @last_complete_cy is not null
begin
    select @a = isnull(sum(members_end), 0) from Layercake.silv_annual_rate_base where campaign_year = @last_complete_cy;
    select @b = isnull(sum(active_count), 0) from Layercake.silv_daily_count
    where [date] = datefromparts(@last_complete_cy, 9, 30) and grade in ('enrolment', 'election');
    insert #recon values ('E. Headline (source vs gold)', 'E3',
            concat('Rate base members_end CY', @last_complete_cy, ' vs daily active on 30 Sep boundary'),
            'rate base', @a, 'daily count', @b, @a - @b, 'INFO',
            N'Member-grade snapshot vs region/grade daily bucket - reconcile-at-boundary validation, equality not required');
end

/*===================================================================================
    RS-1: THE SUMMARY GRID
===================================================================================*/
select
    '[RS-1] summary'   as [rs],
    check_id,
    section,
    check_name,
    side_a, value_a,
    side_b, value_b,
    diff,
    status,
    note
from #recon
order by seq;

-- one-line verdict
select
    '[RS-1v] verdict' as [rs],
    sum(iif(status = 'PASS', 1, 0)) as passed,
    sum(iif(status = 'FAIL', 1, 0)) as failed,
    sum(iif(status = 'WARN', 1, 0)) as warnings,
    sum(iif(status = 'INFO', 1, 0)) as info,
    iif(sum(iif(status = 'FAIL', 1, 0)) = 0, 'LAYERS RECONCILE', '>>> INVESTIGATE FAILURES <<<') as verdict
from #recon;

/*===================================================================================
    RS-2: gold vs silver daily detail mismatch detail (only rows if D2 failed)
    Names resolved through the dims so the grid is readable.
===================================================================================*/
select top (@detail_rows)
    '[RS-2] D2 detail: silver vs gold daily detail rows that differ' as [rs],
    v.which,
    dd.[date],
    ctry.country_name,
    gen.gender_name,
    mg.grade_name,
    ms.status_name,
    v.ActiveMembers,
    v.PaidMembers,
    v.PaidMembersEvent
from (
    select 'in silver agg, not gold' as which, date_id, country_id, gender_id, membership_grade_id, membership_status_id, ActiveMembers, PaidMembers, PaidMembersEvent, JoinEvents, RenewalEvents, ReadmissionEvents, LapseEvents
    from (select date_id, country_id, gender_id, membership_grade_id, membership_status_id, ActiveMembers, PaidMembers, PaidMembersEvent, JoinEvents, RenewalEvents, ReadmissionEvents, LapseEvents from #gold_expected
          except
          select date_id, country_id, gender_id, membership_grade_id, membership_status_id, ActiveMembers, PaidMembers, PaidMembersEvent, JoinEvents, RenewalEvents, ReadmissionEvents, LapseEvents from Layercake.fact_daily_member_count_detail) a
    union all
    select 'in gold, not silver agg', date_id, country_id, gender_id, membership_grade_id, membership_status_id, ActiveMembers, PaidMembers, PaidMembersEvent, JoinEvents, RenewalEvents, ReadmissionEvents, LapseEvents
    from (select date_id, country_id, gender_id, membership_grade_id, membership_status_id, ActiveMembers, PaidMembers, PaidMembersEvent, JoinEvents, RenewalEvents, ReadmissionEvents, LapseEvents from Layercake.fact_daily_member_count_detail
          except
          select date_id, country_id, gender_id, membership_grade_id, membership_status_id, ActiveMembers, PaidMembers, PaidMembersEvent, JoinEvents, RenewalEvents, ReadmissionEvents, LapseEvents from #gold_expected) b
) v
left join Layercake.dim_date              dd   on dd.id   = v.date_id
left join Layercake.dim_country           ctry on ctry.id = v.country_id
left join Layercake.dim_gender            gen  on gen.id  = v.gender_id
left join Layercake.dim_membership_grade  mg   on mg.id   = v.membership_grade_id
left join Layercake.dim_membership_status ms   on ms.id   = v.membership_status_id
order by dd.[date] desc, ctry.country_name, mg.grade_name, ms.status_name;

/*===================================================================================
    RS-3: headline count walk-down (context for E1/E2)
===================================================================================*/
if @check_source = 1
begin
    select '[RS-3] headline walk-down' as [rs], step, contacts
    from (
        select 10 ord, 'Source: active snapshot (agreed definition)' step,
               count(*) contacts
        from CE.vwContact
        where MemberGrade_Description in ('Candidate', 'Qualified Professional', 'Qualified Professional - 2 Years')
          and Rics_LapsedCode is null and StateCode = 0
        union all
        select 20, 'Silver: contacts with an open non-lapse state range today',
               count(distinct contact_no)
        from Layercake.silv_member_state_ranges
        where valid_to is null and grade <> 'lapse'
        union all
        select 30, concat('Gold: sum ActiveMembers (grades Candidate+Qualified) on ', convert(varchar(10), @gold_asof, 23)),
               isnull(sum(f.ActiveMembers), 0)
        from Layercake.fact_daily_member_count_detail f
        join Layercake.dim_date d on d.id = f.date_id
        where d.[date] = @gold_asof and f.membership_grade_id in (@g_cand, @g_qual)
        union all
        select 40, concat('Source: paid snapshot CY', @current_cy, ' (agreed definition)'),
               count(*)
        from Subs.vwSubsMemberStatuses
        where [Campaign Year] = @current_cy
          and [Member Invoice Position] in ('Full Concession', 'Fully Paid', 'Partially Paid', 'Pre-Subs Payment')
        union all
        select 50, concat('Silver: silv_payment_events rows CY', @current_cy),
               count(*)
        from Layercake.silv_payment_events where campaign_year = @current_cy
        union all
        select 55, concat('Silver: ...of which renewal_date_adj <= ', convert(varchar(10), @asof, 23), ' (day-by-day paid rule)'),
               count(*)
        from Layercake.silv_payment_events
        where campaign_year = @current_cy and renewal_date_adj <= @asof
        union all
        select 60, concat('Gold: sum PaidMembers (all grades/statuses) on ', convert(varchar(10), @gold_asof, 23)),
               isnull(sum(f.PaidMembers), 0)
        from Layercake.fact_daily_member_count_detail f
        join Layercake.dim_date d on d.id = f.date_id
        where d.[date] = @gold_asof
    ) v
    order by ord;
end

/*===================================================================================
    RS-4: exception table profile (07)
===================================================================================*/
if @has_exc = 1
begin
    select
        '[RS-4] ref_enrolment_exception profile' as [rs],
        x.member_grade,
        x.date_source,
        count(*) as contacts,
        sum(iif(x.has_subs_history = 0, 1, 0)) as no_subs_history,
        sum(x.surfacing) as surfacing_in_events,
        min(x.derived_date) as earliest_derived_date,
        max(x.derived_date) as latest_derived_date
    from (
        select
            e.member_grade,
            isnull(e.enrolment_date_source, e.election_date_source) as date_source,
            e.has_subs_history,
            isnull(e.derived_enrolment_date, e.derived_election_date) as derived_date,
            iif(exists (select 1 from Layercake.silv_membership_events ev
                        where ev.contact_no = e.contact_no and ev.event_type in ('Join', 'Change')), 1, 0) as surfacing
        from Layercake.ref_enrolment_exception e
    ) x
    group by x.member_grade, x.date_source
    order by x.member_grade, x.date_source;

    -- the C7b cohort, if any: exception contacts producing no events at all
    select top (@detail_rows)
        '[RS-4b] exception contacts with no Join/Change event' as [rs],
        x.contact_no, x.member_grade,
        x.derived_enrolment_date, x.derived_election_date, x.has_subs_history,
        iif(c.ContactId is null, 'contact missing/soft-deleted in bronze',
            iif(t.contactid is not null, 'now a test record',
                iif(r.apuk_membergrade = 200000003, 'now Student grade', 'UNEXPLAINED - investigate'))) as likely_reason
    from Layercake.ref_enrolment_exception x
    left join Layercake.brnz_contact c
           on c.Rics_contactno = x.contact_no and c._is_deleted = 0
    left join Layercake.brnz_contact_test_record t
           on t.contactid = c.ContactId and t._is_deleted = 0
    outer apply (select top (1) rr.apuk_membergrade
                 from Layercake.brnz_rics_record rr
                 where rr.apuk_ricsmembershipnumber = x.contact_no and rr._is_deleted = 0
                 order by rr.ModifiedOn desc) r
    where not exists (select 1 from Layercake.silv_membership_events e
                      where e.contact_no = x.contact_no and e.event_type in ('Join', 'Change'))
    order by x.contact_no;
end

/*===================================================================================
    RS-5: anomaly log profile (v6)
===================================================================================*/
if @has_anom = 1
begin
    select
        '[RS-5] silv_data_anomaly profile' as [rs],
        anomaly_type,
        sum(iif(resolved_at is null, 1, 0))     as open_now,
        sum(iif(resolved_at is not null, 1, 0)) as resolved,
        min(first_detected_at)                  as first_detected,
        max(last_seen_at)                       as last_seen
    from Layercake.silv_data_anomaly
    group by anomaly_type
    order by anomaly_type;
end

/*===================================================================================
    SPOT CHECKS - boundary contacts traced layer by layer
    ---------------------------------------------------------------------------------
    Cohorts:
      SAMEDAY    - contacts with a zero-length state range (same-day transition):
                   verifies the latest-state-wins count rule end to end
      BULK_EDGE  - renewal_date_adj on/±1 day of the current CY bulk lapse date:
                   the Renewal vs In-Year Readmission boundary
      CY_EDGE    - renewal_date_adj or lapse event date within 28 Sep - 02 Oct:
                   the campaign-year / annual-rate-base boundary
      EXCEPTION  - 07-backfilled contacts (mix of with / without subs history)
      ANOMALY    - one contact per open anomaly type
    Sampling is deterministic (top-N by contact_no) so consecutive runs trace the
    same contacts and stay comparable.
===================================================================================*/
create table #spot (cohort varchar(12), contact_no nvarchar(200), reason nvarchar(300),
                    primary key (cohort, contact_no));

-- SAMEDAY
insert #spot
select top (@spot_sample) 'SAMEDAY', r.contact_no,
       concat(N'Zero-length range: ', r.grade, N' on ', convert(nvarchar(10), r.valid_from, 23),
              N' superseded same day (state_seq ', r.state_seq, N')')
from Layercake.silv_member_state_ranges r
where r.valid_from = r.valid_to
order by r.valid_from desc, r.contact_no;

-- BULK_EDGE
insert #spot
select top (@spot_sample) 'BULK_EDGE', p.contact_no,
       concat(N'renewal_date_adj ', convert(nvarchar(10), p.renewal_date_adj, 23),
              N' vs CY', @current_cy, N' bulk lapse date ', convert(nvarchar(10), @bulk_lapse, 23))
from Layercake.silv_payment_events p
where p.campaign_year = @current_cy
  and p.renewal_date_adj between dateadd(day, -1, @bulk_lapse) and dateadd(day, 1, @bulk_lapse)
  and not exists (select 1 from #spot s where s.contact_no = p.contact_no)
order by p.renewal_date_adj, p.contact_no;

-- CY_EDGE: paid dates or lapse events hugging the 30 Sep / 1 Oct boundary
insert #spot
select top (@spot_sample) 'CY_EDGE', v.contact_no, v.reason
from (
    select p.contact_no,
           concat(N'renewal_date_adj ', convert(nvarchar(10), p.renewal_date_adj, 23),
                  N' at the CY', p.campaign_year, N' year-end boundary') as reason,
           p.renewal_date_adj as edge_date
    from Layercake.silv_payment_events p
    join Layercake.ref_campaign_year_config c on c.campaign_year = p.campaign_year
    where p.renewal_date_adj between dateadd(day, -2, c.campaign_year_end) and dateadd(day, 2, c.campaign_year_end)
    union all
    select e.contact_no,
           concat(N'Lapse event ', convert(nvarchar(10), e.event_date, 23),
                  N' at the CY', e.campaign_year, N' boundary'),
           e.event_date
    from Layercake.silv_membership_events e
    where e.event_type = 'Lapse'
      and (   (month(e.event_date) = 9  and day(e.event_date) >= 28)
           or (month(e.event_date) = 10 and day(e.event_date) <= 2))
) v
where not exists (select 1 from #spot s where s.contact_no = v.contact_no)
order by v.edge_date desc, v.contact_no;

-- EXCEPTION (07): favour a mix - no-subs-history first, then the rest
if @has_exc = 1
insert #spot
select top (@spot_sample) 'EXCEPTION', x.contact_no,
       concat(N'07 backfill (', x.member_grade, N', ',
              isnull(x.enrolment_date_source, x.election_date_source),
              iif(x.has_subs_history = 0, N', NO subs history)', N')'))
from Layercake.ref_enrolment_exception x
where not exists (select 1 from #spot s where s.contact_no = x.contact_no)
order by x.has_subs_history, x.contact_no;

-- ANOMALY (v6): one contact per open type
if @has_anom = 1
insert #spot
select 'ANOMALY', v.contact_no, concat(v.anomaly_type, N': ', v.detail)
from (
    select a.contact_no, a.anomaly_type, left(a.detail, 250) as detail,
           row_number() over (partition by a.anomaly_type order by a.contact_no) rn
    from Layercake.silv_data_anomaly a
    where a.resolved_at is null
      and not exists (select 1 from #spot s where s.contact_no = a.contact_no)
) v
where v.rn = 1;

-- SPOT-1: who was sampled and why
select '[SPOT-1] sampled contacts' as [rs], cohort, contact_no, reason
from #spot order by cohort, contact_no;

-- SPOT-2: bronze snapshot per contact
select
    '[SPOT-2] bronze snapshot' as [rs],
    s.cohort, s.contact_no,
    c.MemberGrade_Description,
    cast(c.Rics_ElectionDate as date) as contact_election_date,
    cast(c.Rics_LapsedDate  as date)  as contact_lapsed_date,
    enr.total_enr_rows, enr.rows_with_enrolment_date, enr.rows_with_election_date,
    rr.apuk_membergrade                as latest_rics_grade,
    cast(rr.apuk_lapseddate as date)   as rics_lapsed_date,
    subs.subs_rows, subs.paid_position_rows
from #spot s
left join Layercake.brnz_contact c
       on c.Rics_contactno = s.contact_no and c._is_deleted = 0
outer apply (select count(*) total_enr_rows,
                    sum(iif(e.[Enrolment Date] is not null, 1, 0)) rows_with_enrolment_date,
                    sum(iif(e.[Election Date]  is not null, 1, 0)) rows_with_election_date
             from Layercake.brnz_enrolment e
             where e.[Contact No] = s.contact_no and e._is_deleted = 0) enr
outer apply (select top (1) r.apuk_membergrade, r.apuk_lapseddate
             from Layercake.brnz_rics_record r
             where r.apuk_ricsmembershipnumber = s.contact_no and r._is_deleted = 0
             order by r.ModifiedOn desc) rr
outer apply (select count(*) subs_rows,
                    sum(iif(b.[Member Invoice Position] in ('Full Concession', 'Fully Paid', 'Partially Paid', 'Pre-Subs Payment'), 1, 0)) paid_position_rows
             from Layercake.brnz_subs_status b
             where b.[Contact No.] = s.contact_no and b._is_deleted = 0) subs
order by s.cohort, s.contact_no;

-- SPOT-3: silver membership events
select
    '[SPOT-3] silver events' as [rs],
    s.cohort, s.contact_no,
    e.event_type, e.event_subtype, e.event_date, e.campaign_year, e.campaign_quarter,
    g.grade_name, st.status_name, c.region_name,
    iif(e.source_enr_id is null and e.event_type = 'Join', 'exception-backfilled', null) as lineage_note
from #spot s
join Layercake.silv_membership_events e on e.contact_no = s.contact_no
left join Layercake.silv_ref_membership_grade  g  on g.id  = e.grade_id
left join Layercake.silv_ref_membership_status st on st.id = e.membership_status_id
left join Layercake.silv_ref_country           c  on c.id  = e.country_id
order by s.cohort, s.contact_no, e.event_date, e.event_type;

-- SPOT-4: silver state ranges (the zero-length ones are the interesting rows)
select
    '[SPOT-4] silver state ranges' as [rs],
    s.cohort, s.contact_no,
    r.state_seq, r.grade, r.region, r.valid_from, r.valid_to,
    iif(r.valid_from = r.valid_to, '<< zero-length (superseded same day - never counted)', null) as note
from #spot s
join Layercake.silv_member_state_ranges r on r.contact_no = s.contact_no
order by s.cohort, s.contact_no, r.state_seq;

-- SPOT-5: silver payment events, recent campaign years
select
    '[SPOT-5] silver payment events (last 3 CYs)' as [rs],
    s.cohort, s.contact_no,
    p.campaign_year, p.invoice_position, p.payment_date, p.renewal_date_adj,
    case when p.campaign_year = @current_cy and p.renewal_date_adj between @bulk_lapse and @cy_end
         then '<< In-Year Readmission window' end as note
from #spot s
join Layercake.silv_payment_events p on p.contact_no = s.contact_no
where p.campaign_year >= @current_cy - 2
order by s.cohort, s.contact_no, p.campaign_year;

-- SPOT-6: how each contact lands in the as-of counts (the state that covers @asof
--         under the half-open rule + the paid test), and the star grade/status the
--         detail fact buckets them under
select
    '[SPOT-6] as-of count status' as [rs],
    s.cohort, s.contact_no,
    @asof as asof_date,
    isnull(r.grade, '(no covering range)') as state_on_asof,
    r.region,
    case when r.contact_no is null                 then 'NOT COUNTED (no covering range)'
         when r.grade = 'lapse'                    then 'lapsed (event-only) - NOT active'
         else 'ACTIVE'                             end as active_status,
    case when p.renewal_date_adj <= @asof          then 'PAID'
         when p.contact_no is not null             then concat('not yet paid (renewal_date_adj ', convert(nvarchar(10), p.renewal_date_adj, 23), ')')
         else 'no payment event this CY'           end as paid_status,
    case r.grade when 'enrolment' then 'grade Candidate'
                 when 'election'  then 'grade Qualified'
                 when 'lapse'     then 'grade N/A + status N/A (lapse = event only)' end as feeds_gold_bucket
from #spot s
left join Layercake.silv_member_state_ranges r
       on r.contact_no = s.contact_no
      and @asof >= r.valid_from
      and @asof <  isnull(r.valid_to, dateadd(day, 1, @asof))
left join Layercake.silv_payment_events p
       on p.contact_no = s.contact_no
      and p.campaign_year = (select campaign_year from Layercake.ref_date_spine where [date] = @asof)
order by s.cohort, s.contact_no;

-- SPOT-7: gold events for the same contacts - must mirror SPOT-3 exactly
select
    '[SPOT-7] gold events (must mirror SPOT-3)' as [rs],
    s.cohort, s.contact_no,
    f.event_type, f.event_subtype, f.event_date, f.campaign_year,
    iif(exists (select e.event_type, e.event_subtype, e.event_date, e.campaign_year
                from Layercake.silv_membership_events e
                where e.event_id = f.event_id
                except
                select f.event_type, f.event_subtype, f.event_date, f.campaign_year),
        '<< DIFFERS FROM SILVER', null) as gold_vs_silver
from #spot s
join Layercake.fact_membership_events f on f.contact_no = s.contact_no
order by s.cohort, s.contact_no, f.event_date, f.event_type;

drop table #recon, #gold_expected, #spot;

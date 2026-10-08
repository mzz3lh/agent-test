/*************************************************************************************
    Layercake CONTACT-LEVEL reconciliation  (active + paid)
    ---------------------------------------------------------------------------------
    PURPOSE
    Reconcile, CONTACT BY CONTACT, the two agreed "correct" lists against what the
    pipeline actually produces, and show exactly where each contact is lost or
    gained, at which step of the logic, and for what reason.

        ACTIVE truth  (doc: 'Queries to get current snapshot of active and paid
                       member counts')
            select count(*) from CE.vwContact
            where MemberGrade_Description in ('Candidate','Qualified Professional',
                                              'Qualified Professional - 2 Years')
              and Rics_LapsedCode is null
              and StateCode = 0

        PAID truth
            select count(*) from Subs.vwSubsMemberStatuses
            where [Campaign Year] = @current_cy
              and [Member Invoice Position] in ('Full Concession','Fully Paid',
                                                'Partially Paid','Pre-Subs Payment')

    Unlike 09 (which reconciles LAYER TOTALS), this script reconciles the MEMBERSHIP
    of the two lists. Every contact in either the truth list or the pipeline's
    equivalent output gets one row per reconciliation, carrying its state at every
    gate of the bronze -> silver logic, and the FIRST gate it failed with a reason
    code.

    ---------------------------------------------------------------------------------
    THE GATES (silver load modules - 04_Programmability/StoredProcedures/Silver)

    ACTIVE                                                             gate_seq
      A10  present in Layercake.brnz_contact (_is_deleted = 0)              10
      A20  silv_member_base driver: not a test record                                 20
      A25  silv_member_base driver: latest rics record grade <> 200000003             25
                          (Student - 'Rules to note' #2), or the Student status
                          is superseded in the enrolment history
                          (vw_student_superseded - the driver's override)
      A26  silv_member_base driver: a brnz_rics_record row EXISTS for
           the membership number. No record = no grade, lapse code or
           retirement date = not a member by the source definition.
           The excluded cohort is logged as NO_RICS_RECORD in
           silv_data_anomaly. The same test is repeated on the
           payment-derived Readmission in module 9, the only event that
           can open a state range without a silv_member_base row.        26
      A27  silv_member_base driver: at least one brnz_cust_trans row
           EXISTS for the membership number. A contact that has never
           transacted is not a valid contact, so it counts as neither
           active NOR paid. The excluded cohort is logged as
           NO_TRANSACTIONS in silv_data_anomaly - but only where a
           valid enrolment or election exists, since a contact with
           neither is not a member on any reading. The same test is
           repeated on the payment-derived Readmission in module 9.     27
      A30  has any row at all in brnz_enrolment                             30
      A40  #enr_base part 1 - a row survives the valid-enrolment rules:
           enrolment date not null / route allowlist / application-type
           exclusions (nulls excluded) / not ended-without-election /
           not a 14-day cool-off cancellation                               40
      A50  #enr_base part 2 - a row survives the election rules:
           election date present / 21-type application-type exclusion /
           route <> 'Registered Valuer Top Up'                              50
      A60  an effective enrolment OR election date exists once the 07
           ref_enrolment_exception fallback is coalesced in                 60
           The enrolment date is then BACKDATED to the contact's first
           paid campaign year (silv_payment_events) where the recorded
           one sits in a LATER campaign year - module 8's subs-history
           rule, reported as ENROLMENT_AFTER_FIRST_PAID. A contact with
           NO enrolment date gets the same on its election date (the
           Join anchor in that case), reported as
           ELECTION_AFTER_FIRST_PAID. The same dates are moved FORWARD
           where the recorded campaign year has no paid position and
           the first paid one is LATER - only where the recorded year
           is inside the payment history (on or after the earliest
           campaign year in silv_payment_events) - reported as
           ENROLMENT_ / ELECTION_BEFORE_FIRST_PAID; an election the
           enrolment moved forward past is carried with it. The
           effective dates after that
           step are what every gate below tests, including the
           stale-lapse invalidation. Re-derived here from the same
           inputs so this script predicts what the driver does.
      A70  a range-building event was emitted (Join / Change /
           Readmission - Readmission is payment-derived and needs no
           enrolment at all)                                                70
      A80  a state range exists                                             80
      A85  a state range COVERS the as-of date (half-open
           [valid_from, valid_to); zero-length ranges cover nothing,
           future-dated enrolments cover nothing yet)                       85
      A90  the covering state is not 'lapse'                                90
           A90 splits three ways, because a covering 'lapse' state can
           directly contradict other evidence on the same contact:
             90  LAPSED_DESPITE_LATER_ENROLMENT - a qualifying
                 enrolment/election dated AFTER the lapse exists.
                 silv_member_base tests the lapse date against the
                 EARLIEST enrolment/election, so a member who lapsed and
                 then re-enrolled keeps their Lapse whenever the FIRST
                 enrolment predates it - the stale lapse date left on the
                 contact record stands and the member reads as lapsed.
             91  LAPSED_DESPITE_PAYMENT_THIS_CY - they have paid for the
                 current campaign year, so they are a paid member on a
                 date the pipeline calls them lapsed.
             92  LAPSED_IN_PIPELINE_NOT_IN_SOURCE - the residual.
      A99  counted in the active number                                     99

    PIPELINE_ONLY (counted active by the pipeline, excluded by the truth query)
    is not a gate walk - the pipeline did not lose the contact, the truth query
    excluded it - so those rows carry an X-series code naming the MECHANISM.
    Evaluated most specific first:
      X10  no CE.vwContact row at all for the contact number               110
      X20  latest rics record carries lapse code 200000000 (Deceased)
           with NO lapse date anywhere                                     120
      X21  ... lapse code 200000001 (Duplicate), no lapse date             121
      X22  ... any other lapse code, no lapse date                         122
           X20-X22 are the NO-DATE cohort. The source knows the contact is
           out; the pipeline has no date to exit them on, so they can be
           neither dropped today nor removed from history. There is no
           handling rule for these yet - registered in RS-14.
      X30  brnz_rics_record carries a lapsed date but
           brnz_contact.Rics_LapsedDate is null. The Lapse event reads the
           CONTACT date only, so the rics-record date is invisible to it   130
      X40  contact lapse date present but invalidated by the stale-lapse
           rule, so no Lapse event was emitted                             140
      X50  no rics record at all for this membership number                150
           RETIRED BY GATE A26 - these contacts are now excluded from
           the silv_member_base driver, so they can no longer be
           counted active and cannot reach PIPELINE_ONLY. Kept as a
           regression check: a non-zero X50 means A26 is not deployed,
           or a payment-derived Readmission has slipped past the same
           test in module 9.
      X55  no brnz_cust_trans row at all for this membership number     155
           The same shape as X50, RETIRED BY GATE A27, and kept for the
           same reason.
      X60  rics record grade is not a member grade (not 200000000
           Candidate / 200000001 Qualified Professional / 200000002
           Qualified Professional - 2 Years)                               160
      X70  only payment-derived Readmission events - v9 builds a state
           range from a Readmission with no silv_member_base basis at all  170
      X99  excluded by the truth query for a plain reason (grade, lapse
           code, state code), or unexplained                               199

    PAID
      P10  present in Layercake.brnz_subs_status (_is_deleted = 0)          10
      P20  the contact's PAID source row is the one that survives
           bronze's (contact, campaign year) dedupe. Bronze keeps one
           row per key ordered by [Renewal Date Adj] desc, [Renewal
           Date] desc, and it does that BEFORE any invoice-position
           filter - so a later non-paid row can evict the paid row and
           the contact never reaches silver at all                          20
      P30  a silv_payment_events row exists for the campaign year           30
      P40  renewal_date_adj is not null                                     40
      P50  renewal_date_adj <= as-of date                                   50
      P60  the contact has a state range covering the as-of date -
           the daily count derives paid from the SAME range join, so a
           paid contact with no covering range is never counted,
           whatever their invoice position                                  60
           P60 splits two ways, because one cause of a missing range is
           now a deliberate rule rather than a gap:
             60  NO_TRANSACTION_HISTORY - the contact has a paid
                 invoice position but no brnz_cust_trans row at all, so
                 gate A27 removed them from the base. Paid on paper,
                 never transacted in cash.
             61  NO_STATE_RANGE_COVERS_ASOF - the residual.
      P99  counted in the paid number                                       99

    ---------------------------------------------------------------------------------
    HOW THE PIPELINE'S OWN NUMBER IS DERIVED HERE
    The stored counts (silv_daily_count / _detail) are aggregates, so they cannot
    tell you WHICH contacts they contain. This script re-derives the as-of numbers
    per contact using the exact join rule from step 6 of v9 (half-open range
    interval, lapse excluded from active, payment joined on campaign year with
    renewal_date_adj <= date), then reconciles that re-derivation against the
    stored aggregate in RS-9.

    IMPORTANT under v9: a mismatch in RS-9 is NOT automatically a bug. v9's daily
    count is FORWARD-ONLY - a date recorded in Layercake.etl_daily_count_loaded is
    never re-derived by a daily run, so its stored value is a point-in-time record
    of what source said when it was first loaded. RS-9 therefore reads
    etl_daily_count_loaded and etl_daily_count_pending_rebuild and tells you
    whether a difference is expected drift (remedy: @RebuildFrom) or a genuine
    out-of-step silver (remedy: re-run 02).

    ---------------------------------------------------------------------------------
    OUTPUT
        RS-0   run info, including whether the as-of date is marked loaded
        RS-1   ACTIVE gate coverage - contacts reaching each gate
        RS-2   ACTIVE: reason breakdown for truth-list contacts the pipeline does
               NOT count
        RS-3   ACTIVE: example contacts per reason
        RS-4   ACTIVE: breakdown + examples for contacts the pipeline counts that
               are NOT in the truth list, by X-series mechanism
        RS-5   PAID gate coverage
        RS-6   PAID: reason breakdown (truth not counted)
        RS-7   PAID: example contacts per reason
        RS-8   PAID: pipeline-only breakdown + examples
        RS-9   Recomputed vs STORED silv_daily_count on the as-of date, read
               against v9's forward-only load tracking
        RS-10  Headline walk: every number in one grid
        RS-11  Structural divergences, each one sized
        RS-12  Open retrospective-change log (etl_daily_count_pending_rebuild)
        RS-13  Where to look next
        RS-14  Anomaly-scenario register: the contradictions and no-date cases
               this script now names, each sized, each with its handling state
               (RULE EXISTS / NO RULE YET) and the query that lists the contacts

    Per-contact detail persists in
        Layercake.recon_active_contact
        Layercake.recon_paid_contact
        Layercake.recon_run            (one header row per reconciliation run)

    ---------------------------------------------------------------------------------
    NOTES / CAVEATS
      * Read-only against source, bronze, silver and gold. The ONLY writes are to
        the three Layercake.recon_* tables this script owns.
      * Reads the LIVE source views. If run mid-day the source has moved since the
        last 01 run, so a few bronze-missing contacts may be timing rather than
        error - re-run straight after the daily load to confirm.
      * @asof defaults to today and that is the only fully meaningful setting: the
        SOURCE side of the comparison has no as-of dimension (CE.vwContact is a
        current-state view). Setting @asof backwards compares today's source
        membership against a historical pipeline state; RS-0 flags this.
      * Rics_LapsedCode and StateCode - both used by the ACTIVE truth query - are
        NOT landed in bronze. brnz_contact carries Rics_LapsedDate but neither the
        lapse CODE nor the state code, so the pipeline cannot reproduce the truth
        filter even in principle. It infers lapse from the DATE plus the
        stale-lapse invalidation instead. Sized in RS-11.
      * The Deceased / Duplicate cohort has no exit DATE anywhere in source -
        only a lapse code on the rics record. A date-less exit cannot be
        expressed as a state range, so the pipeline can neither drop these
        contacts on the as-of date nor restate history for them. This script
        identifies and sizes them (X20 / X21 / X22, RS-14); it does not
        pretend to correct them, because there is nothing to correct them WITH.
        Fixing it needs a date landed in source, or an agreed convention (e.g.
        exit at the modified-on date of the rics record, or at the start of the
        campaign year in which the code first appeared).
      * RS-1 and RS-5 are gate COVERAGE, not a strict funnel: a contact can miss an
        early gate and still be counted (a payment-derived Readmission needs no
        enrolment row at all), so the step-to-step deltas are indicative only.
      * Set @keep_history = 1 to accumulate runs instead of replacing the last one.

    HOW TO RUN
    Not deployed and not executed by Deploy-Database.ps1 - this is an ad hoc
    analysis script, though unlike the pipeline report it DOES write its three
    recon_* diagnostic tables. Set the knobs below and run it by hand:

        sqlcmd -S <server> -d <db> -U <user> -P <pwd> -i contact-reconciliation.sql -b -N -I

    Requires the database project deployed and bronze + silver loaded.
    ref_enrolment_exception, silv_data_anomaly and the daily-count tracking
    tables are all optional (handled if absent).
*************************************************************************************/

set nocount on;
set xact_abort on;

/*====================================================================
    PREFLIGHT
    ------------------------------------------------------------------
    The three tables this script writes - recon_run, recon_active_contact
    and recon_paid_contact - are OWNED BY THE DATABASE PROJECT
    (02_Tables/Reconciliation/). Earlier revisions of this script created
    them inline and version-marker-dropped them on shape changes; that is
    gone, so there is exactly one definition in exactly one place.

    Change their shape in 02_Tables/Reconciliation/, not here.

    If the tables are absent the main batch below also fails on its own
    with 'Invalid object name' - this check just says why.
====================================================================*/
if object_id('Layercake.recon_run')            is null
or object_id('Layercake.recon_active_contact') is null
or object_id('Layercake.recon_paid_contact')   is null
    raiserror('Reconciliation tables are missing. Deploy the database project (phase 02_Tables) before running this script.', 16, 1);
go

/*  Shape check. Phase 02 scripts are fresh CREATEs, so a database whose recon
    tables were deployed before the newest diagnostic columns existed still
    carries the OLD shape, and the inserts below fail with one 'Invalid column
    name' per missing column. The columns listed here are the markers for each
    generation of the shape - checked up front so the failure names the remedy
    once instead of arriving as a wall of column errors.

    KEEP THIS LIST IN STEP with 02_Tables/Reconciliation/: when a diagnostic
    column is added there, add it here too.

    NOTE the raiserror below is severity 16, which ABORTS THE RUN only under
    sqlcmd -b (the documented way to run this script). SSMS carries on to the
    next batch, so the column errors appear anyway - they are consequences of
    this message, not separate faults.                                       */
-- nvarchar(1000), not (max): raiserror will not substitute a max-length argument
declare @stale_cols nvarchar(1000) =
(
    select string_agg(concat(v.tbl, '.', v.col), ', ') within group (order by v.tbl, v.col)
    from (values
        ('recon_active_contact', 'has_cust_trans'),               -- gate A27 evidence
        ('recon_active_contact', 'rr_present'),                   -- latest rics record (A26 / X-series)
        ('recon_active_contact', 'no_date_scenario'),             -- X20/X21/X22 no-exit-date cohort
        ('recon_active_contact', 'p1_max_enrolment_date'),        -- A90 lapse-vs-activity split
        ('recon_active_contact', 'paid_but_lapsed'),
        ('recon_paid_contact',   'has_cust_trans')                -- A27 on the paid side
    ) v (tbl, col)
    where object_id('Layercake.' + v.tbl) is not null
      and col_length('Layercake.' + v.tbl, v.col) is null
);

if @stale_cols is not null
    raiserror('The Layercake.recon_* tables are an older shape - missing: %s. These are diagnostic tables rebuilt on every run, so drop and redeploy them:
    drop table Layercake.recon_active_contact;
    drop table Layercake.recon_paid_contact;
    drop table Layercake.recon_run;
then .\Deploy-Database.ps1 -Phase 02 -Filter Reconciliation
Any ''Invalid column name'' errors below follow from this - fix this first.', 16, 1, @stale_cols);
go



/*====================================================================
    THE RECONCILIATION BATCH
    ------------------------------------------------------------------
    Everything below is one batch. @keep_history = 1 accumulates runs
    instead of replacing.
====================================================================*/
set nocount on;
set xact_abort on;

------------------------------------------------------------------ configuration --
declare @asof         date = cast(getdate() as date);  -- reconcile as at this date
declare @keep_history bit  = 0;    -- 1 = keep previous runs' rows, 0 = replace
declare @examples     int  = 20;   -- example contacts shown per reason code

------------------------------------------------------------------ run context ----
declare @run_id      uniqueidentifier = newid();
declare @today       date = cast(getdate() as date);
declare @current_cy  int  = (select campaign_year from Layercake.ref_date_spine where [date] = @asof);
declare @silver_asof date = (select max([date]) from Layercake.silv_daily_count);
declare @has_exc     bit  = iif(object_id('Layercake.ref_enrolment_exception')        is not null, 1, 0);
declare @has_anom    bit  = iif(object_id('Layercake.silv_data_anomaly')              is not null, 1, 0);
declare @has_dcl     bit  = iif(object_id('Layercake.etl_daily_count_loaded')         is not null, 1, 0);
declare @has_dcp     bit  = iif(object_id('Layercake.etl_daily_count_pending_rebuild') is not null, 1, 0);
declare @asof_txt    varchar(10) = convert(varchar(10), @asof, 23);

if @current_cy is null
begin
    raiserror('The as-of date %s is not in Layercake.ref_date_spine - run the silver load first.', 16, 1, @asof_txt);
    return;
end

-- re-runnable in the same session even after an aborted run
drop table if exists #exc, #anom, #dc_loaded, #dc_pending, #src_contact, #truth_active,
                     #src_subs, #subs_agg, #truth_paid, #state_asof, #pipe_active, #pipe_paid,
                     #cohort_a, #cohort_p, #p_ranges, #a_bronze, #enr, #enr_agg, #enr_rpq,
                     #a_events, #a_ranges, #a_anom;

if @keep_history = 0
begin
    truncate table Layercake.recon_active_contact;
    truncate table Layercake.recon_paid_contact;
    delete from Layercake.recon_run;
end

insert into Layercake.recon_run (run_id, asof_date, campaign_year, silver_loaded_through, notes)
values (@run_id, @asof, @current_cy, @silver_asof,
        N'Contact-level reconciliation of the agreed active/paid snapshot queries against bronze + silver');


/*====================================================================
    0. Optional tables staged into #temps so this script still runs
       when 07 / the v6 anomaly log / v9's load tracking are absent.
====================================================================*/
create table #exc
(
    contact_no             nvarchar(200) not null primary key,
    derived_enrolment_date date null,
    derived_election_date  date null,
    member_grade           nvarchar(200) null,
    has_subs_history       bit null
);
if @has_exc = 1
    exec (N'insert into #exc (contact_no, derived_enrolment_date, derived_election_date, member_grade, has_subs_history)
            select contact_no, derived_enrolment_date, derived_election_date,
                   cast(member_grade as nvarchar(200)), has_subs_history
            from Layercake.ref_enrolment_exception');

create table #anom
(
    contact_no   nvarchar(200) not null,
    anomaly_type varchar(40) not null,
    primary key (contact_no, anomaly_type)
);
if @has_anom = 1
    exec (N'insert into #anom (contact_no, anomaly_type)
            select distinct contact_no, anomaly_type
            from Layercake.silv_data_anomaly
            where resolved_at is null');

create table #dc_loaded ([date] date not null primary key);
if @has_dcl = 1
    exec (N'insert into #dc_loaded ([date]) select [date] from Layercake.etl_daily_count_loaded');

create table #dc_pending
(
    [source]          varchar(20) not null,
    affected_from     date not null,
    detection_count   int null,
    first_detected_at datetime2(3) null,
    last_detected_at  datetime2(3) null
);
if @has_dcp = 1
    exec (N'insert into #dc_pending ([source], affected_from, detection_count, first_detected_at, last_detected_at)
            select [source], affected_from, detection_count, first_detected_at, last_detected_at
            from Layercake.etl_daily_count_pending_rebuild
            where applied_at is null');

declare @asof_marked_loaded bit = iif(exists (select 1 from #dc_loaded where [date] = @asof), 1, 0);


/*====================================================================
    1. SOURCE TRUTH - read live, exactly as the agreed queries define it
====================================================================*/

-- every contact row, so "pipeline-only" contacts can be explained against source
select
    c.ContactId,
    c.Rics_contactno,
    c.MemberGrade_Description,
    c.Rics_LapsedCode,
    c.StateCode,
    cast(c.Rics_ElectionDate as date) as Rics_ElectionDate,
    cast(c.Rics_LapsedDate   as date) as Rics_LapsedDate,
    cast(iif(c.MemberGrade_Description in ('Candidate', 'Qualified Professional', 'Qualified Professional - 2 Years')
             and c.Rics_LapsedCode is null
             and c.StateCode = 0, 1, 0) as bit) as in_truth
into #src_contact
from CE.vwContact c;

create clustered index cx_src_contact on #src_contact (Rics_contactno);

-- collapsed to the contact NUMBER, which is the pipeline's key throughout
select
    s.Rics_contactno                          as contact_no,
    count(*)                                  as src_contact_rows,
    max(cast(s.in_truth as int))              as in_truth,
    max(s.MemberGrade_Description)            as src_member_grade,
    max(left(s.Rics_LapsedCode, 100))         as src_lapse_code,
    min(s.StateCode)                          as src_state_code,
    min(s.Rics_ElectionDate)                  as src_election_date,
    min(s.Rics_LapsedDate)                    as src_lapsed_date
into #truth_active
from #src_contact s
where s.Rics_contactno is not null
group by s.Rics_contactno;

create unique clustered index cx_truth_active on #truth_active (contact_no);

declare @src_active_rows     int = (select count(*) from #src_contact where in_truth = 1);
declare @src_active_nulls    int = (select count(*) from #src_contact where in_truth = 1 and Rics_contactno is null);
declare @src_active_contacts int = (select count(*) from #truth_active where in_truth = 1);
declare @src_dup_contact_nos int = (select count(*) from #truth_active where src_contact_rows > 1);

-- PAID truth. Every subs row for the campaign year is staged (not just the paid
-- ones), because bronze's dedupe runs BEFORE the invoice-position filter and can
-- evict a paid row - a loss the pipeline can never recover from.
select
    b.[Contact No.]                as contact_no,
    b.[Campaign Year]              as campaign_year,
    b.[Member Invoice Position]    as invoice_position,
    cast(b.[Renewal Date]     as date) as renewal_date,
    cast(b.[Renewal Date Adj] as date) as renewal_date_adj,
    cast(iif(b.[Member Invoice Position] in ('Full Concession', 'Fully Paid',
                                             'Partially Paid', 'Pre-Subs Payment'), 1, 0) as int) as is_paid_position,
    row_number() over (partition by b.[Contact No.], b.[Campaign Year]
                       order by b.[Renewal Date Adj] desc, b.[Renewal Date] desc) as bronze_rn
into #src_subs
from Subs.vwSubsMemberStatuses b
where b.[Campaign Year] = @current_cy
  and b.[Contact No.] is not null;

create clustered index cx_src_subs on #src_subs (contact_no);

select
    s.contact_no,
    s.campaign_year,
    count(*)                                                    as src_rows_all,
    sum(s.is_paid_position)                                     as src_paid_rows,
    max(case when s.is_paid_position = 1 then s.invoice_position end) as src_invoice_position,
    max(case when s.bronze_rn = 1 then s.invoice_position end)  as src_dedupe_winner_position,
    max(case when s.bronze_rn = 1 then s.is_paid_position end)  as winner_is_paid,
    max(case when s.is_paid_position = 1 then s.renewal_date end)     as src_renewal_date,
    max(case when s.is_paid_position = 1 then s.renewal_date_adj end) as src_renewal_date_adj
into #subs_agg
from #src_subs s
group by s.contact_no, s.campaign_year;

create unique clustered index cx_subs_agg on #subs_agg (contact_no, campaign_year);

-- the truth list itself: contacts with at least one paid-position row
select *
into #truth_paid
from #subs_agg
where src_paid_rows > 0;

create unique clustered index cx_truth_paid on #truth_paid (contact_no, campaign_year);

-- the agreed query AS WRITTEN: every paid-position row, including those with a
-- null contact number (#src_subs excludes those, so read the view directly)
declare @src_paid_rows     int = (select count(*) from Subs.vwSubsMemberStatuses
                                  where [Campaign Year] = @current_cy
                                    and [Member Invoice Position] in ('Full Concession', 'Fully Paid',
                                                                      'Partially Paid', 'Pre-Subs Payment'));
declare @src_paid_nulls    int = (select count(*) from Subs.vwSubsMemberStatuses
                                  where [Campaign Year] = @current_cy
                                    and [Member Invoice Position] in ('Full Concession', 'Fully Paid',
                                                                      'Partially Paid', 'Pre-Subs Payment')
                                    and [Contact No.] is null);
declare @src_paid_contacts int = (select count(*) from #truth_paid);
declare @src_paid_dupes    int = (select isnull(sum(src_paid_rows - 1), 0) from #truth_paid where src_paid_rows > 1);
declare @src_paid_evicted  int = (select count(*) from #truth_paid where winner_is_paid = 0);


/*====================================================================
    2. THE PIPELINE'S OWN MEMBERSHIP on @asof
       Re-derived per contact with the exact step-6 join rule from v9.
====================================================================*/

-- the state range covering @asof, if any (half-open interval; zero-length ranges
-- cover nothing, so a same-day supersede lands on the later state).
-- A correctly chained contact has exactly ONE covering range. covering_ranges is
-- carried so an overlapping chain is REPORTED (RS-11) rather than silently
-- double-counted here or aborting the script on a unique index. NB v9's count
-- join would count such a contact once per cell, so a >1 here also explains an
-- RS-9 difference.
select contact_no, grade, region, state_seq, covering_ranges
into #state_asof
from (
    select
        r.contact_no,
        r.grade,
        r.region,
        r.state_seq,
        count(*)     over (partition by r.contact_no) as covering_ranges,
        row_number() over (partition by r.contact_no
                           order by r.state_seq desc, r.valid_from desc, r.grade) as rn
    from Layercake.silv_member_state_ranges r
    where @asof >= r.valid_from
      and @asof <  isnull(r.valid_to, dateadd(day, 1, @asof))
) v
where v.rn = 1;

create unique clustered index cx_state_asof on #state_asof (contact_no);

-- active membership: covering range, not lapse
select contact_no
into #pipe_active
from #state_asof
where grade <> 'lapse';

create unique clustered index cx_pipe_active on #pipe_active (contact_no);

-- paid membership: covering range of ANY grade (lapse rows still carry paid
-- counts) AND a payment event for the as-of campaign year whose adjusted renewal
-- date has arrived
select distinct p.contact_no
into #pipe_paid
from Layercake.silv_payment_events p
join #state_asof s on s.contact_no = p.contact_no
where p.campaign_year = @current_cy
  and p.renewal_date_adj <= @asof;

create unique clustered index cx_pipe_paid on #pipe_paid (contact_no);

declare @pipe_active_contacts int = (select count(*) from #pipe_active);
declare @pipe_paid_contacts   int = (select count(*) from #pipe_paid);


/*====================================================================
    3. ACTIVE COHORT = truth list  U  pipeline active
====================================================================*/
select contact_no
into #cohort_a
from (
    select contact_no from #truth_active where in_truth = 1
    union
    select contact_no from #pipe_active
) v;

create unique clustered index cx_cohort_a on #cohort_a (contact_no);


/*--------------------------------------------------------------------
    3a. bronze contact + silv_member_base driver exclusions.

    v9's silv_member_base driver is one row per ACTIVE brnz_contact row. Where two
    active rows share a Rics_contactno the derivation fans out and the
    silver load fails loudly on the #ev_stage PK - so this aggregates
    over all active rows rather than picking one, and the duplicate
    count is reported in RS-11.
    is_test_record is true only when EVERY active row is test-flagged;
    a contact with one clean row still produces events in v9.

    The rics-record apply also carries the LAPSE CODE and the rics-record
    lapse date. Neither reaches the Lapse event: silver reads apuk_lapsecode
    only to name the lapse REASON, and reads the lapse DATE from
    brnz_contact.Rics_LapsedDate, never from apuk_lapseddate. So a contact can
    carry a lapse code with no date anywhere (Deceased / Duplicate - nothing to
    date the exit from), or a rics-record lapse date the events never see.
    Both are flagged here and named in the X-series reason ladder.
--------------------------------------------------------------------*/
select
    k.contact_no,
    cast(iif(isnull(ba.brz_rows_all, 0) > 0, 1, 0) as bit)              as brz_present,
    cast(iif(isnull(bc.brz_contact_rows, 0) = 0, 1, 0) as bit)          as brz_is_deleted,
    isnull(bc.brz_contact_rows, 0)                                      as brz_contact_rows,
    bc.brz_member_grade,
    bc.brz_lapsed_date,
    cast(iif(isnull(bc.brz_contact_rows, 0) > 0 and bc.all_test = 1, 1, 0) as bit) as is_test_record,
    cast(iif(isnull(bc.any_test, 0) = 1, 1, 0) as bit)                  as any_test_record,
    rr.apuk_membergrade                                                 as latest_rics_grade,
    -- the driver's Student test, override included: a Student grade whose
    -- status is superseded in the enrolment history does not exclude
    cast(iif(isnull(rr.apuk_membergrade, 0) = 200000003
             and not exists (select 1 from Layercake.vw_student_superseded ss
                             where ss.[Contact No] = k.contact_no), 1, 0) as bit) as is_student_grade,

    /* ---- gate A27: has this contact number EVER transacted? -------
       Existence only, and no approved/settled filter - the driver test
       is that a transaction exists at all, not that it cleared.      */
    cast(iif(isnull(ct.trans_rows, 0) > 0, 1, 0) as bit)                as has_cust_trans,
    isnull(ct.trans_rows, 0)                                            as cust_trans_rows,

    /* ---- latest rics record ------------------------------------- */
    cast(iif(rr.has_rr = 1, 1, 0) as bit)                               as rr_present,
    rr.apuk_lapsecode                                                   as rr_lapse_code,
    cast(left(lr.reason_name, 200) as nvarchar(200))                    as rr_lapse_reason,
    rr.apuk_lapseddate                                                  as rr_lapsed_date,
    rr.apuk_retirementdate                                              as rr_retirement_date,
    -- a lapse code with no date ANYWHERE - neither on the rics record nor on
    -- the contact. Nothing to build an exit from.
    cast(iif(rr.apuk_lapsecode is not null
             and rr.apuk_lapseddate is null and bc.brz_lapsed_date is null, 1, 0) as bit) as rr_lapse_code_no_date,
    cast(iif(rr.apuk_lapsecode is null and rr.apuk_lapseddate is not null, 1, 0) as bit)  as rr_lapse_date_no_code,
    -- the rics record is dated but the CONTACT is not, and only the contact
    -- date reaches the Lapse event
    cast(iif(rr.apuk_lapseddate is not null and bc.brz_lapsed_date is null, 1, 0) as bit) as rr_lapse_date_not_on_contact,
    -- 200000000 Candidate / 200000001 Qualified Professional
    -- 200000002 Qualified Professional - 2 Years  (200000003 Student is A25)
    cast(iif(rr.has_rr = 1
             and isnull(rr.apuk_membergrade, 0) not in (200000000, 200000001, 200000002), 1, 0) as bit) as rr_grade_not_member,
    -- the no-date exit cohort, named from the option set where it is loaded
    case when rr.apuk_lapsecode is null
              or rr.apuk_lapseddate is not null or bc.brz_lapsed_date is not null then null
         else cast(isnull(left(lr.reason_name, 100),
                          case rr.apuk_lapsecode when 200000000 then N'Deceased'
                                                 when 200000001 then N'Duplicate'
                                                 else concat(N'lapse code ', rr.apuk_lapsecode) end)
                   as nvarchar(100))
    end                                                                 as no_date_scenario
into #a_bronze
from #cohort_a k
outer apply (
    select count(*) as brz_rows_all
    from Layercake.brnz_contact c
    where c.Rics_contactno = k.contact_no
) ba
outer apply (
    select
        count(*)                                    as brz_contact_rows,
        max(c.MemberGrade_Description)              as brz_member_grade,
        min(cast(c.Rics_LapsedDate as date))        as brz_lapsed_date,
        min(iif(t.contactid is null, 0, 1))         as all_test,
        max(iif(t.contactid is null, 0, 1))         as any_test
    from Layercake.brnz_contact c
    left join Layercake.brnz_contact_test_record t
           on t.contactid = c.ContactId and t._is_deleted = 0
    where c.Rics_contactno = k.contact_no
      and c._is_deleted = 0
) bc
outer apply (
    -- v9 #rics_record: latest record per membership number, test contacts removed.
    -- has_rr separates "no record" from "record with every column null".
    select top (1)
        1                                       as has_rr,
        r.apuk_membergrade,
        r.apuk_lapsecode,
        cast(r.apuk_lapseddate     as date)     as apuk_lapseddate,
        cast(r.apuk_retirementdate as date)     as apuk_retirementdate
    from Layercake.brnz_rics_record r
    where r.apuk_ricsmembershipnumber = k.contact_no
      and r._is_deleted = 0
      and not exists (select 1 from Layercake.brnz_contact_test_record t
                      where t.contactid = r.apuk_contactid and t._is_deleted = 0)
    order by r.ModifiedOn desc
) rr
outer apply (
    -- gate A27's evidence, counted rather than tested so a zero is
    -- distinguishable from a contact number that never reaches here
    select count(*) as trans_rows
    from Layercake.brnz_cust_trans t
    where t.accountnum  = k.contact_no
      and t._is_deleted = 0
) ct
left join Layercake.silv_ref_lapse_reason lr
       on lr.lapse_code = rr.apuk_lapsecode;

create unique clustered index cx_a_bronze on #a_bronze (contact_no);


/*--------------------------------------------------------------------
    3b. #enr_base equivalent - the two staged row sets from v9 step 4,
        restricted to the cohort, with every rule's survival flag kept
        so the funnel can name the rule that removed the row.
--------------------------------------------------------------------*/
select
    k.contact_no,
    e.[ENR ID]           as enr_id,
    e.[Created DateTime] as created_dt,
    d.enrolment_date,
    cast(e.[Election Date] as date) as election_date,
    e.[Application Type] as application_type,
    rt.apuk_name         as route_name,
    -- part 1: the valid-enrolment rules, cumulative
    f1.r1, f2.r2, f3.r3, f4.r4, f5.r5,
    fv.rv,
    -- part 2: the election rules, cumulative
    g1.s1, g2.s2, g3.s3,
    g4.is_rpq
into #enr
from #cohort_a k
join Layercake.brnz_enrolment e
     on  e.[Contact No] = k.contact_no
     and e._is_deleted  = 0
left join Layercake.brnz_route rt
     on  rt.apuk_routeid = e.[Route ID]
     and rt._is_deleted  = 0
cross apply (select cast(iif(e.[Enrolment Date] < '19800101', '19800101', e.[Enrolment Date]) as date) as enrolment_date) d
cross apply (select cast(iif(e.[Enrolment Date] is not null, 1, 0) as int) as r1) f1
cross apply (select cast(iif(f1.r1 = 1 and e.[Route ID] in (
                 '0504153D-6716-4C23-874E-32E2E2C4E3BF',   -- APC Other
                 'B0CDFF73-5825-4E73-9852-EBC6B88448E1',   -- APC Prelim
                 'E2231B53-7181-4AD8-BE15-3DAED8F0727F',   -- APC Research
                 '6942A086-7EF8-48E7-993F-B0148F419117',   -- APC Structured Training 12
                 '916E1056-C88B-4055-88A3-9FD0B57A98E7',   -- APC Structured Training 24
                 '058D1F92-BD26-48AC-8603-8CC98B7DDA8E',   -- Associate Assessment
                 'D4AC2D23-E733-4B2D-9693-2D1D2A0ACF46',   -- Senior Professional Assessment - 2017
                 '7B867DC6-8F1F-4503-8A07-BFABDDD03CB2',   -- Specialist Assessment
                 '2037C0AD-008D-48EE-B05A-9C90B4D61504'),  -- Academic
            1, 0) as int) as r2) f2
cross apply (select cast(iif(f2.r2 = 1
                 and e.[Application Type] is not null
                 and e.[Application Type] not in (
                     'Chartered Alternative Designation', 'Alternative Designation', 'Apprenticeship',
                     'Credential Application', 'Fellowship', 'Honorary', 'Re-admission', 'Scheme', 'Student'),
            1, 0) as int) as r3) f3
cross apply (select cast(iif(f3.r3 = 1
                 and not (e.[Election Date] is null and e.[End Date] is not null), 1, 0) as int) as r4) f4
cross apply (select cast(iif(f4.r4 = 1
                 and (e.[End Date] is null or e.[End Date] > dateadd(day, 14, d.enrolment_date)), 1, 0) as int) as r5) f5
-- CE.vwEnrolments_Valid parity: the view ALSO excludes Direct Entry, silver does not
cross apply (select cast(iif(f5.r5 = 1 and isnull(e.[Application Type], '') <> 'Direct Entry', 1, 0) as int) as rv) fv
cross apply (select cast(iif(e.[Election Date] is not null, 1, 0) as int) as s1) g1
cross apply (select cast(iif(g1.s1 = 1
                 and e.[Application Type] not in (
                     'Student', 'Scheme', 'Chartered Alternative Designation', 'Accreditation Application',
                     'Additional Role', 'Alternative Designation', 'Appeal', 'Apprenticeship',
                     'Complaint Report', 'Concession', 'Credential Application', 'Deceased',
                     'Deferral Application', 'Fixed Penalty Review', 'Mentor', 'Re-admission',
                     'Recognised Qualification', 'Removal', 'Resignation', 'Route Change', 'Fellowship'),
            1, 0) as int) as s2) g2
cross apply (select cast(iif(g2.s2 = 1
                 and isnull(rt.apuk_name, '') <> 'Registered Valuer Top Up', 1, 0) as int) as s3) g3
cross apply (select cast(case when e.[Application Type] = 'Recognised Professional Qualification'
                                or (e.[Application Type] = 'Assoc' and rt.apuk_name = 'Associate RPQ')
                              then 1 else 0 end as int) as is_rpq) g4;

create clustered index cx_enr on #enr (contact_no);

-- per-contact aggregate of the funnel
select
    contact_no,
    count(*)      as enr_rows,
    sum(r1)       as p1_after_date,
    sum(r2)       as p1_after_route,
    sum(r3)       as p1_after_apptype,
    sum(r4)       as p1_after_ended,
    sum(r5)       as p1_after_cooloff,
    sum(rv)       as p1_view_parity_rows,
    sum(s1)       as p2_after_election,
    sum(s2)       as p2_after_apptype,
    sum(s3)       as p2_after_route,
    -- qualifying ELECTION rows that carry an enrolment date of their own: these
    -- feed min(enrolment_date) unconditionally in v9, so they keep a contact on
    -- the Candidate path even when no part-1 row survives
    sum(iif(s3 = 1 and enrolment_date is not null, 1, 0)) as p2_rows_with_enrolment,
    -- v9: earliest enrolment date across ALL staged rows (part-1 rows AND
    -- enrolment dates riding on qualifying election rows)
    min(case when r5 = 1 or s3 = 1 then enrolment_date end) as p1_min_enrolment_date,
    min(case when s3 = 1 then election_date end)            as p2_min_election_date,
    -- the LATEST qualifying dates. v9 never reads these, which is precisely
    -- why they matter here: silv_member_base tests the contact lapse date
    -- against the EARLIEST enrolment/election, so a member who lapsed and
    -- then re-enrolled keeps their Lapse event whenever the first enrolment
    -- predates the lapse. max() vs min() is the whole of that divergence.
    max(case when r5 = 1 or s3 = 1 then enrolment_date end) as p1_max_enrolment_date,
    max(case when s3 = 1 then election_date end)            as p2_max_election_date
into #enr_agg
from #enr
group by contact_no;

create unique clustered index cx_enr_agg on #enr_agg (contact_no);

-- is_rpq from the row that supplied the earliest election date (v9 tie-break:
-- is_rpq desc, created datetime, ENR ID)
select
    a.contact_no,
    cast(el.is_rpq as bit) as p2_is_rpq
into #enr_rpq
from #enr_agg a
outer apply (
    select top (1) v.is_rpq
    from #enr v
    where v.contact_no  = a.contact_no
      and v.s3 = 1
      and v.election_date = a.p2_min_election_date
    order by v.is_rpq desc, v.created_dt, v.enr_id
) el
where a.p2_min_election_date is not null;

create unique clustered index cx_enr_rpq on #enr_rpq (contact_no);

-- the contact's FIRST PAID campaign year and the date the driver backdates a
-- later-recorded enrolment date to: the payment event's date in that year
-- (renewal_date_adj, else the cash date) clamped inside the campaign year,
-- the year start when neither is known. The SAME derivation as
-- usp_load_silv_member_base (#first_paid there) - keep the two in step.
select v.contact_no,
       v.campaign_year                     as first_paid_cy,
       case when d.d < cy.cy_start then cy.cy_start
            when d.d > cy.cy_end   then cy.cy_end
            else d.d end                   as join_date
into #first_paid
from (
    select p.contact_no, p.campaign_year, p.renewal_date_adj, p.payment_date,
           row_number() over (partition by p.contact_no order by p.campaign_year) as rn
    from Layercake.silv_payment_events p
    join #cohort_a k on k.contact_no = p.contact_no
) v
cross apply (select datefromparts(v.campaign_year - 1, 10, 1) as cy_start,
                    datefromparts(v.campaign_year,     9, 30) as cy_end) cy
cross apply (select cast(coalesce(v.renewal_date_adj, v.payment_date, cy.cy_start) as date) as d) d
where v.rn = 1;

create unique clustered index cx_first_paid on #first_paid (contact_no);

-- the FLOOR of the payment history - the driver's @pay_floor_cy: a recorded
-- date is only moved FORWARD to the first paid year where its own campaign
-- year is on or after this. Taken over ALL of silv_payment_events, NOT
-- #first_paid (which is cut down to this run's cohort), as the driver does.
declare @pay_floor_cy int = (select min(campaign_year) from Layercake.silv_payment_events);


/*--------------------------------------------------------------------
    3c. events, ranges, anomalies per contact.
        ev_country_unresolved matters because v9 step 5 INNER JOINs
        silv_ref_country when building ranges - an event with an
        unresolvable country_id produces no range at all, which would
        otherwise look like "step 5 is out of step".
--------------------------------------------------------------------*/
select
    e.contact_no,
    sum(iif(e.event_type = 'Join'  and e.event_subtype = 'Candidate', 1, 0)) as ev_join_candidate,
    sum(iif(e.event_type = 'Join'  and e.event_subtype = 'RPQ',       1, 0)) as ev_join_rpq,
    sum(iif(e.event_type = 'Change',                                  1, 0)) as ev_change,
    sum(iif(e.event_type = 'Lapse',                                   1, 0)) as ev_lapse,
    sum(iif(e.event_type = 'Readmission',                             1, 0)) as ev_readmission,
    count(*)                                                                 as ev_total,
    sum(iif(ctry.id is null, 1, 0))                                          as ev_country_unresolved,
    min(case when e.event_type = 'Lapse' then e.event_date end)              as ev_lapse_date
into #a_events
from Layercake.silv_membership_events e
join #cohort_a k on k.contact_no = e.contact_no
left join Layercake.silv_ref_country ctry on ctry.id = e.country_id
group by e.contact_no;

create unique clustered index cx_a_events on #a_events (contact_no);

select
    r.contact_no,
    count(*)            as rng_count,
    min(r.valid_from)   as rng_first_valid_from,
    max(r.valid_from)   as rng_last_valid_from
into #a_ranges
from Layercake.silv_member_state_ranges r
join #cohort_a k on k.contact_no = r.contact_no
group by r.contact_no;

create unique clustered index cx_a_ranges on #a_ranges (contact_no);

select
    a.contact_no,
    cast(stuff((select ', ' + x.anomaly_type
                from #anom x
                where x.contact_no = a.contact_no
                order by x.anomaly_type
                for xml path(''), type).value('.', 'nvarchar(400)'), 1, 2, '') as nvarchar(400)) as anomaly_types
into #a_anom
from (select distinct contact_no from #anom) a
join #cohort_a k on k.contact_no = a.contact_no;

create unique clustered index cx_a_anom on #a_anom (contact_no);


/*====================================================================
    4. WRITE THE ACTIVE RECONCILIATION
====================================================================*/
insert into Layercake.recon_active_contact
(
    run_id, contact_no,
    src_present, src_in_truth, src_contact_rows, src_member_grade, src_lapse_code, src_state_code,
    src_election_date, src_lapsed_date,
    brz_present, brz_is_deleted, brz_contact_rows, brz_member_grade, brz_lapsed_date,
    is_test_record, any_test_record, latest_rics_grade, is_student_grade,
    has_cust_trans, cust_trans_rows, mbase_eligible,
    rr_present, rr_lapse_code, rr_lapse_reason, rr_lapsed_date, rr_retirement_date,
    rr_lapse_code_no_date, rr_lapse_date_no_code, rr_lapse_date_not_on_contact,
    rr_grade_not_member, no_date_scenario,
    enr_rows, p1_after_date, p1_after_route, p1_after_apptype, p1_after_ended, p1_after_cooloff,
    p1_view_parity_rows, p1_min_enrolment_date, p1_max_enrolment_date,
    p2_after_election, p2_after_apptype, p2_after_route, p2_rows_with_enrolment,
    p2_min_election_date, p2_max_election_date, p2_is_rpq,
    exc_present, exc_enrolment_used, exc_election_used,
    eff_enrolment_date, eff_election_date, eff_lapsed_date, lapse_invalidated, predicted_join_branch,
    valid_enrolment_after_lapse, paid_src_current_cy, paid_pipe_current_cy, paid_but_lapsed,
    ev_join_candidate, ev_join_rpq, ev_change, ev_lapse, ev_readmission, ev_total, ev_country_unresolved,
    rng_count, rng_first_valid_from, rng_last_valid_from,
    rng_state_on_asof, rng_region_on_asof, rng_seq_on_asof, rng_covering_ranges, counted_active,
    anomaly_types, recon_status, fail_gate, gate_seq, fail_reason, fail_detail
)
select
    @run_id,
    k.contact_no,

    cast(iif(t.contact_no is not null, 1, 0) as bit),
    cast(isnull(t.in_truth, 0) as bit),
    t.src_contact_rows,
    t.src_member_grade,
    t.src_lapse_code,
    t.src_state_code,
    t.src_election_date,
    t.src_lapsed_date,

    b.brz_present, b.brz_is_deleted, b.brz_contact_rows, b.brz_member_grade, b.brz_lapsed_date,
    b.is_test_record, b.any_test_record, b.latest_rics_grade, b.is_student_grade,
    isnull(b.has_cust_trans, cast(0 as bit)), isnull(b.cust_trans_rows, 0),
    -- every silv_member_base driver exclusion in one flag: soft-deleted,
    -- test-flagged, Student grade (A25), no rics record at all (A26) and no
    -- transaction history at all (A27)
    cast(iif(b.brz_present = 1 and isnull(b.brz_is_deleted, 1) = 0
             and isnull(b.is_test_record, 0) = 0
             and isnull(b.is_student_grade, 0) = 0
             and isnull(b.rr_present, 0) = 1
             and isnull(b.has_cust_trans, 0) = 1, 1, 0) as bit),

    isnull(b.rr_present, cast(0 as bit)), b.rr_lapse_code, b.rr_lapse_reason,
    b.rr_lapsed_date, b.rr_retirement_date,
    isnull(b.rr_lapse_code_no_date, cast(0 as bit)),
    isnull(b.rr_lapse_date_no_code, cast(0 as bit)),
    isnull(b.rr_lapse_date_not_on_contact, cast(0 as bit)),
    isnull(b.rr_grade_not_member, cast(0 as bit)),
    b.no_date_scenario,

    isnull(g.enr_rows, 0),
    isnull(g.p1_after_date, 0), isnull(g.p1_after_route, 0), isnull(g.p1_after_apptype, 0),
    isnull(g.p1_after_ended, 0), isnull(g.p1_after_cooloff, 0), isnull(g.p1_view_parity_rows, 0),
    g.p1_min_enrolment_date, g.p1_max_enrolment_date,
    isnull(g.p2_after_election, 0), isnull(g.p2_after_apptype, 0), isnull(g.p2_after_route, 0),
    isnull(g.p2_rows_with_enrolment, 0),
    g.p2_min_election_date, g.p2_max_election_date,
    rp.p2_is_rpq,

    cast(iif(x.contact_no is not null, 1, 0) as bit),
    cast(iif(g.p1_min_enrolment_date is null and x.derived_enrolment_date is not null, 1, 0) as bit),
    cast(iif(g.p2_min_election_date  is null and x.derived_election_date  is not null, 1, 0) as bit),

    ef.eff_enrolment_date,
    ef.eff_election_date,
    -- silv_member_base stale-lapse invalidation, applied against the COALESCED dates
    lp.eff_lapsed_date,
    lp.lapse_invalidated,
    -- which branch of v9 step 4 this contact should take
    case when ef.eff_enrolment_date is not null                             then 'Join/Candidate'
         when ef.eff_election_date is not null and rp.p2_is_rpq = 1         then 'Join/RPQ'
         when ef.eff_election_date is not null                              then 'Change'
         else                                                                   'none'
    end,

    lp.valid_enrolment_after_lapse,
    cast(iif(tp.contact_no is not null, 1, 0) as bit),
    cast(iif(pp.contact_no is not null, 1, 0) as bit),
    cast(iif(sa.grade = 'lapse' and (tp.contact_no is not null or pp.contact_no is not null), 1, 0) as bit),

    isnull(ev.ev_join_candidate, 0), isnull(ev.ev_join_rpq, 0), isnull(ev.ev_change, 0),
    isnull(ev.ev_lapse, 0), isnull(ev.ev_readmission, 0), isnull(ev.ev_total, 0),
    isnull(ev.ev_country_unresolved, 0),

    isnull(rg.rng_count, 0), rg.rng_first_valid_from, rg.rng_last_valid_from,
    sa.grade, sa.region, sa.state_seq, sa.covering_ranges,
    cast(iif(pa.contact_no is not null, 1, 0) as bit),

    an.anomaly_types,

    /* ---- verdict ------------------------------------------------- */
    case when isnull(t.in_truth, 0) = 1 and pa.contact_no is not null then 'BOTH'
         when isnull(t.in_truth, 0) = 1                               then 'SOURCE_ONLY'
         else                                                              'PIPELINE_ONLY'
    end,

    /* ---- first failing gate -------------------------------------- */
    v.fail_gate, v.gate_seq, v.fail_reason, cast(left(v.fail_detail, 600) as nvarchar(600))

from #cohort_a k
left join #truth_active t  on t.contact_no  = k.contact_no
left join #a_bronze     b  on b.contact_no  = k.contact_no
left join #enr_agg      g  on g.contact_no  = k.contact_no
left join #enr_rpq      rp on rp.contact_no = k.contact_no
left join #exc          x  on x.contact_no  = k.contact_no
left join #a_events     ev on ev.contact_no = k.contact_no
left join #a_ranges     rg on rg.contact_no = k.contact_no
left join #a_anom       an on an.contact_no = k.contact_no
left join #state_asof   sa on sa.contact_no = k.contact_no
left join #pipe_active  pa on pa.contact_no = k.contact_no
-- the PAID side of the same as-of date, so a lapse state that contradicts a
-- payment can be named rather than left as a bare 'lapse'
left join #truth_paid   tp on tp.contact_no = k.contact_no
left join #pipe_paid    pp on pp.contact_no = k.contact_no
-- recorded dates after the 07 fallback coalesces in ...
cross apply (
    select coalesce(g.p1_min_enrolment_date, x.derived_enrolment_date) as rec_enrolment_date,
           coalesce(g.p2_min_election_date,  x.derived_election_date)  as rec_election_date
) rd
-- ... then the driver's subs-history date correction (gate A60 in the header):
-- the Join anchor - the enrolment date, or with NO enrolment date the election
-- date - moves to the first paid year's join_date where it was recorded in a
-- different campaign year: backdated from a LATER one, moved forward from an
-- EARLIER one that is inside the payment history (@pay_floor_cy). An election
-- the enrolment moved forward PAST is carried with it. The same case
-- expressions as usp_load_silv_member_base - keep the two in step.
left join #first_paid fp on fp.contact_no = k.contact_no
cross apply (
    select year(rd.rec_enrolment_date) + iif(month(rd.rec_enrolment_date) >= 10, 1, 0) as enr_cy,
           year(rd.rec_election_date)  + iif(month(rd.rec_election_date)  >= 10, 1, 0) as elec_cy
) rcy
cross apply (
    -- -1 = backdated, +1 = moved forward, 0 = as recorded
    select case when fp.first_paid_cy < rcy.enr_cy  then -1
                when fp.first_paid_cy > rcy.enr_cy  and rcy.enr_cy  >= @pay_floor_cy then 1
                else 0 end as enr_dir,
           case when rd.rec_enrolment_date is not null then 0
                when fp.first_paid_cy < rcy.elec_cy then -1
                when fp.first_paid_cy > rcy.elec_cy and rcy.elec_cy >= @pay_floor_cy then 1
                else 0 end as elec_anchor_dir
) dir
cross apply (
    select cast(iif(dir.enr_dir <> 0, 1, 0) as bit) as enrolment_moved,
           cast(iif(   dir.elec_anchor_dir <> 0
                    or (dir.enr_dir = 1 and rd.rec_election_date < fp.join_date), 1, 0) as bit) as election_moved
) bk
cross apply (
    select iif(bk.enrolment_moved = 1, fp.join_date, rd.rec_enrolment_date) as eff_enrolment_date,
           iif(bk.election_moved  = 1, fp.join_date, rd.rec_election_date)  as eff_election_date,
           -- for the narratives: which date moved (the anchor - a carried
           -- election rides on the enrolment's entry), from what, which way,
           -- and the anomaly type that reports it
           case when bk.enrolment_moved = 1 then N'enrolment'
                when bk.election_moved  = 1 then N'election' end                as backdated_kind,
           case when bk.enrolment_moved = 1 then rd.rec_enrolment_date
                when bk.election_moved  = 1 then rd.rec_election_date end       as backdated_from,
           iif(dir.enr_dir = 1 or dir.elec_anchor_dir = 1, N'MOVED FORWARD', N'BACKDATED') as moved_how,
           iif(dir.enr_dir = 1 or dir.elec_anchor_dir = 1, N'_BEFORE_FIRST_PAID', N'_AFTER_FIRST_PAID') as moved_suffix
) ef
-- the lapse verdict, computed once: what silv_member_base does with the lapse
-- date (invalidate it against the EARLIEST enrolment/election, or keep it),
-- and whether a LATER qualifying enrolment/election contradicts a kept lapse
cross apply (
    select
        iif(b.brz_lapsed_date < ef.eff_enrolment_date or b.brz_lapsed_date < ef.eff_election_date,
            null, b.brz_lapsed_date) as eff_lapsed_date,
        cast(iif(b.brz_lapsed_date is not null
                 and (b.brz_lapsed_date < ef.eff_enrolment_date
                   or b.brz_lapsed_date < ef.eff_election_date), 1, 0) as bit) as lapse_invalidated,
        cast(iif(b.brz_lapsed_date is not null
                 -- the lapse SURVIVED silv_member_base ...
                 and not (b.brz_lapsed_date < ef.eff_enrolment_date
                       or b.brz_lapsed_date < ef.eff_election_date)
                 -- ... yet a qualifying enrolment/election postdates it
                 and (g.p1_max_enrolment_date > b.brz_lapsed_date
                   or g.p2_max_election_date  > b.brz_lapsed_date), 1, 0) as bit) as valid_enrolment_after_lapse
) lp
-- the reason ladder. For a SOURCE_ONLY contact it is the FIRST gate that fails,
-- evaluated in gate order. For a PIPELINE_ONLY contact nothing failed, so it is
-- the most specific X-series MECHANISM that explains why the pipeline kept them.
outer apply (
    select top (1) z.fail_gate, z.gate_seq, z.fail_reason, z.fail_detail
    from (
        /* ---- PIPELINE_ONLY: the X-series. Not a gate walk - nothing was
               lost - so each code names the MECHANISM that let the pipeline
               keep a contact the truth query drops. Most specific first;
               ords 101+ so they never interleave with the gate ladder
               (they cannot co-fire: the gates all require in_truth = 1). --*/
        select 'X10' as fail_gate, 110 as gate_seq,
               cast('PIPELINE_ONLY_NOT_IN_CONTACT_SOURCE' as varchar(64)) as fail_reason,
               cast(N'Counted active by the pipeline but the contact number is not present on any CE.vwContact row - bronze is holding a contact source has dropped. Re-run 01; if it persists, the soft-delete sweep is not seeing the deletion.' as nvarchar(600)) as fail_detail,
               101 as ord
        where isnull(t.in_truth, 0) = 0 and t.contact_no is null

        /* X20/X21/X22 - the NO-DATE cohort. A lapse code says the contact is
           out, but there is no lapse date on the rics record OR the contact,
           and a state range needs a date. So the pipeline keeps counting them
           and neither today's number nor history can be corrected without an
           agreed convention. Deceased and Duplicate are called out separately
           because they are the two that matter operationally.              */
        union all
        select 'X20', 120, 'PIPELINE_ONLY_DECEASED_NO_LAPSE_DATE',
               cast(concat(N'Latest rics record carries lapse code 200000000 (',
                    isnull(b.rr_lapse_reason, N'Deceased'),
                    N') but there is NO lapse date - apuk_lapseddate and brnz_contact.Rics_LapsedDate are both null. The truth query drops them on Rics_LapsedCode; the pipeline has no date to close a state range on, so it keeps counting them active and cannot restate history either. NO HANDLING RULE YET (see RS-14).') as nvarchar(600)), 102
        where isnull(t.in_truth, 0) = 0
          and isnull(b.rr_lapse_code_no_date, 0) = 1 and b.rr_lapse_code = 200000000

        union all
        select 'X21', 121, 'PIPELINE_ONLY_DUPLICATE_NO_LAPSE_DATE',
               cast(concat(N'Latest rics record carries lapse code 200000001 (',
                    isnull(b.rr_lapse_reason, N'Duplicate'),
                    N') but there is NO lapse date - apuk_lapseddate and brnz_contact.Rics_LapsedDate are both null. A duplicate is not a member exit at all: the contact should be merged, not lapsed, so counting them active double-counts one person. NO HANDLING RULE YET (see RS-14).') as nvarchar(600)), 103
        where isnull(t.in_truth, 0) = 0
          and isnull(b.rr_lapse_code_no_date, 0) = 1 and b.rr_lapse_code = 200000001

        union all
        select 'X22', 122, 'PIPELINE_ONLY_LAPSE_CODE_NO_LAPSE_DATE',
               cast(concat(N'Latest rics record carries lapse code ', b.rr_lapse_code,
                    N' (', isnull(b.rr_lapse_reason, N'not in the option set'),
                    N') but there is NO lapse date on the rics record or the contact, so no Lapse event can be dated and the pipeline keeps counting them active. NO HANDLING RULE YET (see RS-14).') as nvarchar(600)), 104
        where isnull(t.in_truth, 0) = 0 and isnull(b.rr_lapse_code_no_date, 0) = 1

        union all
        select 'X30', 130, 'PIPELINE_ONLY_LAPSE_DATE_ONLY_ON_RICS_RECORD',
               cast(concat(N'brnz_rics_record.apuk_lapseddate = ',
                    convert(nvarchar(10), b.rr_lapsed_date, 23),
                    N' but brnz_contact.Rics_LapsedDate is null. silv_member_base takes the Lapse event date from the CONTACT only - it reads apuk_lapsecode for the reason NAME and never reads apuk_lapseddate - so this date is invisible to the derivation and no Lapse event is emitted. Fixable in silver: coalesce the rics-record date in, or agree that the contact date is authoritative.') as nvarchar(600)), 105
        where isnull(t.in_truth, 0) = 0 and isnull(b.rr_lapse_date_not_on_contact, 0) = 1

        union all
        select 'X40', 140, 'PIPELINE_ONLY_STALE_LAPSE_IGNORED',
               cast(concat(N'brnz_contact.Rics_LapsedDate = ',
                    convert(nvarchar(10), b.brz_lapsed_date, 23),
                    N' predates the derived enrolment/election (',
                    isnull(convert(nvarchar(10), ef.eff_enrolment_date, 23), N'no enrolment'), N' / ',
                    isnull(convert(nvarchar(10), ef.eff_election_date, 23), N'no election'),
                    N'), so the stale-lapse rule invalidated it and no Lapse event was emitted. On a true readmission CE clears the lapse date, so a surviving one is a source mismatch - already logged as STALE_LAPSE_IGNORED in silv_data_anomaly.',
                    iif(ef.backdated_kind is not null,
                        concat(N' NOTE the ', ef.backdated_kind, N' date is the ', ef.moved_how, N' one (recorded ',
                               convert(nvarchar(10), ef.backdated_from, 23),
                               N', moved to the first paid campaign year - ', upper(ef.backdated_kind), ef.moved_suffix, N').'),
                        N'')) as nvarchar(600)), 106
        where isnull(t.in_truth, 0) = 0 and lp.lapse_invalidated = 1

        union all
        select 'X50', 150, 'PIPELINE_ONLY_NO_RICS_RECORD',
               cast(N'No row in brnz_rics_record for this membership number at all, so there is no grade, lapse code or retirement date to test. EXPECTED TO BE ZERO: gate A26 now excludes these contacts from the silv_member_base driver and the payment-derived Readmission applies the same test, so they cannot be counted active. A row here means A26 is not deployed (re-run 02 after deploying phase 04) or the Readmission guard has been bypassed.' as nvarchar(600)), 107
        where isnull(t.in_truth, 0) = 0 and isnull(b.rr_present, 0) = 0

        union all
        select 'X55', 155, 'PIPELINE_ONLY_NO_TRANSACTION_HISTORY',
               cast(N'No rows in brnz_cust_trans for this membership number at all, so the contact has never transacted. EXPECTED TO BE ZERO: gate A27 now excludes these contacts from the silv_member_base driver and the payment-derived Readmission applies the same test, so they cannot be counted active. A row here means A27 is not deployed (re-run 02 after deploying phase 04) or the Readmission guard has been bypassed.' as nvarchar(600)), 108
        where isnull(t.in_truth, 0) = 0 and isnull(b.has_cust_trans, 0) = 0

        union all
        select 'X60', 160, 'PIPELINE_ONLY_RICS_GRADE_NOT_MEMBER',
               cast(concat(N'Latest rics record grade is ',
                    isnull(cast(b.latest_rics_grade as nvarchar(20)), N'(null)'),
                    N', not one of 200000000 Candidate / 200000001 Qualified Professional / 200000002 Qualified Professional - 2 Years. Source member grade on the contact is ',
                    isnull(t.src_member_grade, N'(null)'),
                    N'. The silv_member_base driver excludes the Student grade (200000003) and contacts with no rics record at all, so every other non-member grade on a record that EXISTS still produces events and a state range.') as nvarchar(600)), 109
        where isnull(t.in_truth, 0) = 0 and isnull(b.rr_grade_not_member, 0) = 1

        union all
        select 'X70', 170, 'PIPELINE_ONLY_READMISSION_DERIVED_ONLY',
               cast(N'This contact holds ONLY payment-derived Readmission events - no Join, Change or Lapse. v9 builds a state range from a Readmission with no silv_member_base basis at all, so a payment alone puts them into the active count.' as nvarchar(600)), 110
        where isnull(t.in_truth, 0) = 0
          and isnull(ev.ev_total, 0) > 0
          and isnull(ev.ev_join_candidate, 0) + isnull(ev.ev_join_rpq, 0) + isnull(ev.ev_change, 0) = 0
          and isnull(ev.ev_readmission, 0) > 0

        union all
        select 'X99', 199, 'PIPELINE_ONLY_NOT_IN_SOURCE_LIST',
               cast(concat(N'Counted active by the pipeline but excluded by the truth query: ',
                    case when t.src_member_grade is null then N'member grade is null'
                         when t.src_member_grade not in ('Candidate', 'Qualified Professional', 'Qualified Professional - 2 Years')
                              then concat(N'member grade = ', t.src_member_grade)
                         when t.src_lapse_code is not null then concat(N'Rics_LapsedCode = ', t.src_lapse_code)
                         when t.src_state_code <> 0 then concat(N'StateCode = ', t.src_state_code)
                         else N'reason not determined' end,
                    N'. No rics-record mechanism above explains it - neither Rics_LapsedCode nor StateCode is landed in bronze, so the pipeline cannot see either filter.') as nvarchar(600)), 111
        where isnull(t.in_truth, 0) = 0

        union all
        select 'A99', 99, 'COUNTED', null, 2
        where isnull(t.in_truth, 0) = 1 and pa.contact_no is not null

        /* ---- SOURCE_ONLY: walk the gates in order ------------------ */
        union all
        select 'A10', 10, 'BRONZE_CONTACT_MISSING',
               N'No row in Layercake.brnz_contact for this contact number - bronze has not landed it (re-run 01, or intra-day source drift)', 3
        where isnull(t.in_truth, 0) = 1 and pa.contact_no is null and isnull(b.brz_present, 0) = 0

        union all
        select 'A10', 11, 'BRONZE_CONTACT_SOFT_DELETED',
               N'Every brnz_contact row for this contact number has _is_deleted = 1 - it has disappeared from CE.vwContact since the last bronze load', 4
        where isnull(t.in_truth, 0) = 1 and pa.contact_no is null
          and isnull(b.brz_present, 0) = 1 and isnull(b.brz_is_deleted, 0) = 1

        union all
        select 'A20', 20, 'EXCLUDED_TEST_RECORD',
               N'Every active bronze contact row for this number is on ce.tblcontact_test_records, so silver produces no events', 5
        where isnull(t.in_truth, 0) = 1 and pa.contact_no is null and isnull(b.is_test_record, 0) = 1

        union all
        select 'A25', 25, 'EXCLUDED_STUDENT_GRADE',
               concat(N'Latest rics record carries member grade 200000003 (Student) - excluded from the silv_member_base driver per Rules to note #2, and not overridden (no ended Student application superseded by a qualifying row - vw_student_superseded). Source grade on the contact is ',
                      isnull(t.src_member_grade, N'(null)')), 6
        where isnull(t.in_truth, 0) = 1 and pa.contact_no is null and isnull(b.is_student_grade, 0) = 1

        union all
        select 'A26', 26, 'EXCLUDED_NO_RICS_RECORD',
               concat(N'No row in brnz_rics_record for this membership number, so there is no grade, lapse code or retirement date behind the contact. The silv_member_base driver requires one, so no events, no state range and no active count - and the payment-derived Readmission applies the same test, so a payment cannot bring them back either. Source grade on the contact is ',
                      isnull(t.src_member_grade, N'(null)'),
                      N'. Logged as NO_RICS_RECORD in silv_data_anomaly for feedback to the client.'), 7
        where isnull(t.in_truth, 0) = 1 and pa.contact_no is null and isnull(b.rr_present, 0) = 0

        union all
        select 'A27', 27, 'EXCLUDED_NO_TRANSACTION_HISTORY',
               concat(N'No rows in brnz_cust_trans for this membership number - the contact has never transacted, so it is not a valid contact. The silv_member_base driver requires at least one row: no events, no state range, no active count, and no PAID count either (the paid number joins the same state ranges). The Readmission applies the same test, so an invoice position alone cannot bring them back. Source grade is ',
                      isnull(t.src_member_grade, N'(null)'),
                      N'. Logged as NO_TRANSACTIONS in silv_data_anomaly where a valid enrolment or election exists.'), 8
        where isnull(t.in_truth, 0) = 1 and pa.contact_no is null and isnull(b.has_cust_trans, 0) = 0

        union all
        select 'A30', 30, 'NO_ENROLMENT_ROWS_AT_ALL',
               N'No rows in brnz_enrolment for this contact and no 07 exception backfill - the migration-gap cohort (Known enrolment issues #1)', 9
        where isnull(t.in_truth, 0) = 1 and pa.contact_no is null
          and isnull(g.enr_rows, 0) = 0 and ef.eff_enrolment_date is null and ef.eff_election_date is null

        /* A40/A50 are ONE decision: rows exist but nothing survives. The
           reason names whichever side got furthest, so an election-side
           loss is never reported as an enrolment-side rule.            */
        union all
        select
            case when isnull(g.p2_after_election, 0) > 0 then 'A50' else 'A40' end,
            case when isnull(g.p2_after_election, 0) > 0 then 50 else 40 end,
            case when isnull(g.p2_after_election, 0) > 0 and isnull(g.p2_after_apptype, 0) = 0
                      then 'ELECTION_APPLICATION_TYPE_EXCLUDED'
                 when isnull(g.p2_after_election, 0) > 0 and isnull(g.p2_after_route, 0) = 0
                      then 'ELECTION_ROUTE_RV_TOPUP'
                 when isnull(g.p1_after_date, 0) = 0     then 'NO_ENROLMENT_OR_ELECTION_DATE'
                 when isnull(g.p1_after_route, 0) = 0    then 'ROUTE_NOT_IN_ALLOWLIST'
                 when isnull(g.p1_after_apptype, 0) = 0  then 'APPLICATION_TYPE_EXCLUDED_OR_NULL'
                 when isnull(g.p1_after_ended, 0) = 0    then 'ENDED_WITHOUT_ELECTION'
                 else                                         'COOLOFF_14_DAY_CANCELLATION'
            end,
            concat(N'No enrolment or election row survives. Part 1 (enrolment): ', isnull(g.enr_rows, 0),
                   N' rows -> date ', isnull(g.p1_after_date, 0),
                   N' -> route ', isnull(g.p1_after_route, 0),
                   N' -> app type ', isnull(g.p1_after_apptype, 0),
                   N' -> ended ', isnull(g.p1_after_ended, 0),
                   N' -> cool-off ', isnull(g.p1_after_cooloff, 0),
                   N'.  Part 2 (election): election date ', isnull(g.p2_after_election, 0),
                   N' -> app type ', isnull(g.p2_after_apptype, 0),
                   N' -> route ', isnull(g.p2_after_route, 0),
                   N'.  No 07 fallback either.'), 10
        where isnull(t.in_truth, 0) = 1 and pa.contact_no is null
          and isnull(g.enr_rows, 0) > 0
          and ef.eff_enrolment_date is null and ef.eff_election_date is null

        union all
        select 'A70', 70, 'NO_EVENTS_DESPITE_DATES',
               N'Effective dates exist but silv_membership_events holds no Join, Change or Readmission for this contact - silver is out of step with bronze, re-run 02', 11
        where isnull(t.in_truth, 0) = 1 and pa.contact_no is null
          and (ef.eff_enrolment_date is not null or ef.eff_election_date is not null)
          and isnull(ev.ev_join_candidate, 0) + isnull(ev.ev_join_rpq, 0)
              + isnull(ev.ev_change, 0) + isnull(ev.ev_readmission, 0) = 0

        union all
        select 'A80', 80,
               iif(isnull(ev.ev_country_unresolved, 0) > 0, 'RANGES_LOST_UNRESOLVED_COUNTRY', 'NO_STATE_RANGES'),
               iif(isnull(ev.ev_country_unresolved, 0) > 0,
                   concat(N'Events exist but ', ev.ev_country_unresolved,
                          N' of them carry a country_id that does not resolve in silv_ref_country. Step 5 INNER JOINs that reference table, so those events build no state range at all - fix the country reference, not the range derivation.'),
                   N'Events exist but silv_member_state_ranges holds nothing for this contact - step 5 is out of step, re-run 02'), 12
        where isnull(t.in_truth, 0) = 1 and pa.contact_no is null and isnull(rg.rng_count, 0) = 0

        /* A90 splits three ways. A covering 'lapse' state is only the headline
           when nothing else on the contact contradicts it outright - a later
           qualifying enrolment, or a payment for the current campaign year,
           each say the member is IN on a date the pipeline says they are out,
           and each has a different fix. Both are also carried as flags
           (valid_enrolment_after_lapse, paid_but_lapsed) so RS-11 can size
           them independently of which one won the ladder.                  */
        union all
        select 'A90', 90, 'LAPSED_DESPITE_LATER_ENROLMENT',
               concat(N'The state covering ', convert(nvarchar(10), @asof, 23),
                      N' is ''lapse'' (lapse date ',
                      isnull(convert(nvarchar(10), b.brz_lapsed_date, 23), N'(null)'),
                      N') but a qualifying enrolment/election POSTDATES it - latest enrolment ',
                      isnull(convert(nvarchar(10), g.p1_max_enrolment_date, 23), N'(none)'),
                      N', latest election ', isnull(convert(nvarchar(10), g.p2_max_election_date, 23), N'(none)'),
                      N'. silv_member_base tests the lapse date against the EARLIEST enrolment/election (',
                      isnull(convert(nvarchar(10), ef.eff_enrolment_date, 23), N'none'), N' / ',
                      isnull(convert(nvarchar(10), ef.eff_election_date, 23), N'none'),
                      N'), so the stale-lapse rule does not fire and the Lapse event stands. The member re-enrolled after lapsing and the old lapse date was never cleared from the contact record.',
                      iif(ef.backdated_kind is not null,
                          concat(N' The earliest ', ef.backdated_kind, N' here is the ', ef.moved_how, N' one (recorded ',
                                 convert(nvarchar(10), ef.backdated_from, 23),
                                 N', moved to the first paid campaign year - ', upper(ef.backdated_kind), ef.moved_suffix,
                                 iif(ef.moved_how = N'BACKDATED',
                                     N'): the subs history shows the member paying before the lapse, so the lapse is real and a later payment re-opens the range as a Readmission.',
                                     N'): the lapse postdates the first paid year, so it stands against the moved date as well.')),
                          N'')), 13
        where isnull(t.in_truth, 0) = 1 and pa.contact_no is null and sa.grade = 'lapse'
          and lp.valid_enrolment_after_lapse = 1

        union all
        select 'A90', 91, 'LAPSED_DESPITE_PAYMENT_THIS_CY',
               concat(N'The state covering ', convert(nvarchar(10), @asof, 23),
                      N' is ''lapse'' (lapse date ',
                      isnull(convert(nvarchar(10), b.brz_lapsed_date, 23), N'(null)'),
                      N') but the contact has PAID for CY', @current_cy,
                      N' - source invoice position ', isnull(tp.src_invoice_position, N'(not in the source paid list)'),
                      N', pipeline paid = ', iif(pp.contact_no is not null, N'yes', N'no'),
                      N'. A payment is an assertion of membership on that date, so the lapse date on the contact record is stale. The paid count is unaffected (it joins state ranges of ANY grade, lapse included) - only the ACTIVE count loses them.'), 14
        where isnull(t.in_truth, 0) = 1 and pa.contact_no is null and sa.grade = 'lapse'
          and (tp.contact_no is not null or pp.contact_no is not null)

        union all
        select 'A90', 92, 'LAPSED_IN_PIPELINE_NOT_IN_SOURCE',
               concat(N'The state covering ', convert(nvarchar(10), @asof, 23),
                      N' is ''lapse'' (lapse event ', convert(nvarchar(10), ev.ev_lapse_date, 23),
                      N'), but the source contact has Rics_LapsedCode null so the truth query counts them. ',
                      N'brnz_contact.Rics_LapsedDate = ', isnull(convert(nvarchar(10), b.brz_lapsed_date, 23), N'(null)'),
                      N'. Note bronze does not land Rics_LapsedCode at all, so the two definitions cannot agree by construction.'), 15
        where isnull(t.in_truth, 0) = 1 and pa.contact_no is null and sa.grade = 'lapse'

        union all
        select 'A85', 85, 'NO_RANGE_COVERS_ASOF',
               concat(N'Ranges exist (', isnull(rg.rng_count, 0), N') but none covers ',
                      convert(nvarchar(10), @asof, 23),
                      N'. Earliest range starts ', isnull(convert(nvarchar(10), rg.rng_first_valid_from, 23), N'(null)'),
                      N', latest starts ', isnull(convert(nvarchar(10), rg.rng_last_valid_from, 23), N'(null)'),
                      N' - a future-dated enrolment/election, or every range is zero-length.'), 16
        where isnull(t.in_truth, 0) = 1 and pa.contact_no is null and sa.contact_no is null

        union all
        select 'A99', 98, 'UNEXPLAINED_INVESTIGATE',
               N'In the truth list, not counted by the pipeline, and no gate above fired - investigate', 99
        where isnull(t.in_truth, 0) = 1 and pa.contact_no is null
    ) z
    order by z.ord
) v;


/*====================================================================
    5. PAID COHORT + reconciliation
====================================================================*/
select contact_no
into #cohort_p
from (
    select contact_no from #truth_paid
    union
    select contact_no from #pipe_paid
) v;

create unique clustered index cx_cohort_p on #cohort_p (contact_no);

-- range counts for the paid cohort only (the full table is large)
select r.contact_no, count(*) as rng_count
into #p_ranges
from Layercake.silv_member_state_ranges r
join #cohort_p k on k.contact_no = r.contact_no
group by r.contact_no;

create unique clustered index cx_p_ranges on #p_ranges (contact_no);

insert into Layercake.recon_paid_contact
(
    run_id, contact_no, campaign_year,
    src_present, src_in_truth, src_rows_all, src_paid_rows,
    src_invoice_position, src_dedupe_winner_position, src_renewal_date, src_renewal_date_adj,
    brz_present, brz_is_deleted, brz_invoice_position, brz_renewal_date_adj,
    pay_present, pay_invoice_position, pay_payment_date, pay_renewal_date_adj,
    renewal_adj_is_null, renewal_adj_after_asof,
    has_cust_trans, has_range_on_asof, rng_state_on_asof, rng_count,
    counted_paid, recon_status, fail_gate, gate_seq, fail_reason, fail_detail
)
select
    @run_id,
    k.contact_no,
    @current_cy,

    cast(iif(t.contact_no is not null, 1, 0) as bit),
    cast(iif(t.contact_no is not null, 1, 0) as bit),
    t.src_rows_all, t.src_paid_rows,
    t.src_invoice_position, t.src_dedupe_winner_position, t.src_renewal_date, t.src_renewal_date_adj,

    cast(iif(b.[Contact No.] is not null, 1, 0) as bit),
    cast(b._is_deleted as bit),
    b.[Member Invoice Position],
    cast(b.[Renewal Date Adj] as date),

    cast(iif(p.contact_no is not null, 1, 0) as bit),
    p.invoice_position,
    cast(p.payment_date as date),
    cast(p.renewal_date_adj as date),

    cast(iif(p.contact_no is not null and p.renewal_date_adj is null, 1, 0) as bit),
    cast(iif(p.renewal_date_adj > @asof, 1, 0) as bit),

    cast(iif(ct.trans_rows > 0, 1, 0) as bit),
    cast(iif(sa.contact_no is not null, 1, 0) as bit),
    sa.grade,
    isnull(rg.rng_count, 0),

    cast(iif(pp.contact_no is not null, 1, 0) as bit),

    case when t.contact_no is not null and pp.contact_no is not null then 'BOTH'
         when t.contact_no is not null                               then 'SOURCE_ONLY'
         else                                                             'PIPELINE_ONLY'
    end,

    v.fail_gate, v.gate_seq, v.fail_reason, cast(left(v.fail_detail, 600) as nvarchar(600))

from #cohort_p k
left join #truth_paid t on t.contact_no = k.contact_no and t.campaign_year = @current_cy
left join Layercake.brnz_subs_status b
       on b.[Contact No.] = k.contact_no and b.[Campaign Year] = @current_cy
left join Layercake.silv_payment_events p
       on p.contact_no = k.contact_no and p.campaign_year = @current_cy
left join #state_asof sa on sa.contact_no = k.contact_no
left join #p_ranges   rg on rg.contact_no = k.contact_no
left join #pipe_paid  pp on pp.contact_no = k.contact_no
-- gate A27 on the paid side: a paid invoice position says nothing about cash,
-- so a contact can be paid on paper and have no brnz_cust_trans row at all
outer apply (
    select count(*) as trans_rows
    from Layercake.brnz_cust_trans t
    where t.accountnum  = k.contact_no
      and t._is_deleted = 0
) ct
outer apply (
    select top (1) z.fail_gate, z.gate_seq, z.fail_reason, z.fail_detail
    from (
        select 'P99' as fail_gate, 99 as gate_seq, 'PIPELINE_ONLY_NOT_IN_SOURCE_LIST' as fail_reason,
               cast(concat(N'Counted paid by the pipeline but not in the source paid list for CY', @current_cy,
                    N': ', case when b.[Contact No.] is null then N'no brnz_subs_status row for this CY'
                               when b._is_deleted = 1 then N'bronze row soft-deleted'
                               else concat(N'bronze invoice position = ', isnull(b.[Member Invoice Position], N'(null)')) end,
                    N'. Silver still holds a payment event, so silv_payment_events is stale - re-run 02.') as nvarchar(600)) as fail_detail,
               1 as ord
        where t.contact_no is null

        union all
        select 'P99', 99, 'COUNTED', null, 2
        where t.contact_no is not null and pp.contact_no is not null

        union all
        select 'P10', 10, 'BRONZE_SUBS_ROW_MISSING',
               N'No row in Layercake.brnz_subs_status for this contact + campaign year - bronze has not landed it (re-run 01, or intra-day source drift)', 3
        where t.contact_no is not null and pp.contact_no is null and b.[Contact No.] is null

        union all
        select 'P10', 11, 'BRONZE_SUBS_ROW_SOFT_DELETED',
               N'brnz_subs_status._is_deleted = 1 - the subs row has disappeared from the source view since the last bronze load', 4
        where t.contact_no is not null and pp.contact_no is null and b._is_deleted = 1

        /* P20 - the dedupe eviction. Bronze keeps ONE row per (contact,
           campaign year), ordered by [Renewal Date Adj] desc then
           [Renewal Date] desc, and it does that BEFORE any invoice-position
           filter. A later non-paid row therefore evicts the paid row and the
           contact never reaches silver. Re-running 02 cannot fix this.     */
        union all
        select 'P20', 20, 'PAID_ROW_EVICTED_BY_BRONZE_DEDUPE',
               concat(N'The source has ', t.src_paid_rows, N' paid row(s) for this contact in CY', @current_cy,
                      N' (position ', isnull(t.src_invoice_position, N'(null)'),
                      N'), but bronze''s (contact, campaign year) dedupe keeps the row with the latest [Renewal Date Adj], which is ',
                      isnull(t.src_dedupe_winner_position, N'(null)'),
                      N' - a non-paid position. The paid row is discarded in BRONZE, so silver never sees it and re-running 02 will not help. Fix the bronze dedupe rule (01, brnz_subs_status) or the source data.'), 5
        where t.contact_no is not null and pp.contact_no is null and t.winner_is_paid = 0

        union all
        select 'P30', 30, 'NO_PAYMENT_EVENT',
               concat(N'Bronze holds the row (invoice position ', isnull(b.[Member Invoice Position], N'(null)'),
                      N') but silv_payment_events has nothing for CY', @current_cy,
                      N' - silver is out of step, re-run 02.'), 6
        where t.contact_no is not null and pp.contact_no is null and p.contact_no is null

        union all
        select 'P40', 40, 'RENEWAL_DATE_ADJ_NULL',
               N'Payment event exists but renewal_date_adj is null. The day-by-day paid rule is renewal_date_adj <= date, and null never satisfies it - this contact can never be counted paid on any date.', 7
        where t.contact_no is not null and pp.contact_no is null and p.renewal_date_adj is null

        union all
        select 'P50', 50, 'RENEWAL_DATE_ADJ_AFTER_ASOF',
               concat(N'renewal_date_adj = ', convert(nvarchar(10), p.renewal_date_adj, 23),
                      N' is later than ', convert(nvarchar(10), @asof, 23),
                      N' - paid in the source snapshot, not yet paid on a day-by-day basis.'), 8
        where t.contact_no is not null and pp.contact_no is null and p.renewal_date_adj > @asof

        /* P60 splits two ways. The generic form is "no covering range";
           where the cause is the A27 transaction gate it is a deliberate
           rule, not a gap, so it is named separately.                    */
        union all
        select 'P60', 60, 'NO_TRANSACTION_HISTORY',
               concat(N'Paid in the source snapshot (invoice position ',
                      isnull(t.src_invoice_position, N'(null)'),
                      N') but there are NO rows in brnz_cust_trans for this membership number - the contact has never transacted in cash. Gate A27 removes them from silv_member_base, so they hold no state range and the paid count, which joins the same ranges, cannot include them. Deliberate: an invoice position alone is not evidence of a valid contact.'), 9
        where t.contact_no is not null and pp.contact_no is null
          and sa.contact_no is null and ct.trans_rows = 0

        union all
        select 'P60', 61, 'NO_STATE_RANGE_COVERS_ASOF',
               concat(N'Paid, but the contact has ',
                      iif(isnull(rg.rng_count, 0) = 0, N'NO state ranges at all',
                          concat(N'no state range covering ', convert(nvarchar(10), @asof, 23),
                                 N' (', rg.rng_count, N' range(s) exist)')),
                      N'. The daily paid count is derived from the SAME range join as the active count, so a paid contact with no covering range is silently dropped from the paid number.'), 10
        where t.contact_no is not null and pp.contact_no is null and sa.contact_no is null

        union all
        select 'P99', 98, 'UNEXPLAINED_INVESTIGATE',
               N'In the source paid list, not counted by the pipeline, and no gate above fired - investigate', 99
        where t.contact_no is not null and pp.contact_no is null
    ) z
    order by z.ord
) v;


/*====================================================================
    6. Finish the run header
====================================================================*/
update Layercake.recon_run
set asof_marked_loaded   = @asof_marked_loaded,
    src_active_rows      = @src_active_rows,
    src_active_contacts  = @src_active_contacts,
    pipe_active_contacts = @pipe_active_contacts,
    active_in_both       = (select count(*) from Layercake.recon_active_contact where run_id = @run_id and recon_status = 'BOTH'),
    active_source_only   = (select count(*) from Layercake.recon_active_contact where run_id = @run_id and recon_status = 'SOURCE_ONLY'),
    active_pipeline_only = (select count(*) from Layercake.recon_active_contact where run_id = @run_id and recon_status = 'PIPELINE_ONLY'),
    src_paid_rows        = @src_paid_rows,
    src_paid_contacts    = @src_paid_contacts,
    pipe_paid_contacts   = @pipe_paid_contacts,
    paid_in_both         = (select count(*) from Layercake.recon_paid_contact where run_id = @run_id and recon_status = 'BOTH'),
    paid_source_only     = (select count(*) from Layercake.recon_paid_contact where run_id = @run_id and recon_status = 'SOURCE_ONLY'),
    paid_pipeline_only   = (select count(*) from Layercake.recon_paid_contact where run_id = @run_id and recon_status = 'PIPELINE_ONLY')
where run_id = @run_id;


/*====================================================================
    REPORT SETS
====================================================================*/

/*-------------------------------------------------------- RS-0 ------*/
declare @stored_active bigint = (select isnull(sum(active_count), 0) from Layercake.silv_daily_count where [date] = @asof);
declare @stored_paid   bigint = (select isnull(sum(paid_count),   0) from Layercake.silv_daily_count where [date] = @asof);
declare @asof_has_rows bit    = iif(exists (select 1 from Layercake.silv_daily_count where [date] = @asof), 1, 0);

select
    '[RS-0] run info'  as [rs],
    @run_id            as run_id,
    sysdatetime()      as run_at,
    @asof              as asof_date,
    iif(@asof = @today, 'yes',
        'NO - the SOURCE side of this comparison is a current-state view with no as-of dimension, so every reason code below is against TODAY''S source') as asof_is_today,
    @current_cy        as campaign_year,
    @silver_asof       as silv_daily_count_max_date,
    case when @has_dcl = 0 then 'unknown - v9 load tracking not deployed'
         when @asof = @today then 'n/a - v9 never marks the current day (it is rebuilt every run)'
         when @asof_marked_loaded = 1 then 'yes - this date is FINAL under v9; a difference in RS-9 is expected drift, not a bug'
         else 'NO - this date has never been loaded by silver'
    end                as asof_load_state,
    @has_exc           as exception_table_present,
    @has_anom          as anomaly_log_present,
    (select count(*) from #dc_pending) as open_pending_rebuilds,
    @src_active_rows   as src_active_rows,
    @src_active_nulls  as src_active_rows_with_null_contact_no,
    @src_dup_contact_nos as contact_numbers_shared_by_2plus_contacts,
    @src_paid_rows     as src_paid_rows,
    @src_paid_nulls    as src_paid_rows_with_null_contact_no,
    @src_paid_dupes    as src_paid_duplicate_rows_collapsed,
    @src_paid_evicted  as src_paid_rows_evicted_by_bronze_dedupe;

/*-------------------------------------------------------- RS-1 ------*/
-- ACTIVE gate coverage. NOT a strict funnel: a contact can miss an early gate
-- and still be counted (a payment-derived Readmission needs no enrolment row),
-- so read the deltas as indicative.
select '[RS-1] ACTIVE gate coverage (see note - not strictly nested)' as [rs],
       v.step_no, v.step, v.contacts,
       v.contacts - lag(v.contacts) over (order by v.step_no) as change_vs_previous
from (
    select 0 as step_no, 'Source truth rows (agreed query, as written)' as step, @src_active_rows as contacts
    union all select 1, '...of which carry a contact number', @src_active_contacts
    union all select 10, 'A10 present in brnz_contact with at least one active row',
        (select count(*) from Layercake.recon_active_contact where run_id = @run_id and src_in_truth = 1
           and brz_present = 1 and isnull(brz_is_deleted, 1) = 0)
    union all select 20, 'A20 not test-flagged on every active row',
        (select count(*) from Layercake.recon_active_contact where run_id = @run_id and src_in_truth = 1
           and brz_present = 1 and isnull(brz_is_deleted, 1) = 0 and isnull(is_test_record, 0) = 0)
    union all select 25, 'A25 not Student grade (200000003), or Student superseded',
        (select count(*) from Layercake.recon_active_contact where run_id = @run_id and src_in_truth = 1
           and brz_present = 1 and isnull(brz_is_deleted, 1) = 0 and isnull(is_test_record, 0) = 0
           and isnull(is_student_grade, 0) = 0)
    union all select 26, 'A26 has a brnz_rics_record row',
        (select count(*) from Layercake.recon_active_contact where run_id = @run_id and src_in_truth = 1
           and brz_present = 1 and isnull(brz_is_deleted, 1) = 0 and isnull(is_test_record, 0) = 0
           and isnull(is_student_grade, 0) = 0 and rr_present = 1)
    union all select 27, 'A27 has a brnz_cust_trans row - i.e. silv_member_base eligible',
        (select count(*) from Layercake.recon_active_contact where run_id = @run_id and src_in_truth = 1
           and mbase_eligible = 1)
    union all select 30, 'A30 has at least one brnz_enrolment row',
        (select count(*) from Layercake.recon_active_contact where run_id = @run_id and src_in_truth = 1
           and mbase_eligible = 1 and enr_rows > 0)
    union all select 40, 'A40 has a qualifying ENROLMENT row (valid-enrolment rules)',
        (select count(*) from Layercake.recon_active_contact where run_id = @run_id and src_in_truth = 1
           and mbase_eligible = 1 and p1_after_cooloff > 0)
    union all select 50, 'A50 has a qualifying ELECTION row',
        (select count(*) from Layercake.recon_active_contact where run_id = @run_id and src_in_truth = 1
           and mbase_eligible = 1 and p2_after_route > 0)
    union all select 55, 'A40/A50 has EITHER (before the 07 fallback)',
        (select count(*) from Layercake.recon_active_contact where run_id = @run_id and src_in_truth = 1
           and mbase_eligible = 1 and (p1_after_cooloff > 0 or p2_after_route > 0))
    union all select 60, 'A60 has an effective date AFTER the 07 exception fallback',
        (select count(*) from Layercake.recon_active_contact where run_id = @run_id and src_in_truth = 1
           and (eff_enrolment_date is not null or eff_election_date is not null))
    union all select 70, 'A70 has a Join, Change or Readmission event in silver',
        (select count(*) from Layercake.recon_active_contact where run_id = @run_id and src_in_truth = 1
           and ev_join_candidate + ev_join_rpq + ev_change + ev_readmission > 0)
    union all select 80, 'A80 has state ranges',
        (select count(*) from Layercake.recon_active_contact where run_id = @run_id and src_in_truth = 1
           and rng_count > 0)
    union all select 85, 'A85 has a state range covering the as-of date',
        (select count(*) from Layercake.recon_active_contact where run_id = @run_id and src_in_truth = 1
           and rng_state_on_asof is not null)
    union all select 90, 'A90 that covering state is not lapse',
        (select count(*) from Layercake.recon_active_contact where run_id = @run_id and src_in_truth = 1
           and rng_state_on_asof is not null and rng_state_on_asof <> 'lapse')
    union all select 99, 'A99 COUNTED ACTIVE by the pipeline',
        (select count(*) from Layercake.recon_active_contact where run_id = @run_id and src_in_truth = 1
           and counted_active = 1)
    union all select 100, 'Pipeline active total (incl. contacts NOT in the truth list)', @pipe_active_contacts
) v
order by v.step_no;

/*-------------------------------------------------------- RS-2 ------*/
select
    '[RS-2] ACTIVE: in the truth list, NOT counted by the pipeline' as [rs],
    fail_gate, gate_seq, fail_reason,
    count(*) as contacts,
    cast(100.0 * count(*) / nullif(@src_active_contacts, 0) as decimal(6,3)) as pct_of_truth_list
from Layercake.recon_active_contact
where run_id = @run_id and recon_status = 'SOURCE_ONLY'
group by fail_gate, gate_seq, fail_reason
order by contacts desc;

/*-------------------------------------------------------- RS-3 ------*/
select '[RS-3] ACTIVE: example contacts per reason' as [rs], v.*
from (
    select
        row_number() over (partition by r.fail_reason order by r.contact_no) as rn,
        r.fail_gate, r.fail_reason, r.contact_no,
        r.src_member_grade, r.src_lapse_code, r.src_state_code, r.src_contact_rows,
        r.brz_present, r.brz_contact_rows, r.is_test_record, r.is_student_grade,
        r.rr_present, r.latest_rics_grade, r.has_cust_trans, r.cust_trans_rows, r.mbase_eligible,
        r.enr_rows, r.p1_after_date, r.p1_after_route, r.p1_after_apptype,
        r.p1_after_ended, r.p1_after_cooloff,
        r.p2_after_election, r.p2_after_apptype, r.p2_after_route,
        r.exc_present, r.eff_enrolment_date, r.eff_election_date, r.eff_lapsed_date,
        r.p1_max_enrolment_date, r.p2_max_election_date,
        r.valid_enrolment_after_lapse, r.paid_src_current_cy, r.paid_but_lapsed,
        r.rr_lapse_code, r.rr_lapse_reason, r.rr_lapsed_date,
        r.predicted_join_branch, r.ev_total, r.ev_readmission, r.ev_country_unresolved,
        r.rng_count, r.rng_state_on_asof,
        r.anomaly_types, r.fail_detail
    from Layercake.recon_active_contact r
    where r.run_id = @run_id and r.recon_status = 'SOURCE_ONLY'
) v
where v.rn <= @examples
order by v.fail_reason, v.contact_no;

/*-------------------------------------------------------- RS-4 ------*/
-- The X-series mechanism (why the PIPELINE kept them) crossed with the truth
-- query's own exclusion (why SOURCE dropped them). Read the pair together: the
-- mechanism is what you can fix, the exclusion is what you are fixing it
-- against.
select
    '[RS-4a] ACTIVE: counted by the pipeline, NOT in the truth list' as [rs],
    fail_gate, gate_seq, fail_reason,
    case when src_present = 0 then 'not present in CE.vwContact'
         when src_member_grade is null then 'member grade null'
         when src_member_grade not in ('Candidate', 'Qualified Professional', 'Qualified Professional - 2 Years')
              then concat('grade = ', src_member_grade)
         when src_lapse_code is not null then 'Rics_LapsedCode set'
         when src_state_code <> 0 then 'StateCode <> 0'
         else 'undetermined' end as excluded_by,
    sum(iif(lapse_invalidated = 1, 1, 0)) as of_which_stale_lapse_ignored,
    sum(iif(ev_join_candidate + ev_join_rpq + ev_change = 0 and ev_readmission > 0, 1, 0))
                                          as of_which_readmission_only,
    sum(iif(no_date_scenario is not null, 1, 0)) as of_which_no_exit_date,
    count(*) as contacts
from Layercake.recon_active_contact
where run_id = @run_id and recon_status = 'PIPELINE_ONLY'
group by fail_gate, gate_seq, fail_reason,
         case when src_present = 0 then 'not present in CE.vwContact'
              when src_member_grade is null then 'member grade null'
              when src_member_grade not in ('Candidate', 'Qualified Professional', 'Qualified Professional - 2 Years')
                   then concat('grade = ', src_member_grade)
              when src_lapse_code is not null then 'Rics_LapsedCode set'
              when src_state_code <> 0 then 'StateCode <> 0'
              else 'undetermined' end
order by contacts desc;

select '[RS-4b] ACTIVE: pipeline-only examples per mechanism' as [rs], v.*
from (
    select row_number() over (partition by r.fail_reason order by r.contact_no) as rn,
           r.fail_gate, r.fail_reason, r.contact_no,
           r.src_member_grade, r.src_lapse_code, r.src_state_code,
           r.src_lapsed_date, r.brz_lapsed_date, r.lapse_invalidated,
           r.rr_present, r.latest_rics_grade, r.rr_grade_not_member, r.has_cust_trans,
           r.rr_lapse_code, r.rr_lapse_reason, r.rr_lapsed_date,
           r.rr_lapse_code_no_date, r.rr_lapse_date_not_on_contact, r.no_date_scenario,
           r.eff_enrolment_date, r.eff_election_date, r.eff_lapsed_date,
           r.p1_max_enrolment_date, r.p2_max_election_date,
           r.predicted_join_branch, r.ev_readmission, r.ev_total,
           r.paid_src_current_cy, r.paid_pipe_current_cy,
           r.rng_state_on_asof, r.rng_region_on_asof, r.anomaly_types, r.fail_detail
    from Layercake.recon_active_contact r
    where r.run_id = @run_id and r.recon_status = 'PIPELINE_ONLY'
) v
where v.rn <= @examples
order by v.fail_reason, v.contact_no;

/*-------------------------------------------------------- RS-5 ------*/
select '[RS-5] PAID gate coverage' as [rs], v.step_no, v.step, v.contacts,
       v.contacts - lag(v.contacts) over (order by v.step_no) as change_vs_previous
from (
    select 0 as step_no, 'Source truth rows (agreed query, as written)' as step, @src_paid_rows as contacts
    union all select 1, '...of which carry a contact number', @src_paid_rows - @src_paid_nulls
    union all select 2, '...collapsed to distinct contact + campaign year (bronze key)', @src_paid_contacts
    union all select 20, 'P20 the paid row survives bronze''s dedupe (not evicted by a later non-paid row)',
        @src_paid_contacts - @src_paid_evicted
    union all select 10, 'P10 present in brnz_subs_status and not soft-deleted',
        (select count(*) from Layercake.recon_paid_contact where run_id = @run_id and src_in_truth = 1
           and brz_present = 1 and isnull(brz_is_deleted, 1) = 0)
    union all select 30, 'P30 has a silv_payment_events row for the CY',
        (select count(*) from Layercake.recon_paid_contact where run_id = @run_id and src_in_truth = 1
           and pay_present = 1)
    union all select 40, 'P40 renewal_date_adj is not null',
        (select count(*) from Layercake.recon_paid_contact where run_id = @run_id and src_in_truth = 1
           and pay_present = 1 and renewal_adj_is_null = 0)
    union all select 50, 'P50 renewal_date_adj <= as-of date',
        (select count(*) from Layercake.recon_paid_contact where run_id = @run_id and src_in_truth = 1
           and pay_present = 1 and renewal_adj_is_null = 0 and renewal_adj_after_asof = 0)
    union all select 55, 'A27 (paid side) has a brnz_cust_trans row',
        (select count(*) from Layercake.recon_paid_contact where run_id = @run_id and src_in_truth = 1
           and pay_present = 1 and renewal_adj_is_null = 0 and renewal_adj_after_asof = 0
           and has_cust_trans = 1)
    union all select 60, 'P60 also has a state range covering the as-of date',
        (select count(*) from Layercake.recon_paid_contact where run_id = @run_id and src_in_truth = 1
           and pay_present = 1 and renewal_adj_is_null = 0 and renewal_adj_after_asof = 0
           and has_range_on_asof = 1)
    union all select 99, 'P99 COUNTED PAID by the pipeline',
        (select count(*) from Layercake.recon_paid_contact where run_id = @run_id and src_in_truth = 1
           and counted_paid = 1)
    union all select 100, 'Pipeline paid total (incl. contacts NOT in the truth list)', @pipe_paid_contacts
) v
order by v.step_no;

/*-------------------------------------------------------- RS-6 ------*/
select
    '[RS-6] PAID: in the truth list, NOT counted by the pipeline' as [rs],
    fail_gate, gate_seq, fail_reason,
    count(*) as contacts,
    cast(100.0 * count(*) / nullif(@src_paid_contacts, 0) as decimal(6,3)) as pct_of_truth_list
from Layercake.recon_paid_contact
where run_id = @run_id and recon_status = 'SOURCE_ONLY'
group by fail_gate, gate_seq, fail_reason
order by contacts desc;

/*-------------------------------------------------------- RS-7 ------*/
select '[RS-7] PAID: example contacts per reason' as [rs], v.*
from (
    select row_number() over (partition by r.fail_reason order by r.contact_no) as rn,
           r.fail_gate, r.fail_reason, r.contact_no,
           r.src_invoice_position, r.src_dedupe_winner_position, r.src_rows_all, r.src_paid_rows,
           r.src_renewal_date, r.src_renewal_date_adj,
           r.brz_present, r.brz_is_deleted, r.brz_invoice_position, r.brz_renewal_date_adj,
           r.pay_present, r.pay_renewal_date_adj, r.pay_payment_date,
           r.has_cust_trans, r.has_range_on_asof, r.rng_state_on_asof, r.rng_count, r.fail_detail
    from Layercake.recon_paid_contact r
    where r.run_id = @run_id and r.recon_status = 'SOURCE_ONLY'
) v
where v.rn <= @examples
order by v.fail_reason, v.contact_no;

/*-------------------------------------------------------- RS-8 ------*/
select '[RS-8] PAID: counted by the pipeline, NOT in the truth list' as [rs],
       isnull(brz_invoice_position, '(no bronze row)') as bronze_invoice_position,
       count(*) as contacts
from Layercake.recon_paid_contact
where run_id = @run_id and recon_status = 'PIPELINE_ONLY'
group by isnull(brz_invoice_position, '(no bronze row)')
order by contacts desc;

/*-------------------------------------------------------- RS-9 ------*/
-- The per-contact re-derivation above vs what silver STORED for the as-of date,
-- read against v9's forward-only load tracking so an expected drift is not
-- reported as a bug.
select
    '[RS-9] recomputed vs stored silv_daily_count' as [rs],
    @asof                                          as asof_date,
    @pipe_active_contacts                          as recomputed_active,
    @stored_active                                 as stored_active,
    @pipe_active_contacts - @stored_active         as active_diff,
    @pipe_paid_contacts                            as recomputed_paid,
    @stored_paid                                   as stored_paid,
    @pipe_paid_contacts - @stored_paid             as paid_diff,
    (select count(*) from #state_asof where covering_ranges > 1) as contacts_with_overlapping_ranges,
    case
        when @asof_has_rows = 0
            then 'N/A - silver holds no rows for this date. Run 02 (or 02 with @RebuildFrom) to load it.'
        when @pipe_active_contacts = @stored_active and @pipe_paid_contacts = @stored_paid
            then 'PASS - the recomputation matches what silver stored'
        when (select count(*) from #state_asof where covering_ranges > 1) > 0
            then 'INVESTIGATE - some contacts have overlapping state ranges, which double-count in the stored aggregate but count once here. Fix the range chain first (see 09 checks C5b/C5c and RS-11 item 9), then re-read this row.'
        when @has_dcl = 1 and @asof < @today and @asof_marked_loaded = 1
            then 'EXPECTED DRIFT - under v9 this date is marked loaded in etl_daily_count_loaded and is never re-derived by a daily run, so the stored value is a point-in-time record. To apply source corrections: exec Layercake.usp_load_silver @RebuildFrom = ''' + convert(varchar(10), @asof, 23) + ''''
        when @asof = @today
            then 'FAIL - the current day is rebuilt on every silver run, so it should match. Silver has not run since the source last changed: re-run 02.'
        else 'FAIL - this date is not marked loaded and its stored rows disagree with a fresh derivation. Re-run 02.'
    end as verdict;

/*-------------------------------------------------------- RS-10 -----*/
select '[RS-10] headline walk' as [rs], v.ord, v.metric, v.value
from (
    select 10 ord, 'ACTIVE: source truth (agreed query)'                as metric, cast(@src_active_rows as bigint) as value
    union all select 11, 'ACTIVE: ...distinct contact numbers',           @src_active_contacts
    union all select 12, 'ACTIVE: in both source and pipeline',           (select count(*) from Layercake.recon_active_contact where run_id = @run_id and recon_status = 'BOTH')
    union all select 13, 'ACTIVE: source only (lost by the pipeline)',    (select count(*) from Layercake.recon_active_contact where run_id = @run_id and recon_status = 'SOURCE_ONLY')
    union all select 14, 'ACTIVE: pipeline only (gained)',                (select count(*) from Layercake.recon_active_contact where run_id = @run_id and recon_status = 'PIPELINE_ONLY')
    union all select 15, 'ACTIVE: pipeline total (recomputed)',           @pipe_active_contacts
    union all select 16, 'ACTIVE: pipeline total (stored silv_daily_count)', @stored_active
    union all select 17, 'ACTIVE: net difference (pipeline - source)',    cast(@pipe_active_contacts - @src_active_contacts as bigint)
    union all select 20, 'PAID: source truth (agreed query)',             @src_paid_rows
    union all select 21, 'PAID: ...distinct contact numbers',             @src_paid_contacts
    union all select 22, 'PAID: in both source and pipeline',             (select count(*) from Layercake.recon_paid_contact where run_id = @run_id and recon_status = 'BOTH')
    union all select 23, 'PAID: source only (lost by the pipeline)',      (select count(*) from Layercake.recon_paid_contact where run_id = @run_id and recon_status = 'SOURCE_ONLY')
    union all select 24, 'PAID: pipeline only (gained)',                  (select count(*) from Layercake.recon_paid_contact where run_id = @run_id and recon_status = 'PIPELINE_ONLY')
    union all select 25, 'PAID: pipeline total (recomputed)',             @pipe_paid_contacts
    union all select 26, 'PAID: pipeline total (stored silv_daily_count)', @stored_paid
    union all select 27, 'PAID: net difference (pipeline - source)',      cast(@pipe_paid_contacts - @src_paid_contacts as bigint)
) v
order by v.ord;

/*-------------------------------------------------------- RS-11 -----*/
-- Structural divergences: differences that follow from how the pipeline is
-- built rather than from bad data. Sized here so each one is a number.
select '[RS-11] structural divergences, sized' as [rs], v.ord, v.divergence, v.contacts, v.note
from (
    select 1 as ord,
        'Truth-query filter columns are not landed in bronze' as divergence,
        cast(null as int) as contacts,
        cast(N'CE.vwContact.Rics_LapsedCode and StateCode drive the agreed ACTIVE query but neither is landed by 01 - brnz_contact carries Rics_LapsedDate only. The pipeline cannot reproduce the truth filter; it infers lapse from the DATE plus the stale-lapse invalidation instead. Land both columns in bronze if the two numbers are ever to agree by construction.' as nvarchar(600)) as note

    union all
    select 2,
        'Contacts kept active only by the stale-lapse invalidation',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and lapse_invalidated = 1 and counted_active = 1),
        N'The bronze contact carries a lapse date that predates the derived enrolment/election, so silv_member_base discards it and no Lapse event is emitted. This is the concrete mechanism behind divergence 1: the source lapse CODE is invisible to the pipeline, so these contacts stay active on a date test alone.'

    union all
    select 3,
        'CE.vwEnrolments_Valid excludes Direct Entry, silver v9 does not',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and p1_after_cooloff > 0 and p1_view_parity_rows = 0
           and p2_rows_with_enrolment = 0),
        N'Contacts whose ONLY source of an enrolment date is a Direct Entry application row - they are Candidates under v9 and would have no enrolment date under strict view parity. The view still carries ''Direct Entry'' in its Application Type ID exclusion list despite the 06/03/2024 comment; v9 deliberately omits it. Column p1_view_parity_rows carries the row-level detail.'

    union all
    select 4,
        'Paid contacts with no state range covering the as-of date',
        (select count(*) from Layercake.recon_paid_contact
         where run_id = @run_id and src_in_truth = 1 and pay_present = 1
           and renewal_adj_is_null = 0 and renewal_adj_after_asof = 0 and has_range_on_asof = 0),
        N'The daily paid count is derived from the same range join as the active count, so a contact who has paid but has no covering state range is dropped from the paid number entirely. Usually the biggest single structural difference between the source paid snapshot and the pipeline''s paid count.'

    union all
    select 5,
        'Payment events with a null renewal_date_adj',
        (select count(*) from Layercake.recon_paid_contact
         where run_id = @run_id and src_in_truth = 1 and renewal_adj_is_null = 1),
        N'renewal_date_adj is the only date the day-by-day paid rule reads. Where it is null the contact can never be counted paid on any date, however they appear in the source snapshot.'

    union all
    select 6,
        'Paid source rows EVICTED by bronze''s (contact, campaign year) dedupe',
        @src_paid_evicted,
        N'Bronze keeps one subs row per contact + campaign year, ordered by [Renewal Date Adj] desc, and does so BEFORE any invoice-position filter. Where a later non-paid row wins, the paid row is discarded in bronze and silver never sees it - re-running 02 cannot recover these. This is a real loss, not a counting-basis difference.'

    union all
    select 7,
        'Duplicate PAID source rows collapsed by the same dedupe',
        @src_paid_dupes,
        N'The agreed paid query counts ROWS; bronze keys on contact + campaign year. These rows are removed but the contact still reaches silver via the surviving paid row - a counting-basis difference, not a loss.'

    union all
    select 8,
        'Source truth rows with no contact number',
        @src_active_nulls,
        N'Counted by the agreed ACTIVE query but carrying no Rics_contactno, so they can never join to anything downstream.'

    union all
    select 9,
        'Contact numbers shared by two or more CE.vwContact rows',
        @src_dup_contact_nos,
        N'v9 derives events per brnz_contact ROW and keys them on the contact NUMBER, so a duplicate makes the silver load fail loudly on the #ev_stage primary key (by design). Any non-zero here is the first thing to fix - every other number in this report is suspect until it is zero. Column src_contact_rows carries the per-contact count.'

    union all
    select 10,
        'Truth-list contacts held in only by the 07 exception backfill',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and src_in_truth = 1
           and exc_enrolment_used = 1 and exc_election_used = 1),
        N'These contacts have neither a qualifying enrolment nor a qualifying election of their own; they are in the pipeline only because 07 backfilled curated dates. If 07 is not deployed they drop out of the active number entirely.'

    union all
    select 11,
        'Open data anomalies among truth-list contacts',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and src_in_truth = 1 and anomaly_types is not null),
        N'Contacts carrying at least one open silv_data_anomaly row (ELECTION_NO_ENROLMENT / ELECTION_BEFORE_ENROLMENT / RPQ_WITH_ENROLMENT / STALE_LAPSE_IGNORED / NO_RICS_RECORD / NO_TRANSACTIONS). The first four still count - their derivation had to tolerate bad data. NO_RICS_RECORD and NO_TRANSACTIONS are the two types that record a contact the driver REMOVED (see divergences 19 and 22).'

    union all
    select 12,
        'Contacts with MORE THAN ONE state range covering the as-of date',
        (select count(*) from #state_asof where covering_ranges > 1),
        N'A correctly chained contact has exactly one covering range under the half-open rule. Anything here means an overlapping chain: v9''s aggregate would count the contact once per cell (inflating the stored number) while this report counts them once. Expected to be zero - if it is not, fix it before trusting RS-9. Also check for NULL state_seq (pre-v6 rows) via 09''s C5d.'

    union all
    select 13,
        'Events whose country_id does not resolve in silv_ref_country',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and ev_country_unresolved > 0),
        N'Step 5 INNER JOINs silv_ref_country when building state ranges, so an event with an unresolvable country produces NO range and the contact vanishes from every count. Looks identical to "step 5 is out of step" unless you check this.'

    union all
    select 14,
        'Contacts where the predicted event branch disagrees with silver',
        (select count(*) from Layercake.recon_active_contact r
         where r.run_id = @run_id
           and ((r.predicted_join_branch = 'Join/Candidate' and r.ev_join_candidate = 0)
             or (r.predicted_join_branch = 'Join/RPQ'       and r.ev_join_rpq = 0)
             or (r.predicted_join_branch = 'Change'         and r.ev_change = 0))),
        N'This script re-derives which branch of v9 step 4 each contact should take (Join/Candidate, Join/RPQ per the v6 RPQ-first rule, or Change). A disagreement with silv_membership_events means silver is stale against current bronze - re-run 02 before reading anything else here.'

    union all
    select 15,
        'Lapse code with NO lapse date anywhere (Deceased / Duplicate / other)',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and rr_lapse_code_no_date = 1),
        N'The rics record says the contact is out but carries no date, and brnz_contact.Rics_LapsedDate is null too. A state range needs a date, so the pipeline can neither close them today nor restate history. NO HANDLING RULE YET - see RS-14. Split by scenario in RS-4a (X20 Deceased / X21 Duplicate / X22 other).'

    union all
    select 16,
        'Lapsed date on the rics record but NOT on the contact',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and rr_lapse_date_not_on_contact = 1),
        N'silv_member_base reads apuk_lapsecode for the lapse REASON but takes the lapse DATE from brnz_contact.Rics_LapsedDate only - apuk_lapseddate is never read. Where the rics record is dated and the contact is not, the lapse is invisible to the derivation. Unlike divergence 15 there IS a date here, so this one is fixable in silver by coalescing the rics-record date in (a rule decision, not a data gap).'

    union all
    select 17,
        'Lapsed in the pipeline despite a LATER qualifying enrolment/election',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and valid_enrolment_after_lapse = 1),
        N'silv_member_base invalidates a stale lapse by comparing the lapse date with the EARLIEST enrolment/election. A member who enrolled, lapsed, then re-enrolled fails that test (their first enrolment predates the lapse) so the Lapse event stands and they read as lapsed on every date after it. Comparing against the LATEST qualifying date instead would clear them - min() vs max() is the whole of this divergence. Columns p1_max_enrolment_date / p2_max_election_date carry the evidence.'

    union all
    select 18,
        'Lapsed in the pipeline despite a payment for the current campaign year',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and paid_but_lapsed = 1),
        N'These contacts have paid for the current campaign year, so they are counted PAID, and are simultaneously counted as lapsed - i.e. not ACTIVE - on the same date. A payment is an assertion of membership, so the lapse date left on the contact record is stale. Overlaps divergence 17 where the member also re-enrolled; each is counted here on its own evidence.'

    union all
    select 19,
        'Truth-list contacts DROPPED because they have no rics record (A26)',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and src_in_truth = 1 and rr_present = 0),
        N'No brnz_rics_record row for the membership number, so no grade, lapse code or retirement date exists to test. Gate A26 excludes them from the silv_member_base driver and the Readmission guard keeps a payment from bringing them back, so the pipeline no longer counts them - this is the size of that deliberate reduction against the truth list, and every one of them is logged as NO_RICS_RECORD in silv_data_anomaly for the client. The pipeline-side residual (recon_status = ''PIPELINE_ONLY'' with rr_present = 0, reported as X50) should now be zero.'

    union all
    select 20,
        'Pipeline-active contacts whose rics grade is not a member grade',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and recon_status = 'PIPELINE_ONLY' and rr_grade_not_member = 1),
        N'Latest rics record grade is not 200000000 Candidate / 200000001 Qualified Professional / 200000002 Qualified Professional - 2 Years. The driver excludes the Student grade (A25) and contacts with no rics record at all (A26), but every other non-member grade on a record that EXISTS still produces events and a state range. Widening the exclusion to an allowlist of 200000000/1/2 is a rule decision, not a data fix.'

    union all
    select 21,
        'PAID contacts whose covering state on the as-of date is lapse',
        (select count(*) from Layercake.recon_paid_contact
         where run_id = @run_id and counted_paid = 1 and rng_state_on_asof = 'lapse'),
        N'The paid count joins state ranges of ANY grade, so these still count as paid - correctly. Listed as the paid-side view of divergence 18: the same contacts are absent from the ACTIVE count on a date they have paid for.'

    union all
    select 22,
        'Truth-list contacts DROPPED because they have no transaction history (A27)',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and src_in_truth = 1 and has_cust_trans = 0),
        N'No brnz_cust_trans row for the membership number, so the contact has never transacted and is not a valid contact. Gate A27 excludes them from the silv_member_base driver and the Readmission guard keeps an invoice position from bringing them back, so they are counted as neither active nor paid - this is the size of that deliberate reduction against the ACTIVE truth list. The ones that also carry a valid enrolment or election are logged as NO_TRANSACTIONS in silv_data_anomaly; the rest are contacts with no membership basis at all. The pipeline-side residual (X55) should be zero.'

    union all
    select 23,
        'PAID-truth contacts dropped by the same A27 gate',
        (select count(*) from Layercake.recon_paid_contact
         where run_id = @run_id and src_in_truth = 1 and has_cust_trans = 0),
        N'The paid side of divergence 22, and the one worth reading twice: these contacts hold a PAID invoice position in Subs.vwSubsMemberStatuses for the campaign year yet have no cash transaction anywhere in brnz_cust_trans. Paid on paper, never transacted. They are dropped from the paid number because the paid count joins the same state ranges as the active count. Reported as P60 / NO_TRANSACTION_HISTORY.'

    union all
    select 24,
        'Contacts whose enrolment / election date is BACKDATED to the first paid campaign year',
        (select count(*) from Layercake.recon_active_contact r
         where r.run_id = @run_id
           and exists (select 1 from #anom a
                       where a.contact_no = r.contact_no
                         and a.anomaly_type in ('ENROLMENT_AFTER_FIRST_PAID', 'ELECTION_AFTER_FIRST_PAID'))),
        N'The recorded enrolment date (real row or 07 fallback) - or, with no enrolment date at all, the election date - sits in a later campaign year than the contact''s first paid position, so silv_member_base moved it to the first paid year: the Join lands where the paying started, later paid years derive as Renewals, and the recorded year gets no Join (it counts as paid only if a paid position exists for it). A deliberate correction, kept visible on the base row and as ENROLMENT_AFTER_FIRST_PAID / ELECTION_AFTER_FIRST_PAID in silv_data_anomaly. The lapse verdicts in this report (X40, A90/90) use the backdated date, as the driver does.'

    union all
    select 25,
        'Contacts whose enrolment / election date is MOVED FORWARD to the first paid campaign year',
        (select count(*) from Layercake.recon_active_contact r
         where r.run_id = @run_id
           and exists (select 1 from #anom a
                       where a.contact_no = r.contact_no
                         and a.anomaly_type in ('ENROLMENT_BEFORE_FIRST_PAID', 'ELECTION_BEFORE_FIRST_PAID'))),
        N'The mirror of divergence 24: the recorded date sits in a campaign year the contact holds NO paid position for, and the first paid position is a later year, so silv_member_base moved the date forward - the first paid year is the join year and only the years after it renew. Bounded by the payment history: only a recorded year on or after the earliest campaign year in silv_payment_events is moved, because before that the subs history was never loaded and a late first paid year is the edge of the data, not a fact about the member. An election the enrolment moved forward past is carried to the same date. Until the join date these contacts are NOT active in the pipeline even where the source holds them active - expect them as SOURCE_ONLY on an as-of date between the recorded and the moved date. Kept visible as ENROLMENT_BEFORE_FIRST_PAID / ELECTION_BEFORE_FIRST_PAID in silv_data_anomaly.'
) v
order by v.ord;

/*-------------------------------------------------------- RS-12 -----*/
select '[RS-12] open retrospective-change log (etl_daily_count_pending_rebuild)' as [rs],
       [source], affected_from, detection_count, first_detected_at, last_detected_at,
       N'Apply with: exec Layercake.usp_load_silver @RebuildFrom = '''
           + convert(varchar(10), affected_from, 23) + '''' as how_to_apply
from #dc_pending
order by affected_from;

/*-------------------------------------------------------- RS-13 -----*/
select
    '[RS-13] where to look next' as [rs],
    @run_id as run_id,
    N'select * from Layercake.recon_active_contact where recon_status = ''SOURCE_ONLY'' order by gate_seq, contact_no;' as active_detail,
    N'select * from Layercake.recon_paid_contact where recon_status = ''SOURCE_ONLY'' and fail_gate = ''P60'';' as paid_detail,
    N'Re-run this script after each fix and compare Layercake.recon_run row by row (set @keep_history = 1 to keep the history).' as workflow;

/*-------------------------------------------------------- RS-14 -----*/
-- The anomaly-scenario register. One row per named contradiction, sized, with
-- the state of its handling rule and the query that lists its contacts.
--   RULE EXISTS  - silver already has a rule; a non-zero count is data to fix
--                  (or a rule to widen), not a hole in the pipeline.
--   RULE NEEDED  - the evidence to act on IS present but no rule reads it.
--                  A decision away from being fixable in silver.
--   NO RULE YET  - there is no date to act on at all. Not fixable in silver as
--                  it stands; needs a date landed in source or an agreed
--                  convention for dating the exit.
-- @examples has no effect here - every row is a count plus a query.
select '[RS-14] anomaly-scenario register' as [rs], v.ord, v.scenario, v.contacts, v.handling, v.what_is_needed, v.list_them
from (
    select 1 as ord,
        'Deceased, no lapse date (X20)' as scenario,
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and fail_reason = 'PIPELINE_ONLY_DECEASED_NO_LAPSE_DATE') as contacts,
        cast('NO RULE YET' as varchar(12)) as handling,
        cast(N'Lapse code 200000000 with no date on the rics record or the contact. The pipeline keeps counting them active and history cannot be restated, because a state range has to close on a DATE. Options: land a date of death in source; or agree a convention (ModifiedOn of the rics record, or the start of the campaign year the code first appeared in) and apply it in silv_member_base.' as nvarchar(700)) as what_is_needed,
        cast(N'select * from Layercake.recon_active_contact where run_id = ''' + cast(@run_id as nvarchar(40)) + N''' and fail_reason = ''PIPELINE_ONLY_DECEASED_NO_LAPSE_DATE'';' as nvarchar(300)) as list_them

    union all
    select 2, 'Duplicate, no lapse date (X21)',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and fail_reason = 'PIPELINE_ONLY_DUPLICATE_NO_LAPSE_DATE'),
        'NO RULE YET',
        N'Lapse code 200000001 with no date anywhere. A duplicate is not an exit - it is one person counted twice - so dating a lapse is the wrong fix in principle: the surviving record should absorb the duplicate. Until source merges them, the only safe treatment is a suppression list keyed on contact number, applied at the driver.',
        N'select * from Layercake.recon_active_contact where run_id = ''' + cast(@run_id as nvarchar(40)) + N''' and fail_reason = ''PIPELINE_ONLY_DUPLICATE_NO_LAPSE_DATE'';'

    union all
    select 3, 'Other lapse code, no lapse date (X22)',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and fail_reason = 'PIPELINE_ONLY_LAPSE_CODE_NO_LAPSE_DATE'),
        'NO RULE YET',
        N'Same shape as X20/X21 under a different lapse reason - check rr_lapse_reason for the mix before deciding whether one convention covers them all.',
        N'select rr_lapse_code, rr_lapse_reason, count(*) from Layercake.recon_active_contact where run_id = ''' + cast(@run_id as nvarchar(40)) + N''' and fail_reason = ''PIPELINE_ONLY_LAPSE_CODE_NO_LAPSE_DATE'' group by rr_lapse_code, rr_lapse_reason;'

    union all
    select 4, 'Lapse date on the rics record only (X30)',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and rr_lapse_date_not_on_contact = 1),
        'RULE NEEDED',
        N'There IS a date - silver just never reads it, because the Lapse event takes its date from brnz_contact.Rics_LapsedDate and apuk_lapseddate is unused. One decision: coalesce the rics-record date into silv_member_base, or confirm the contact date is authoritative and the rics-record date is noise.',
        N'select * from Layercake.recon_active_contact where run_id = ''' + cast(@run_id as nvarchar(40)) + N''' and rr_lapse_date_not_on_contact = 1;'

    union all
    select 5, 'Valid enrolment AFTER the lapse date (A90/90)',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and valid_enrolment_after_lapse = 1),
        'RULE NEEDED',
        N'The stale-lapse rule in silv_member_base compares the lapse date with the EARLIEST enrolment/election, so a member who enrolled, lapsed, then re-enrolled keeps their Lapse. Comparing with the LATEST qualifying enrolment/election clears exactly this cohort. Note the wider consequence before changing it: invalidating the lapse removes the Lapse event entirely, so the member reads as never having lapsed rather than as having lapsed and returned - if the history matters, this wants a Readmission event at the re-enrolment date instead.',
        N'select * from Layercake.recon_active_contact where run_id = ''' + cast(@run_id as nvarchar(40)) + N''' and valid_enrolment_after_lapse = 1;'

    union all
    select 6, 'Paid for the current CY but lapsed on the as-of date (A90/91)',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and paid_but_lapsed = 1),
        'RULE NEEDED',
        N'Counted PAID and not counted ACTIVE on the same date - the two numbers contradict each other for these contacts. A payment for the campaign year is an assertion of membership, so the lapse date on the contact record is stale. The existing Renewal / In-Year Readmission / Readmission events already model a payment-driven return; the gap is that none of them invalidates a lapse date that sits AFTER the range they open. Decide whether a payment inside the campaign year should supersede a lapse date in the same year.',
        N'select * from Layercake.recon_active_contact where run_id = ''' + cast(@run_id as nvarchar(40)) + N''' and paid_but_lapsed = 1;'

    union all
    select 7, 'No rics record at all (A26, was X50)',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and rr_present = 0),
        'RULE EXISTS',
        N'DECIDED: the driver now requires a rics record. A contact with no brnz_rics_record row has no grade, lapse code or retirement date behind it, so silv_member_base excludes it (gate A26) and the payment-derived Readmission repeats the test - it produces no events, no state range and no active count. The cohort is captured as NO_RICS_RECORD in silv_data_anomaly for feedback to the client: that is the client-facing list, and it is where the count above should be reconciled to. The pipeline-side residual (X50) should be zero.',
        N'select contact_no, detail, first_detected_at, last_seen_at from Layercake.silv_data_anomaly where anomaly_type = ''NO_RICS_RECORD'' and resolved_at is null order by contact_no;'

    union all
    select 11, 'No transaction history at all (A27)',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and has_cust_trans = 0),
        'RULE EXISTS',
        N'DECIDED: the driver now requires a transaction. A contact with no row in brnz_cust_trans has never transacted, so it is not a valid contact - silv_member_base excludes it (gate A27), the payment-derived Readmission repeats the test, and because the paid count joins the same state ranges it counts as neither active nor paid. Only the contacts that ALSO have a valid enrolment or election are logged as NO_TRANSACTIONS in silv_data_anomaly: that contradiction is what makes them worth feeding back, and it is the client-facing list. The pipeline-side residual (X55) should be zero, and the paid-side size is RS-11 divergence 23.',
        N'select contact_no, detail, first_detected_at, last_seen_at from Layercake.silv_data_anomaly where anomaly_type = ''NO_TRANSACTIONS'' and resolved_at is null order by contact_no;'

    union all
    select 8, 'Rics grade is not a member grade (X60)',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and recon_status = 'PIPELINE_ONLY' and rr_grade_not_member = 1),
        'RULE NEEDED',
        N'The driver excludes the Student grade (A25) and contacts with no rics record at all (A26); every other non-member grade on a record that EXISTS still produces events and a state range. Widening the exclusion to an allowlist of 200000000/1/2 would align the driver with the truth query - check the grade mix first, since a null grade on a real record also lands here.',
        N'select latest_rics_grade, count(*) from Layercake.recon_active_contact where run_id = ''' + cast(@run_id as nvarchar(40)) + N''' and recon_status = ''PIPELINE_ONLY'' and rr_grade_not_member = 1 group by latest_rics_grade;'

    union all
    select 9, 'Stale lapse already invalidated (X40)',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and recon_status = 'PIPELINE_ONLY' and lapse_invalidated = 1),
        'RULE EXISTS',
        N'The stale-lapse rule fired as designed and these contacts are active by intent - already logged as STALE_LAPSE_IGNORED in silv_data_anomaly. Listed here for completeness: on a true readmission CE clears the lapse date, so a surviving one is still a source mismatch worth feeding back.',
        N'select * from Layercake.recon_active_contact where run_id = ''' + cast(@run_id as nvarchar(40)) + N''' and recon_status = ''PIPELINE_ONLY'' and lapse_invalidated = 1;'

    union all
    select 10, 'Active only from a payment-derived Readmission (X70)',
        (select count(*) from Layercake.recon_active_contact
         where run_id = @run_id and recon_status = 'PIPELINE_ONLY'
           and ev_join_candidate + ev_join_rpq + ev_change = 0 and ev_readmission > 0),
        'RULE EXISTS',
        N'v9 builds a state range from a Readmission with no silv_member_base basis at all, by design - a payment after a gap is a return to membership. It is the only event that does so, which is why the A26 no-rics-record test is repeated on it; the contacts left here are those excluded from the base for some OTHER reason (Student grade, no qualifying enrolment) whom a payment still readmits. Non-zero is expected; a large number means the Readmission derivation is firing on contacts who should never have been members, which is the open validation item with Alex/Maxine.',
        N'select * from Layercake.recon_active_contact where run_id = ''' + cast(@run_id as nvarchar(40)) + N''' and recon_status = ''PIPELINE_ONLY'' and ev_join_candidate + ev_join_rpq + ev_change = 0 and ev_readmission > 0;'

    union all
    select 12, 'Enrolment / election recorded after the first paid campaign year (ENROLMENT_ / ELECTION_AFTER_FIRST_PAID)',
        (select count(*) from #anom where anomaly_type in ('ENROLMENT_AFTER_FIRST_PAID', 'ELECTION_AFTER_FIRST_PAID')),
        'RULE EXISTS',
        N'DECIDED: a valid enrolment row - or, with no enrolment at all, a valid election row - dated years after the subs history says the contact was paying. Derived as recorded, the Join landed in a year they had NOT paid (counting them as paid from the Join event there) with the earlier payments falling through as Renewals before any Join. silv_member_base now backdates the date that anchors the Join to the first paid campaign year, keeping the recorded date on the row; the Join lands where the paying started and every later paid year derives as a Renewal. Where an enrolment date exists the election date is never moved. The count here is every open anomaly of both types, not just this run''s cohort; RS-11 divergence 24 sizes it within the run.',
        N'select anomaly_type, contact_no, detail, first_detected_at, last_seen_at from Layercake.silv_data_anomaly where anomaly_type in (''ENROLMENT_AFTER_FIRST_PAID'', ''ELECTION_AFTER_FIRST_PAID'') and resolved_at is null order by anomaly_type, contact_no;'

    union all
    select 13, 'Enrolment / election recorded before the first paid campaign year (ENROLMENT_ / ELECTION_BEFORE_FIRST_PAID)',
        (select count(*) from #anom where anomaly_type in ('ENROLMENT_BEFORE_FIRST_PAID', 'ELECTION_BEFORE_FIRST_PAID')),
        'RULE EXISTS',
        N'DECIDED: a valid enrolment - or, with no enrolment at all, a valid election - in a campaign year the contact holds no paid position for, with the first paid position in a later year. Derived as recorded, the Join landed in the unpaid year and the first paid year fell through as a Renewal. silv_member_base now moves the date that anchors the Join forward to the first paid campaign year, keeping the recorded date on the row. BOUNDED: only where the recorded year is on or after the earliest campaign year in silv_payment_events - earlier than that the subs history was never loaded, so a late first paid year is the edge of the data and the date is left alone. An election the enrolment moved forward past is carried to the same date (it would otherwise open the state range in the unpaid year). The count here is every open anomaly of both types; RS-11 divergence 25 sizes it within the run.',
        N'select anomaly_type, contact_no, detail, first_detected_at, last_seen_at from Layercake.silv_data_anomaly where anomaly_type in (''ENROLMENT_BEFORE_FIRST_PAID'', ''ELECTION_BEFORE_FIRST_PAID'') and resolved_at is null order by anomaly_type, contact_no;'
) v
order by case v.handling when 'NO RULE YET' then 1 when 'RULE NEEDED' then 2 else 3 end, v.ord;

drop table #src_contact, #truth_active, #src_subs, #subs_agg, #truth_paid, #state_asof,
           #pipe_active, #pipe_paid, #cohort_a, #cohort_p, #p_ranges, #a_bronze,
           #enr, #enr_agg, #enr_rpq, #first_paid, #a_events, #a_ranges, #a_anom,
           #exc, #anom, #dc_loaded, #dc_pending;
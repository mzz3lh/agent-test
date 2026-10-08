/*************************************************************************************
    Layercake ACTIVE MEMBER difference list
    ---------------------------------------------------------------------------------
    PURPOSE
    One list that accounts for EVERY unit of difference between the official active
    member count and the Layercake active member count on a given date - contact by
    contact, with the reason(s) each contact is on it.

        OFFICIAL ACTIVE  (agreed definition - doc: 'Queries to get current snapshot
                          of active and paid member counts')
            select count(*) from CE.vwContact
            where MemberGrade_Description in ('Candidate','Qualified Professional',
                                              'Qualified Professional - 2 Years')
              and Rics_LapsedCode is null
              and StateCode = 0

        LAYERCAKE ACTIVE
            @layercake_source = 'GOLD'    sum(ActiveMembers) from
                                          fact_daily_member_count_detail on @asof
            @layercake_source = 'SILVER'  sum(active_count) from
                                          silv_daily_count on @asof

    ---------------------------------------------------------------------------------
    THE GUARANTEE
    Every row of the list carries a signed count_impact:

        +1   the contact is in the official list and NOT in the Layercake number
        -1   the contact is in the Layercake number and NOT in the official list

    and a handful of BRIDGE rows carry the differences that are not contact-level
    membership at all - a source row with no contact number, a contact holding two
    source rows, a contact counted twice by an overlapping state range, stored-vs-
    derived drift.

        sum(count_impact) over the whole list  ==  official count - Layercake count

    RS-1 asserts exactly that and prints PASS or FAIL. If it says PASS the list is
    complete: nothing is missing from it and nothing is double counted in it. If it
    says FAIL, do not use the list - something below has stopped being true.

    ---------------------------------------------------------------------------------
    HOW THE NUMBER IS BRIDGED  (RS-2 walks this line by line)

        official count            count(*) over CE.vwContact rows
          - rows with no contact number          B01   (+1 each)
          - extra rows sharing a contact number  B02   (+1 each)
        = official contacts                      distinct contact numbers

        official contacts - Layercake contacts   = (+1 rows) - (-1 rows)

        Layercake contacts        distinct contacts with a covering non-lapse range
          + extra region/grade cells             B03   (-1 each)
        = re-derived cell total                  what the daily-count join produces
          + stored-vs-derived drift              B04
        = silv_daily_count on @asof
          + gold behind silver                   B05   (only when anchored on GOLD)
        = Layercake count

    The two ends of that walk are different KINDS of number, which is the whole
    reason the bridge exists. The official side counts ROWS in a current-state view.
    The Layercake side is a sum over (region, grade) CELLS, each counting distinct
    contacts, on a stored daily aggregate. B01-B03 are the conversions between them;
    B04-B05 are staleness between the layers.

    B04 is not an error on its own. silv_daily_count is FORWARD ONLY: a date already
    marked in etl_daily_count_loaded is never re-derived by a daily run, so a past
    date's stored value is a point-in-time record of what source said when it was
    first loaded. On @asof = today - the only fully meaningful setting, see NOTES -
    it should be zero; anything else is either expected drift (remedy: @RebuildFrom)
    or an out-of-step silver (remedy: re-run the silver load).

    ---------------------------------------------------------------------------------
    REASON CODES

    IN_OFFICIAL_NOT_LAYERCAKE - walked in pipeline order, so reason_code names the
    FIRST thing that stopped the contact. all_reasons carries every code that
    applies, which is what to read when one contact fails several rules at once.

      A01  no brnz_contact row - source has moved since the last bronze load
      A02  every brnz_contact row for the number is a test record
      A03  no brnz_rics_record row at all               - silv_member_base driver
      A04  latest rics record is Student grade (200000003) - driver. Not raised
           where the driver overrides the grade: the Student status is
           superseded in the enrolment history (vw_student_superseded)
      A05  no brnz_cust_trans row at all                - driver
      A06  passed every driver test but has no silv_member_base row - unexpected
      A07  no brnz_enrolment row at all, and no exception fallback date
      A08  brnz_enrolment rows exist but none survives vw_enrolment_base
      A09  qualifying rows exist but no effective enrolment/election date
      A10  dates exist but no Join / Change / Readmission event was emitted
      A11  events exist but no state range was built
      A12  ranges exist but the earliest starts AFTER @asof (future-dated enrolment)
      A13  ranges exist, none covers @asof (closed before it, or zero-length)
      A20  covering state is lapse, but a qualifying enrolment or election POSTDATES
           the lapse. silv_member_base tests the lapse against the EARLIEST
           enrolment, so a member who lapsed and re-enrolled keeps their Lapse
      A21  covering state is lapse, and the contact is counted PAID for this
           campaign year on the same date - the two readings contradict each other
      A22  covering state is lapse from a contact lapse DATE, while source carries
           no lapse CODE. The agreed query keeps them, the pipeline drops them.
           Usually the largest single reason, and structural - see NOTES
      A23  covering state is lapse, residual
      A99  unexplained - if this is not zero, the rule set in section 6a needs
           extending. Never leave it non-zero and quote the list as complete

    IN_LAYERCAKE_NOT_OFFICIAL - the pipeline lost nothing here; the official query
    excluded the contact. The code names the MECHANISM instead of a gate.

      X01  no CE.vwContact row at all for the contact number
      X02  no source row carries one of the three member grades
      X03  no source row carries StateCode = 0 (not landed in bronze at all)
      X10  rics record lapse code 200000000 Deceased, and NO lapse date anywhere
      X11  ... 200000001 Duplicate, no lapse date
      X12  ... any other lapse code, no lapse date
           X10-X12 are the no-date cohort: source knows the contact is out, the
           pipeline has no date to exit them on, so it can neither drop them today
           nor restate history. Not fixable here - it needs a date landed in
           source, or an agreed convention (e.g. exit at the rics record's
           ModifiedOn, or at the start of the campaign year the code appeared in)
      X13  lapse date on brnz_rics_record but not on the contact. The Lapse event
           reads the CONTACT date only, so the rics-record date is invisible to it
      X15  contact lapse date is AFTER @asof - the pipeline is right to count them
      X14  contact lapse date present but invalidated by the stale-lapse rule
      X17  source carries a lapse date bronze has not landed yet
      X16  source lapse code set, mechanism not one of the above
      X20  active purely from a payment-derived Readmission. A secondary reason -
           it appears in all_reasons, never as the primary code
      X98  rows exist that pass each official test separately, but no single row
           passes all three
      X99  unexplained - same warning as A99

    ---------------------------------------------------------------------------------
    NOTES
      * Read-only. #temp tables only - nothing in the Layercake schema is written,
        so this is safe to run against the live database at any time.
      * Reads the LIVE source view. Run it straight after the daily load: mid-day, a
        few A01 / X01 rows are timing rather than error.
      * @asof defaults to today and that is the only fully meaningful setting. The
        SOURCE side has no as-of dimension - CE.vwContact is a current-state view -
        so an earlier @asof compares today's source membership against a historical
        pipeline state. RS-0 flags it.
      * Rics_LapsedCode and StateCode both drive the official query and NEITHER is
        landed in bronze. brnz_contact carries Rics_LapsedDate and nothing else, so
        the pipeline cannot reproduce the official filter even in principle - it
        infers lapse from the DATE plus the stale-lapse invalidation instead. That
        one gap is the structural cause behind A22 and most of the X-series, and no
        rule change here can close it: it needs the two columns landed in bronze.
      * silv_data_anomaly is read for context only (the anomaly_types column) and is
        optional - the script runs without it.

    HOW TO RUN
    Not deployed - Deploy-Database.ps1 only walks the numbered phase folders. Set
    the knobs below and run it by hand:

        sqlcmd -S <server> -d <db> -U <user> -P <pwd> -i active-member-difference.sql -b -N -I

    Requires the database project deployed and bronze + silver + gold loaded.
    Its sibling, paid-member-difference.sql, does the same job for the paid number.
*************************************************************************************/

set nocount on;
set xact_abort on;

------------------------------------------------------------------ configuration --
declare @asof             date       = cast(getdate() as date);  -- reconcile as at this date
declare @layercake_source varchar(6) = 'GOLD';                   -- 'GOLD' or 'SILVER'

------------------------------------------------------------------ run context ----
declare @today       date = cast(getdate() as date);
declare @cy          int  = (select campaign_year from Layercake.ref_date_spine where [date] = @asof);
declare @silver_asof date = (select max([date]) from Layercake.silv_daily_count);
declare @has_anom    bit  = iif(object_id('Layercake.silv_data_anomaly') is not null, 1, 0);
declare @asof_txt    varchar(10) = convert(varchar(10), @asof, 23);

if @layercake_source not in ('GOLD', 'SILVER')
begin
    raiserror('@layercake_source must be GOLD or SILVER.', 16, 1);
    return;
end

if @cy is null
begin
    raiserror('The as-of date %s is not in Layercake.ref_date_spine - run the silver load first.', 16, 1, @asof_txt);
    return;
end

if @asof > @today
begin
    raiserror('The as-of date %s is in the future. Open-ended state ranges count through today only, so a future date cannot be reconciled.', 16, 1, @asof_txt);
    return;
end

-- re-runnable in the same session even after an aborted run
drop table if exists #src, #off, #src_agg, #cover, #cov_cells, #cohort, #anom_raw, #anom,
                     #rics, #bcontact, #trans, #enr_raw, #enr, #mb, #ev, #rng, #cov_agg,
                     #paid, #facts, #diff;


/*====================================================================
    1. THE OFFICIAL LIST, exactly as the agreed query defines it
====================================================================*/
select
    cast(c.Rics_contactno as nvarchar(200))          as contact_no,
    cast(c.MemberGrade_Description as nvarchar(350)) as member_grade,
    convert(nvarchar(100), c.Rics_LapsedCode)        as lapse_code,
    cast(c.StateCode as int)                         as state_code,
    cast(c.Rics_ElectionDate as date)                as election_date,
    cast(c.Rics_LapsedDate   as date)                as lapsed_date,
    cast(iif(c.MemberGrade_Description in ('Candidate', 'Qualified Professional',
                                           'Qualified Professional - 2 Years')
             and c.Rics_LapsedCode is null
             and c.StateCode = 0, 1, 0) as int)      as qualifies
into #src
from CE.vwContact c;

create clustered index cx_src on #src (contact_no);

declare @off_rows      int = (select count(*) from #src where qualifies = 1);
declare @off_null_rows int = (select count(*) from #src where qualifies = 1 and contact_no is null);

-- the official list collapsed to the contact NUMBER, which is the pipeline's key
select contact_no, count(*) as qualifying_rows
into #off
from #src
where qualifies = 1
  and contact_no is not null
group by contact_no;

create unique clustered index cx_off on #off (contact_no);

declare @off_distinct  int = (select count(*) from #off);
declare @off_dup_extra int = (select isnull(sum(qualifying_rows - 1), 0) from #off);

-- every source row per contact, so a Layercake-only contact can be explained
-- against source. The three official tests are carried SEPARATELY: a contact can
-- hold one row passing each of them and still have no single row that passes all
-- three, and the official query counts rows.
select
    s.contact_no,
    count(*)                                                    as src_rows,
    max(s.qualifies)                                            as qualifies,
    max(iif(s.member_grade in ('Candidate', 'Qualified Professional',
                               'Qualified Professional - 2 Years'), 1, 0)) as any_member_grade,
    max(iif(s.lapse_code is null, 1, 0))                        as any_null_lapse_code,
    max(iif(s.state_code = 0, 1, 0))                            as any_state_zero,
    max(s.member_grade)                                         as member_grade,
    max(s.lapse_code)                                           as lapse_code,
    min(s.state_code)                                           as state_code,
    min(s.election_date)                                        as election_date,
    min(s.lapsed_date)                                          as lapsed_date
into #src_agg
from #src s
where s.contact_no is not null
group by s.contact_no;

create unique clustered index cx_src_agg on #src_agg (contact_no);


/*====================================================================
    2. THE LAYERCAKE LIST on @asof, re-derived per contact with the
       exact join rule from step d of usp_load_silv_daily_count
    ------------------------------------------------------------------
    Half-open interval [valid_from, valid_to). Zero-length ranges (a
    same-day supersede) cover nothing; open-ended ranges count through
    today, which is why a future @asof is refused above.

    ALL covering ranges are kept, not just the winning one. The
    daily-count join groups by (region, grade) and counts distinct
    contacts per cell, so a contact holding two covering ranges in
    different cells is counted TWICE by the pipeline. #cov_cells
    reproduces that exactly: one row per contact carrying how many
    active cells it occupies. Its ROW COUNT is the contact list, its
    SUM is the number.

    The finer grain of silv_daily_count_detail adds country, gender and
    status, and none of them can add further duplication -
    silv_member_profile is keyed on contact_no, and status is a
    function of grade plus the retirement date. So (region, grade) is
    the whole story.
====================================================================*/
select r.contact_no, r.grade, r.region, r.valid_from, r.valid_to, r.state_seq
into #cover
from Layercake.silv_member_state_ranges r
where @asof >= r.valid_from
  and @asof <  isnull(r.valid_to, dateadd(day, 1, @asof));

create clustered index cx_cover on #cover (contact_no);

select v.contact_no, count(*) as active_cells
into #cov_cells
from (select distinct contact_no, region, grade from #cover where grade <> 'lapse') v
group by v.contact_no;

create unique clustered index cx_cov_cells on #cov_cells (contact_no);

declare @lc_distinct  int = (select count(*) from #cov_cells);
declare @lc_cells     int = (select isnull(sum(active_cells), 0) from #cov_cells);
declare @lc_overcount int = @lc_cells - @lc_distinct;

-- the stored numbers
declare @lc_silver int = isnull((select sum(active_count)
                                 from Layercake.silv_daily_count
                                 where [date] = @asof), 0);

declare @lc_gold   int = isnull((select sum(f.ActiveMembers)
                                 from Layercake.fact_daily_member_count_detail f
                                 join Layercake.dim_date d on d.id = f.date_id
                                 where d.[date] = @asof), 0);

declare @lc_anchor     int = iif(@layercake_source = 'GOLD', @lc_gold, @lc_silver);
declare @lc_drift      int = @lc_silver - @lc_cells;                                    -- B04
declare @lc_gold_delta int = iif(@layercake_source = 'GOLD', @lc_gold - @lc_silver, 0); -- B05

declare @difference int = @off_rows - @lc_anchor;


/*====================================================================
    3. THE COHORT = official list  U  Layercake list
       Everything below is staged for these contacts only.
====================================================================*/
select contact_no
into #cohort
from (
    select contact_no from #off
    union
    select contact_no from #cov_cells
) v;

create unique clustered index cx_cohort on #cohort (contact_no);


/*====================================================================
    4. THE GATES, one staging step per silver rule
====================================================================*/

-- 4a. bronze contact rows, and whether every one of them is a test record
select
    cast(c.Rics_contactno as nvarchar(200)) as contact_no,
    count(*)                                as bronze_contact_rows,
    sum(iif(t.contactid is null, 1, 0))     as bronze_nontest_rows
into #bcontact
from Layercake.brnz_contact c
join #cohort k on k.contact_no = c.Rics_contactno
-- left joined rather than tested with EXISTS inside the SUM: an aggregate
-- cannot contain a subquery. brnz_contact_test_record is keyed on contactid,
-- so this stays 1:1 and count(*) above still counts contact rows.
left join Layercake.brnz_contact_test_record t
       on  t.contactid   = c.ContactId
       and t._is_deleted = 0
where c._is_deleted    = 0
  and c.Rics_contactno is not null
group by cast(c.Rics_contactno as nvarchar(200));

create unique clustered index cx_bcontact on #bcontact (contact_no);

-- 4b. latest rics record per membership number - an EXACT copy of the
--     #rics_record staging inside usp_load_silv_member_base, test-record
--     exclusion included, so "has a rics record" means here exactly what it
--     means to the driver
select
    cast(v.apuk_ricsmembershipnumber as nvarchar(200)) as contact_no,
    cast(v.apuk_lapseddate           as date)          as rics_lapsed_date,
    cast(v.apuk_retirementdate       as date)          as rics_retirement_date,
    v.apuk_lapsecode                                   as rics_lapse_code,
    v.apuk_membergrade                                 as rics_grade
into #rics
from (
    select
        rec.apuk_ricsmembershipnumber,
        rec.apuk_lapseddate,
        rec.apuk_retirementdate,
        rec.apuk_lapsecode,
        rec.apuk_membergrade,
        row_number() over (partition by rec.apuk_ricsmembershipnumber order by rec.ModifiedOn desc) n
    from Layercake.brnz_rics_record rec
    where rec._is_deleted               = 0
      and rec.apuk_ricsmembershipnumber is not null
      and not exists (select 1
                      from Layercake.brnz_contact_test_record tst
                      where tst.contactid  = rec.apuk_contactid
                        and tst._is_deleted = 0)
) v
where v.n = 1;

create unique clustered index cx_rics on #rics (contact_no);

-- 4c. contacts whose Student grade the driver OVERRIDES: the Student status is
--     superseded in the enrolment history (latest Student application ended, a
--     qualifying row created on or after it). Read from the view the driver
--     itself stages, Layercake.vw_student_superseded, so the test here is the
--     driver's own
select cast(v.[Contact No] as nvarchar(200)) as contact_no
into #student_superseded
from Layercake.vw_student_superseded v;

create unique clustered index cx_student_superseded on #student_superseded (contact_no);

-- 4c. transaction history. The driver tests EXISTENCE only - no approved or
--     settled filter, that rule lives in the payment derivation.
select distinct cast(ct.accountnum as nvarchar(200)) as contact_no
into #trans
from Layercake.brnz_cust_trans ct
join #cohort k on k.contact_no = ct.accountnum
where ct._is_deleted = 0;

create unique clustered index cx_trans on #trans (contact_no);

-- 4d. raw enrolment rows (any row at all), which separates A07 from A08
select cast(e.[Contact No] as nvarchar(200)) as contact_no, count(*) as enrolment_rows
into #enr_raw
from Layercake.brnz_enrolment e
join #cohort k on k.contact_no = e.[Contact No]
where e._is_deleted = 0
group by cast(e.[Contact No] as nvarchar(200));

create unique clustered index cx_enr_raw on #enr_raw (contact_no);

-- 4e. QUALIFYING enrolment / election rows, read from the same view the driver
--     reads, so this test cannot drift from it.
--     latest_qualifying_date is the later of the two dates on each row, maxed
--     across rows - it is what A20 tests the lapse date against.
select
    cast(eb.[Contact No] as nvarchar(200)) as contact_no,
    count(*)                               as qualifying_rows,
    min(eb.enrolment_date)                 as first_enrolment_date,
    min(eb.election_date)                  as first_election_date,
    max(iif(eb.election_date > eb.enrolment_date or eb.enrolment_date is null,
            eb.election_date, eb.enrolment_date)) as latest_qualifying_date
into #enr
from Layercake.vw_enrolment_base eb
join #cohort k on k.contact_no = eb.[Contact No]
group by cast(eb.[Contact No] as nvarchar(200));

create unique clustered index cx_enr on #enr (contact_no);

-- 4f. the member base. One row per brnz_contact row, so aggregated - a contact
--     number shared by two contact records produces two.
select
    b.contact_no,
    count(*)                                             as base_rows,
    min(b.enrolment_date)                                as mb_enrolment_date,
    min(b.election_date)                                 as mb_election_date,
    max(b.contact_lapsed_date)                           as mb_contact_lapsed_date,
    max(b.lapsed_date)                                   as mb_lapsed_date,
    max(b.lapse_reason_name)                             as mb_lapse_reason,
    max(b.enrolment_from_exception + b.election_from_exception) as mb_from_exception
into #mb
from Layercake.silv_member_base b
join #cohort k on k.contact_no = b.contact_no
group by b.contact_no;

create unique clustered index cx_mb on #mb (contact_no);

-- 4g. events. Only Join / Change / Readmission open a state range.
select
    e.contact_no,
    count(*)                                                          as events,
    max(iif(e.event_type in ('Join', 'Change', 'Readmission'), 1, 0)) as has_range_event,
    max(iif(e.event_type = 'Readmission', 1, 0))                      as has_readmission,
    max(iif(e.event_type in ('Join', 'Change'), 1, 0))                as has_join_or_change,
    max(iif(e.event_type = 'Lapse', 1, 0))                            as has_lapse_event
into #ev
from Layercake.silv_membership_events e
join #cohort k on k.contact_no = e.contact_no
group by e.contact_no;

create unique clustered index cx_ev on #ev (contact_no);

-- 4h. every state range the contact has, covering @asof or not
select
    r.contact_no,
    count(*)          as state_ranges,
    min(r.valid_from) as first_valid_from,
    max(r.valid_from) as last_valid_from
into #rng
from Layercake.silv_member_state_ranges r
join #cohort k on k.contact_no = r.contact_no
group by r.contact_no;

create unique clustered index cx_rng on #rng (contact_no);

-- 4i. the covering ranges, summarised for display
select
    c.contact_no,
    count(*)                           as covering_ranges,
    max(iif(c.grade <> 'lapse', 1, 0)) as any_non_lapse,
    ltrim(rtrim(concat(iif(max(iif(c.grade = 'enrolment', 1, 0)) = 1, 'enrolment ', ''),
                       iif(max(iif(c.grade = 'election',  1, 0)) = 1, 'election ',  ''),
                       iif(max(iif(c.grade = 'lapse',     1, 0)) = 1, 'lapse ',     '')))) as covering_grades
into #cov_agg
from #cover c
join #cohort k on k.contact_no = c.contact_no
group by c.contact_no;

create unique clustered index cx_cov_agg on #cov_agg (contact_no);

-- 4j. counted PAID on @asof, using the same rule the daily count uses. A21 needs
--     it, and it is worth seeing on every row of the list.
select distinct p.contact_no
into #paid
from Layercake.silv_payment_events p
join #cover  c on c.contact_no = p.contact_no
join #cohort k on k.contact_no = p.contact_no
where p.campaign_year    = @cy
  and p.renewal_date_adj <= @asof;

create unique clustered index cx_paid on #paid (contact_no);

-- 4k. open anomalies, context only. The table is optional, so it is staged
--     through exec() and the string work is done outside it.
create table #anom_raw
(
    contact_no   nvarchar(200) collate database_default not null,
    anomaly_type varchar(40)   collate database_default not null,
    primary key (contact_no, anomaly_type)
);
if @has_anom = 1
    exec (N'insert into #anom_raw (contact_no, anomaly_type)
            select distinct contact_no, anomaly_type
            from Layercake.silv_data_anomaly
            where resolved_at is null');

select
    r.contact_no,
    left(stuff((select ', ' + a.anomaly_type
                from #anom_raw a
                where a.contact_no = r.contact_no
                order by a.anomaly_type
                for xml path(''), type).value('.', 'nvarchar(max)'), 1, 2, ''), 200) as anomaly_types
into #anom
from (select distinct contact_no from #anom_raw) r;

create unique clustered index cx_anom on #anom (contact_no);


/*====================================================================
    5. ONE FACT ROW PER DIVERGING CONTACT
       Every gate expressed as a value, so section 6 can both PICK the
       first failure and LIST every reason that applies. Contacts the
       two lists agree on drop out here.
====================================================================*/
select
    k.contact_no,
    cast(iif(o.contact_no  is not null, 1, 0) as bit) as in_official,
    cast(iif(cc.contact_no is not null, 1, 0) as bit) as in_layercake,
    isnull(cc.active_cells, 0)                        as active_cells,

    -- source side
    isnull(sa.src_rows, 0)            as src_rows,
    sa.member_grade                   as src_member_grade,
    sa.lapse_code                     as src_lapse_code,
    sa.state_code                     as src_state_code,
    sa.election_date                  as src_election_date,
    sa.lapsed_date                    as src_lapsed_date,
    isnull(sa.any_member_grade, 0)    as any_member_grade,
    isnull(sa.any_null_lapse_code, 0) as any_null_lapse_code,
    isnull(sa.any_state_zero, 0)      as any_state_zero,

    -- bronze / driver side
    isnull(bc.bronze_contact_rows, 0) as bronze_contact_rows,
    isnull(bc.bronze_nontest_rows, 0) as bronze_nontest_rows,
    cast(iif(rr.contact_no is not null, 1, 0) as bit) as has_rics_record,
    rr.rics_grade,
    rr.rics_lapse_code,
    rr.rics_lapsed_date,
    cast(iif(tr.contact_no is not null, 1, 0) as bit) as has_transactions,

    -- silver side
    isnull(mb.base_rows, 0)           as base_rows,
    mb.mb_enrolment_date,
    mb.mb_election_date,
    mb.mb_contact_lapsed_date,
    mb.mb_lapsed_date,
    mb.mb_lapse_reason,
    isnull(mb.mb_from_exception, 0)   as mb_from_exception,
    isnull(er.enrolment_rows, 0)      as enrolment_rows,
    isnull(en.qualifying_rows, 0)     as qualifying_enrolment_rows,
    en.latest_qualifying_date,
    isnull(ev.events, 0)              as events,
    isnull(ev.has_range_event, 0)     as has_range_event,
    isnull(ev.has_readmission, 0)     as has_readmission,
    isnull(ev.has_join_or_change, 0)  as has_join_or_change,
    isnull(ev.has_lapse_event, 0)     as has_lapse_event,
    isnull(rg.state_ranges, 0)        as state_ranges,
    rg.first_valid_from,
    isnull(ca.covering_ranges, 0)     as covering_ranges,
    isnull(ca.covering_grades, '')    as covering_grades,
    cast(iif(pd.contact_no is not null, 1, 0) as bit) as paid_on_asof,
    an.anomaly_types
into #facts
from #cohort k
left join #off       o  on o.contact_no  = k.contact_no
left join #cov_cells cc on cc.contact_no = k.contact_no
left join #src_agg   sa on sa.contact_no = k.contact_no
left join #bcontact  bc on bc.contact_no = k.contact_no
left join #rics      rr on rr.contact_no = k.contact_no
left join #trans     tr on tr.contact_no = k.contact_no
left join #mb        mb on mb.contact_no = k.contact_no
left join #enr_raw   er on er.contact_no = k.contact_no
left join #enr       en on en.contact_no = k.contact_no
left join #ev        ev on ev.contact_no = k.contact_no
left join #rng       rg on rg.contact_no = k.contact_no
left join #cov_agg   ca on ca.contact_no = k.contact_no
left join #paid      pd on pd.contact_no = k.contact_no
left join #anom      an on an.contact_no = k.contact_no
where o.contact_no is null            -- in Layercake only
   or cc.contact_no is null;          -- in the official list only

create unique clustered index cx_facts on #facts (contact_no);


/*====================================================================
    6. THE LIST
====================================================================*/
create table #diff
(
    direction                 varchar(26)    not null,
    count_impact              int            not null,
    reason_code               varchar(4)     not null,
    reason                    nvarchar(1000) not null,
    all_reasons               varchar(120)   null,
    contact_no                nvarchar(200)  collate database_default null,
    src_member_grade          nvarchar(350)  null,
    src_lapse_code            nvarchar(100)  null,
    src_state_code            int            null,
    src_lapsed_date           date           null,
    src_election_date         date           null,
    src_rows                  int            null,
    bronze_contact_rows       int            null,
    bronze_nontest_rows       int            null,
    has_rics_record           bit            null,
    rics_grade                int            null,
    rics_lapse_code           int            null,
    rics_lapsed_date          date           null,
    has_transactions          bit            null,
    base_rows                 int            null,
    mb_enrolment_date         date           null,
    mb_election_date          date           null,
    mb_contact_lapsed_date    date           null,
    mb_lapsed_date            date           null,
    mb_lapse_reason           nvarchar(700)  null,
    mb_from_exception         int            null,
    enrolment_rows            int            null,
    qualifying_enrolment_rows int            null,
    latest_qualifying_date    date           null,
    events                    int            null,
    has_range_event           int            null,
    has_readmission           int            null,
    state_ranges              int            null,
    first_valid_from          date           null,
    covering_ranges           int            null,
    covering_grades           varchar(50)    null,
    active_cells              int            null,
    paid_on_asof              bit            null,
    anomaly_types             varchar(200)   null
);

/*--------------------------------------------------------------------
    6a. IN THE OFFICIAL LIST, NOT IN THE LAYERCAKE NUMBER   (+1 each)
        The flags are evaluated independently so all_reasons can carry
        more than one; the CASE below picks the first in pipeline order
        as the primary code.
--------------------------------------------------------------------*/
insert into #diff
(direction, count_impact, reason_code, reason, all_reasons, contact_no,
 src_member_grade, src_lapse_code, src_state_code, src_lapsed_date, src_election_date, src_rows,
 bronze_contact_rows, bronze_nontest_rows, has_rics_record, rics_grade, rics_lapse_code,
 rics_lapsed_date, has_transactions, base_rows, mb_enrolment_date, mb_election_date,
 mb_contact_lapsed_date, mb_lapsed_date, mb_lapse_reason, mb_from_exception, enrolment_rows,
 qualifying_enrolment_rows, latest_qualifying_date, events, has_range_event, has_readmission,
 state_ranges, first_valid_from, covering_ranges, covering_grades, active_cells, paid_on_asof,
 anomaly_types)
select
    'IN_OFFICIAL_NOT_LAYERCAKE',
    1,
    g.code,
    g.reason,
    nullif(stuff(concat(
        iif(x.f01 = 1, ', A01', ''), iif(x.f02 = 1, ', A02', ''), iif(x.f03 = 1, ', A03', ''),
        iif(x.f04 = 1, ', A04', ''), iif(x.f05 = 1, ', A05', ''), iif(x.f06 = 1, ', A06', ''),
        iif(x.f07 = 1, ', A07', ''), iif(x.f08 = 1, ', A08', ''), iif(x.f09 = 1, ', A09', ''),
        iif(x.f10 = 1, ', A10', ''), iif(x.f11 = 1, ', A11', ''), iif(x.f12 = 1, ', A12', ''),
        iif(x.f13 = 1, ', A13', ''), iif(x.f20 = 1, ', A20', ''), iif(x.f21 = 1, ', A21', ''),
        iif(x.f22 = 1, ', A22', ''), iif(y.f23 = 1, ', A23', '')), 1, 2, ''), ''),
    f.contact_no,
    f.src_member_grade, f.src_lapse_code, f.src_state_code, f.src_lapsed_date, f.src_election_date, f.src_rows,
    f.bronze_contact_rows, f.bronze_nontest_rows, f.has_rics_record, f.rics_grade, f.rics_lapse_code,
    f.rics_lapsed_date, f.has_transactions, f.base_rows, f.mb_enrolment_date, f.mb_election_date,
    f.mb_contact_lapsed_date, f.mb_lapsed_date, f.mb_lapse_reason, f.mb_from_exception, f.enrolment_rows,
    f.qualifying_enrolment_rows, f.latest_qualifying_date, f.events, f.has_range_event, f.has_readmission,
    f.state_ranges, f.first_valid_from, f.covering_ranges, f.covering_grades, f.active_cells, f.paid_on_asof,
    f.anomaly_types
from #facts f
cross apply (select
    -- driver gates, in the order usp_load_silv_member_base applies them
    iif(f.bronze_contact_rows = 0, 1, 0)                                                   as f01,
    iif(f.bronze_contact_rows > 0 and f.bronze_nontest_rows = 0, 1, 0)                     as f02,
    iif(f.bronze_nontest_rows > 0 and f.has_rics_record = 0, 1, 0)                         as f03,
    iif(f.has_rics_record = 1 and isnull(f.rics_grade, 0) = 200000003
        and not exists (select 1 from #student_superseded ss
                        where ss.contact_no = f.contact_no), 1, 0)                         as f04,
    iif(f.bronze_nontest_rows > 0 and f.has_transactions = 0, 1, 0)                        as f05,
    iif(f.bronze_nontest_rows > 0 and f.has_rics_record = 1 and f.has_transactions = 1
        and (   isnull(f.rics_grade, 0) <> 200000003
             or exists (select 1 from #student_superseded ss
                        where ss.contact_no = f.contact_no))
        and f.base_rows = 0, 1, 0)                                                         as f06,
    -- date gates
    iif(f.base_rows > 0 and f.mb_enrolment_date is null and f.mb_election_date is null
        and f.enrolment_rows = 0, 1, 0)                                                    as f07,
    iif(f.base_rows > 0 and f.mb_enrolment_date is null and f.mb_election_date is null
        and f.enrolment_rows > 0 and f.qualifying_enrolment_rows = 0, 1, 0)                as f08,
    iif(f.base_rows > 0 and f.mb_enrolment_date is null and f.mb_election_date is null
        and f.qualifying_enrolment_rows > 0, 1, 0)                                         as f09,
    -- event and range gates
    iif(f.base_rows > 0 and (f.mb_enrolment_date is not null or f.mb_election_date is not null)
        and f.has_range_event = 0, 1, 0)                                                   as f10,
    iif(f.has_range_event = 1 and f.state_ranges = 0, 1, 0)                                as f11,
    iif(f.state_ranges > 0 and f.covering_ranges = 0 and f.first_valid_from > @asof, 1, 0) as f12,
    iif(f.state_ranges > 0 and f.covering_ranges = 0
        and isnull(f.first_valid_from, @asof) <= @asof, 1, 0)                              as f13,
    -- the covering state is a lapse. Three readings of it, independent of each
    -- other, because one contact can carry more than one at once.
    iif(f.covering_ranges > 0 and f.mb_contact_lapsed_date is not null
        and f.latest_qualifying_date > f.mb_contact_lapsed_date, 1, 0)                     as f20,
    iif(f.covering_ranges > 0 and f.paid_on_asof = 1, 1, 0)                                as f21,
    iif(f.covering_ranges > 0 and f.mb_contact_lapsed_date is not null, 1, 0)              as f22
) x
cross apply (select
    iif(f.covering_ranges > 0 and x.f20 = 0 and x.f21 = 0 and x.f22 = 0, 1, 0)             as f23
) y
cross apply (select
    case
        when x.f01 = 1 then 'A01' when x.f02 = 1 then 'A02' when x.f03 = 1 then 'A03'
        when x.f04 = 1 then 'A04' when x.f05 = 1 then 'A05' when x.f06 = 1 then 'A06'
        when x.f07 = 1 then 'A07' when x.f08 = 1 then 'A08' when x.f09 = 1 then 'A09'
        when x.f10 = 1 then 'A10' when x.f11 = 1 then 'A11' when x.f12 = 1 then 'A12'
        when x.f13 = 1 then 'A13' when x.f20 = 1 then 'A20' when x.f21 = 1 then 'A21'
        when x.f22 = 1 then 'A22' when y.f23 = 1 then 'A23'
        else 'A99'
    end as code,
    case
        when x.f01 = 1 then N'No brnz_contact row for this contact number - source has moved since the last bronze load. Re-run the bronze load and re-check.'
        when x.f02 = 1 then N'Every brnz_contact row for this number is flagged as a test record, so the silv_member_base driver excludes it.'
        when x.f03 = 1 then N'No brnz_rics_record row at all - no grade, lapse code or retirement date behind the contact, so it is not a member by the source definition and the silv_member_base driver excludes it. Logged as NO_RICS_RECORD in silv_data_anomaly.'
        when x.f04 = 1 then N'The latest rics record is Student grade (200000003), excluded from the silv_member_base driver by the agreed Rules to note #2. Not overridden: no ended Student application with a qualifying enrolment/election row created on or after it (vw_student_superseded).'
        when x.f05 = 1 then N'No brnz_cust_trans row at all - the contact has never transacted, so the silv_member_base driver excludes it and it counts as neither active nor paid. Logged as NO_TRANSACTIONS where a valid enrolment exists behind it.'
        when x.f06 = 1 then N'Passes every silv_member_base driver test but has no member base row. Unexpected - re-run usp_load_silv_member_base and re-check.'
        when x.f07 = 1 then N'No brnz_enrolment row at all, and no ref_enrolment_exception fallback date, so no enrolment or election date could be derived.'
        when x.f08 = 1 then N'brnz_enrolment rows exist but none survives the rules in vw_enrolment_base (route allowlist, application-type exclusions, ended-without-election, 14-day cool-off), and no fallback date exists.'
        when x.f09 = 1 then N'Qualifying enrolment rows exist but no effective enrolment or election date reached silv_member_base. Check the per-contact aggregate in usp_load_silv_member_base.'
        when x.f10 = 1 then N'Dates exist on silv_member_base but no Join / Change / Readmission event was emitted, so nothing opened a state range.'
        when x.f11 = 1 then N'Range-opening events exist but no state range was built. Re-run usp_load_silv_member_state_ranges.'
        when x.f12 = 1 then N'The earliest state range starts after the as-of date - a future-dated enrolment. The contact becomes active on that date, not before.'
        when x.f13 = 1 then N'State ranges exist but none covers the as-of date - closed before it, or zero-length from a same-day supersede.'
        when x.f20 = 1 then N'Counted as lapsed, but a qualifying enrolment or election POSTDATES the lapse date. silv_member_base tests the lapse against the EARLIEST enrolment, so a member who lapsed and then re-enrolled keeps their Lapse and the stale lapse date stands.'
        when x.f21 = 1 then N'Counted as lapsed on a date the contact is also counted PAID for this campaign year - the two readings contradict each other on the same contact, same date.'
        when x.f22 = 1 then N'Counted as lapsed from the contact lapse DATE, while source carries no lapse CODE - so the agreed query keeps the contact and the pipeline drops it. Neither Rics_LapsedCode nor StateCode is landed in bronze, so this cannot be closed by a rule change here.'
        when y.f23 = 1 then N'Counted as lapsed by the pipeline, with no contradicting evidence found on the contact.'
        else N'In the official list, not in the Layercake number, and none of the known gates explains it. Extend the rule set in section 6a before quoting this list as complete.'
    end as reason
) g
where f.in_official  = 1
  and f.in_layercake = 0;

/*--------------------------------------------------------------------
    6b. IN THE LAYERCAKE NUMBER, NOT IN THE OFFICIAL LIST   (-1 each)
        The pipeline lost nothing here - the official query excluded
        the contact - so the codes name the mechanism, not a gate.
--------------------------------------------------------------------*/
insert into #diff
(direction, count_impact, reason_code, reason, all_reasons, contact_no,
 src_member_grade, src_lapse_code, src_state_code, src_lapsed_date, src_election_date, src_rows,
 bronze_contact_rows, bronze_nontest_rows, has_rics_record, rics_grade, rics_lapse_code,
 rics_lapsed_date, has_transactions, base_rows, mb_enrolment_date, mb_election_date,
 mb_contact_lapsed_date, mb_lapsed_date, mb_lapse_reason, mb_from_exception, enrolment_rows,
 qualifying_enrolment_rows, latest_qualifying_date, events, has_range_event, has_readmission,
 state_ranges, first_valid_from, covering_ranges, covering_grades, active_cells, paid_on_asof,
 anomaly_types)
select
    'IN_LAYERCAKE_NOT_OFFICIAL',
    -1,
    g.code,
    g.reason,
    nullif(stuff(concat(
        iif(x.f01 = 1, ', X01', ''), iif(x.f02 = 1, ', X02', ''), iif(x.f03 = 1, ', X03', ''),
        iif(x.f10 = 1, ', X10', ''), iif(x.f11 = 1, ', X11', ''), iif(x.f12 = 1, ', X12', ''),
        iif(x.f13 = 1, ', X13', ''), iif(x.f15 = 1, ', X15', ''), iif(x.f14 = 1, ', X14', ''),
        iif(x.f17 = 1, ', X17', ''), iif(y.f16 = 1, ', X16', ''), iif(x.f20 = 1, ', X20', ''),
        iif(x.f98 = 1, ', X98', '')), 1, 2, ''), ''),
    f.contact_no,
    f.src_member_grade, f.src_lapse_code, f.src_state_code, f.src_lapsed_date, f.src_election_date, f.src_rows,
    f.bronze_contact_rows, f.bronze_nontest_rows, f.has_rics_record, f.rics_grade, f.rics_lapse_code,
    f.rics_lapsed_date, f.has_transactions, f.base_rows, f.mb_enrolment_date, f.mb_election_date,
    f.mb_contact_lapsed_date, f.mb_lapsed_date, f.mb_lapse_reason, f.mb_from_exception, f.enrolment_rows,
    f.qualifying_enrolment_rows, f.latest_qualifying_date, f.events, f.has_range_event, f.has_readmission,
    f.state_ranges, f.first_valid_from, f.covering_ranges, f.covering_grades, f.active_cells, f.paid_on_asof,
    f.anomaly_types
from #facts f
cross apply (select
    iif(f.src_rows = 0, 1, 0)                                                             as f01,
    iif(f.src_rows > 0 and f.any_member_grade = 0, 1, 0)                                  as f02,
    iif(f.src_rows > 0 and f.any_state_zero   = 0, 1, 0)                                  as f03,
    -- the lapse-code cohort, split by the mechanism that hides the exit from
    -- the pipeline. any_null_lapse_code = 0 means EVERY source row carries a
    -- lapse code, which is what the official query excludes on.
    iif(f.src_rows > 0 and f.any_null_lapse_code = 0 and f.src_lapsed_date is null
        and f.rics_lapsed_date is null and isnull(f.rics_lapse_code, -1) = 200000000, 1, 0) as f10,
    iif(f.src_rows > 0 and f.any_null_lapse_code = 0 and f.src_lapsed_date is null
        and f.rics_lapsed_date is null and isnull(f.rics_lapse_code, -1) = 200000001, 1, 0) as f11,
    iif(f.src_rows > 0 and f.any_null_lapse_code = 0 and f.src_lapsed_date is null
        and f.rics_lapsed_date is null
        and isnull(f.rics_lapse_code, -1) not in (200000000, 200000001), 1, 0)            as f12,
    iif(f.src_rows > 0 and f.any_null_lapse_code = 0
        and f.src_lapsed_date is null and f.rics_lapsed_date is not null, 1, 0)           as f13,
    iif(f.src_rows > 0 and f.any_null_lapse_code = 0
        and f.mb_contact_lapsed_date is not null and f.mb_lapsed_date is null, 1, 0)      as f14,
    iif(f.src_rows > 0 and f.any_null_lapse_code = 0 and f.src_lapsed_date > @asof, 1, 0) as f15,
    iif(f.src_rows > 0 and f.any_null_lapse_code = 0 and f.src_lapsed_date is not null
        and f.src_lapsed_date <= @asof and f.mb_contact_lapsed_date is null, 1, 0)        as f17,
    -- secondary reason: reported in all_reasons, never chosen as the primary code
    iif(f.has_readmission = 1 and f.has_join_or_change = 0, 1, 0)                         as f20,
    iif(f.src_rows > 0 and f.any_member_grade = 1 and f.any_null_lapse_code = 1
        and f.any_state_zero = 1, 1, 0)                                                  as f98
) x
cross apply (select
    iif(f.src_rows > 0 and f.any_null_lapse_code = 0
        and x.f10 + x.f11 + x.f12 + x.f13 + x.f14 + x.f15 + x.f17 = 0, 1, 0)             as f16
) y
cross apply (select
    case
        when x.f01 = 1 then 'X01' when x.f02 = 1 then 'X02' when x.f03 = 1 then 'X03'
        when x.f10 = 1 then 'X10' when x.f11 = 1 then 'X11' when x.f12 = 1 then 'X12'
        when x.f13 = 1 then 'X13' when x.f15 = 1 then 'X15' when x.f14 = 1 then 'X14'
        when x.f17 = 1 then 'X17' when y.f16 = 1 then 'X16' when x.f98 = 1 then 'X98'
        else 'X99'
    end as code,
    case
        when x.f01 = 1 then N'No CE.vwContact row at all for this contact number - bronze is holding a contact source has dropped. Re-run the bronze load; if it persists, the soft-delete sweep is not seeing the deletion.'
        when x.f02 = 1 then N'No source row carries one of the three member grades, so the official query excludes the contact. The pipeline never reads MemberGrade_Description - it reads the rics-record grade, and only to exclude Student.'
        when x.f03 = 1 then N'No source row carries StateCode = 0. StateCode is not landed in bronze at all, so the pipeline cannot apply this part of the official filter.'
        when x.f10 = 1 then N'Rics record lapse code 200000000 (Deceased) with NO lapse date anywhere. Source knows the contact is out; the pipeline has no date to exit them on, so it can neither drop them today nor restate history. Needs a date landed in source, or an agreed convention.'
        when x.f11 = 1 then N'Rics record lapse code 200000001 (Duplicate) with NO lapse date anywhere - same mechanism as X10.'
        when x.f12 = 1 then N'The rics record carries a lapse code with NO lapse date anywhere - same mechanism as X10.'
        when x.f13 = 1 then N'brnz_rics_record carries a lapsed date but brnz_contact.Rics_LapsedDate is null. The Lapse event reads the CONTACT date only, so the rics-record date is invisible to it.'
        when x.f15 = 1 then N'The contact lapse date is AFTER the as-of date, so the pipeline is right to still count the contact here. The official query has no as-of dimension and lapses them on the code alone.'
        when x.f14 = 1 then N'Contact lapse date present but invalidated by the stale-lapse rule - the member enrolled or was elected after the lapse date, so silv_member_base nulls the lapse and no Lapse event is emitted.'
        when x.f17 = 1 then N'Source carries a lapse date on or before the as-of date that bronze has not landed yet. Re-run the bronze load and re-check.'
        when y.f16 = 1 then N'Source carries a lapse code, but none of the known mechanisms explains why the pipeline did not act on it. Extend the rule set in section 6b.'
        when x.f98 = 1 then N'The contact holds source rows passing each of the three official tests, but no SINGLE row passes all three - the official query counts rows, not contacts.'
        else N'Counted by the pipeline, excluded by the official query, and no mechanism identified. Extend the rule set in section 6b before quoting this list as complete.'
    end as reason
) g
where f.in_official  = 0
  and f.in_layercake = 1;

/*--------------------------------------------------------------------
    6c. THE BRIDGE ROWS
        Differences that are not contact-level membership at all.
        These are what close the identity between a ROW count on the
        source side and a CELL total on the Layercake side.
--------------------------------------------------------------------*/

-- B01: official rows with no contact number. The agreed query counts them and the
--      pipeline keys on the contact number throughout, so they can never match.
insert into #diff (direction, count_impact, reason_code, reason, all_reasons)
select 'IN_OFFICIAL_NOT_LAYERCAKE', 1, 'B01',
       N'Official row with a NULL Rics_contactno. The agreed query counts rows, and every Layercake table keys on the contact number, so this row can never reach the Layercake number.',
       'B01'
from #src
where qualifies  = 1
  and contact_no is null;

-- B02: one row per EXTRA official row sharing a contact number. The agreed query
--      counts rows; every Layercake number counts contacts.
insert into #diff (direction, count_impact, reason_code, reason, all_reasons, contact_no,
                   src_member_grade, src_lapse_code, src_state_code, src_rows)
select 'IN_OFFICIAL_NOT_LAYERCAKE', 1, 'B02',
       N'Duplicate contact number in the official list: this contact holds more than one qualifying CE.vwContact row. The agreed query counts rows and the Layercake number counts contacts, so each extra row is one unit of difference.',
       'B02', o.contact_no, sa.member_grade, sa.lapse_code, sa.state_code, o.qualifying_rows
from #off o
join #src_agg sa on sa.contact_no = o.contact_no
cross apply (select top (case when o.qualifying_rows > 1 then o.qualifying_rows - 1 else 0 end)
                    1 as n
             from sys.all_columns) rep
where o.qualifying_rows > 1;

-- B03: one row per EXTRA active cell a contact occupies. The daily-count join
--      groups by (region, grade) and counts distinct contacts per cell, so a
--      contact with two covering non-lapse ranges in different cells is counted
--      twice. A correctly chained contact has exactly one covering range.
insert into #diff (direction, count_impact, reason_code, reason, all_reasons, contact_no,
                   state_ranges, covering_ranges, covering_grades, active_cells)
select 'IN_LAYERCAKE_NOT_OFFICIAL', -1, 'B03',
       N'Overlapping state ranges: this contact occupies more than one region/grade cell on the as-of date, so the daily-count join counts it more than once. A correctly chained contact has exactly one covering range - re-run usp_load_silv_member_state_ranges and check the event chain.',
       'B03', cc.contact_no, rg.state_ranges, ca.covering_ranges, ca.covering_grades, cc.active_cells
from #cov_cells cc
left join #rng     rg on rg.contact_no = cc.contact_no
left join #cov_agg ca on ca.contact_no = cc.contact_no
cross apply (select top (case when cc.active_cells > 1 then cc.active_cells - 1 else 0 end)
                    1 as n
             from sys.all_columns) rep
where cc.active_cells > 1;

-- B04: stored silv_daily_count versus the per-contact re-derivation above.
--      Expected to be zero on @asof = today, which is rebuilt on every run. On a
--      past date it is the forward-only load showing through - the stored value
--      records what source said when the date was FIRST loaded.
insert into #diff (direction, count_impact, reason_code, reason, all_reasons)
select iif(@lc_drift < 0, 'IN_OFFICIAL_NOT_LAYERCAKE', 'IN_LAYERCAKE_NOT_OFFICIAL'),
       -@lc_drift, 'B04',
       concat(N'Stored silv_daily_count on this date is ', @lc_silver,
              N', but re-deriving it per contact from the current silver tables gives ', @lc_cells,
              N'. silv_daily_count is FORWARD ONLY - a date already in etl_daily_count_loaded is never re-derived by a daily run - so on a past date this is the point-in-time record showing through. On today it should be zero. Remedy: exec Layercake.usp_load_silver @RebuildFrom = ''',
              convert(varchar(10), @asof, 23), N'''.'),
       'B04'
where @lc_drift <> 0;

-- B05: gold behind silver. Only ever raised when anchored on GOLD, since the star
--      is a straight SUM of silv_daily_count_detail and should equal it.
insert into #diff (direction, count_impact, reason_code, reason, all_reasons)
select iif(@lc_gold_delta < 0, 'IN_OFFICIAL_NOT_LAYERCAKE', 'IN_LAYERCAKE_NOT_OFFICIAL'),
       -@lc_gold_delta, 'B05',
       concat(N'The gold star carries ', @lc_gold, N' on this date and silver carries ', @lc_silver,
              N'. fact_daily_member_count_detail is a straight SUM of silv_daily_count_detail, so they should agree. Remedy: exec Layercake.usp_load_gold.'),
       'B05'
where @lc_gold_delta <> 0;


/*====================================================================
    7. OUTPUT
====================================================================*/
declare @impact_sum int = (select isnull(sum(count_impact), 0) from #diff);

-- RS-0: run context
select
    'RS-0 run context'              as result_set,
    @asof                           as asof_date,
    @cy                             as campaign_year,
    @layercake_source               as layercake_source,
    @silver_asof                    as silver_loaded_through,
    iif(@asof = @today, 'yes',
        'NO - the source side is current-state, so this compares today''s source membership against a historical pipeline state')
                                    as asof_is_today,
    iif(@has_anom = 1, 'yes', 'no') as anomaly_table_present;

-- RS-1: the assertion. Read this first; if it is not PASS, nothing below is safe
-- to quote.
select
    'RS-1 count reconciliation'  as result_set,
    @off_rows                    as official_active,
    @lc_anchor                   as layercake_active,
    @difference                  as difference,
    @impact_sum                  as sum_of_count_impact,
    (select count(*) from #diff) as rows_in_list,
    iif(@impact_sum = @difference,
        'PASS - the list accounts for every unit of the difference',
        'FAIL - the list does not net to the difference; do not use it until this reads PASS')
                                 as verdict;

-- RS-2: the bridge, line by line
select 'RS-2 bridge' as result_set, seq, step, value, note
from (values
    ( 1, 'Official active (rows in CE.vwContact)',       @off_rows,       'The agreed query, exactly as written'),
    ( 2, '  less rows with no contact number (B01)',     -@off_null_rows, 'Cannot be keyed to the pipeline'),
    ( 3, '  less extra rows on a shared number (B02)',   -@off_dup_extra, 'The agreed query counts rows, not contacts'),
    ( 4, '= Official active contacts',                   @off_distinct,   'Distinct contact numbers'),
    ( 5, 'Layercake active contacts',                    @lc_distinct,    'Distinct contacts with a covering non-lapse range'),
    ( 6, '  contact-level difference',                   @off_distinct - @lc_distinct,
                                                                          'Equals the (+1) rows minus the (-1) rows in the list'),
    ( 7, 'Layercake active contacts',                    @lc_distinct,    ''),
    ( 8, '  plus extra region/grade cells (B03)',        @lc_overcount,   'Overlapping state ranges counted more than once'),
    ( 9, '= Re-derived cell total',                      @lc_cells,       'What the daily-count join produces from current silver'),
    (10, '  plus stored-vs-derived drift (B04)',         @lc_drift,       'Forward-only load; zero on today'),
    (11, '= silv_daily_count on the as-of date',         @lc_silver,      ''),
    (12, '  plus gold behind silver (B05)',              @lc_gold_delta,  'Only applied when anchored on GOLD'),
    (13, '= Layercake active (the anchor)',              @lc_anchor,      'The number this list reconciles to')
) v(seq, step, value, note)
order by seq;

-- RS-3: reason summary
select
    'RS-3 reasons'               as result_set,
    d.direction,
    d.reason_code,
    count(*)                     as rows_in_list,
    count(distinct d.contact_no) as contacts,
    sum(d.count_impact)          as count_impact,
    min(d.reason)                as reason
from #diff d
group by d.direction, d.reason_code
order by sum(d.count_impact) desc, d.reason_code;

-- RS-4: THE LIST. One row per unit of difference.
select
    'RS-4 list'  as result_set,
    d.direction,
    d.count_impact,
    d.reason_code,
    d.all_reasons,
    d.contact_no,
    d.reason,
    d.src_member_grade,
    d.src_lapse_code,
    d.src_state_code,
    d.src_lapsed_date,
    d.src_election_date,
    d.src_rows,
    d.bronze_contact_rows,
    d.bronze_nontest_rows,
    d.has_rics_record,
    d.rics_grade,
    d.rics_lapse_code,
    d.rics_lapsed_date,
    d.has_transactions,
    d.base_rows,
    d.mb_enrolment_date,
    d.mb_election_date,
    d.mb_contact_lapsed_date,
    d.mb_lapsed_date,
    d.mb_lapse_reason,
    d.mb_from_exception,
    d.enrolment_rows,
    d.qualifying_enrolment_rows,
    d.latest_qualifying_date,
    d.events,
    d.has_range_event,
    d.has_readmission,
    d.state_ranges,
    d.first_valid_from,
    d.covering_ranges,
    d.covering_grades,
    d.active_cells,
    d.paid_on_asof,
    d.anomaly_types
from #diff d
order by d.direction, d.reason_code, d.contact_no;

drop table if exists #src, #off, #src_agg, #cover, #cov_cells, #cohort, #anom_raw, #anom,
                     #rics, #bcontact, #trans, #enr_raw, #enr, #mb, #ev, #rng, #cov_agg,
                     #paid, #facts, #diff;
go

/*************************************************************************************
    Layercake PAID MEMBER difference list  (both paid measures)
    ---------------------------------------------------------------------------------
    PURPOSE
    One list that accounts for EVERY unit of difference between the official paid
    member count and the Layercake paid member counts on a given date - contact by
    contact, with the reason(s) each contact is on it.

    The pipeline carries TWO independent readings of "how many members have paid",
    side by side. This script reconciles BOTH against the same official query, each
    with its own guaranteed identity, then compares the two measures against each
    other.

        OFFICIAL PAID  (agreed definition - doc: 'Queries to get current snapshot of
                        active and paid member counts')
            select count(*) from Subs.vwSubsMemberStatuses
            where [Campaign Year] = @current_cy
              and [Member Invoice Position] in ('Full Concession','Fully Paid',
                                                'Partially Paid','Pre-Subs Payment')

        measure = 'PAYMENT'   the payment-driven measure
            @layercake_source = 'GOLD'    sum(PaidMembers) from
                                          fact_daily_member_count_detail on @asof
            @layercake_source = 'SILVER'  sum(paid_count) from
                                          silv_daily_count on @asof

        measure = 'EVENT'     the event-driven measure
            @layercake_source = 'GOLD'    sum(PaidMembersEvent)
            @layercake_source = 'SILVER'  sum(paid_count_event)

    ---------------------------------------------------------------------------------
    THE TWO MEASURES, AND WHY THEY DIFFER

    PAYMENT reads the subs invoice position - the same data the official query
    reads - so it is the measure the official number is really about. A contact is
    paid from the adjusted renewal date of their paid position for the campaign year.

    EVENT reads silv_membership_events instead: a contact is paid from the earliest
    Join / Renewal / Readmission event in the campaign year, and stays counted for
    the rest of it. Two consequences drive nearly every divergence:

      * JOIN IS AN EVENT, NOT A PAYMENT. It is enrolment-dated for Candidates and
        election-dated for RPQ direct entries, so a member who joined this campaign
        year is counted by EVENT before any money moves. This is the designed
        difference in a member's first year, and the main reason EVENT runs ahead.
      * LAPSING DOES NOT DEDUCT. A member who paid and then lapsed still paid, so
        EVENT is monotonic within a campaign year. PAYMENT stops at a lapse through
        its state-range gate.

    They are NOT expected to agree - carrying both is the point. RS-5 and RS-6 put
    them side by side and name the mechanism behind every contact that differs.
    Full rules in the header of usp_load_silv_daily_count and in
    'Two paid member counts' in database/README.md.

    ---------------------------------------------------------------------------------
    THE GUARANTEE

    Every row of the list carries a measure and a signed count_impact:

        +1   the contact is in the official list and NOT in that Layercake measure
        -1   the contact is in that Layercake measure and NOT in the official list

    and a handful of BRIDGE rows per measure carry the differences that are not
    contact-level membership at all - a source row with no contact number, a contact
    holding two source rows for the campaign year, a contact counted twice by an
    overlapping state range, stored-vs-derived drift, gold behind silver.

        sum(count_impact) WITHIN EACH MEASURE
            ==  official count - that measure's Layercake count

    RS-1 asserts that for both measures and prints PASS or FAIL for each. If either
    says FAIL, do not use that measure's list - something below has stopped being
    true.

    ---------------------------------------------------------------------------------
    HOW EACH NUMBER IS BRIDGED  (RS-2 walks both, line by line)

        official count            count(*) over Subs.vwSubsMemberStatuses rows
          - rows with no contact number          B01   (+1 each)
          - extra rows on the same contact+year  B02   (+1 each)
        = official contacts                      distinct contact numbers

        official contacts - Layercake contacts   = (+1 rows) - (-1 rows)

        Layercake contacts        distinct contacts with a covering state range AND
                                  the measure's paid-in test satisfied on @asof
          + extra region/grade cells             B03   (-1 each)
        = re-derived cell total                  what the daily-count join produces
          + stored-vs-derived drift              B04
        = silv_daily_count on @asof
          + gold behind silver                   B05   (only when anchored on GOLD)
        = Layercake count

    THE STATE-RANGE GATE APPLIES TO BOTH MEASURES. Neither paid number is a count of
    paid positions or of events on its own - both join the SAME state ranges as the
    active count, so every driver exclusion on the active side removes the contact
    from both paid numbers. A contact with a paid invoice position and no state range
    is never counted, whatever their position says. That is why the P10-P22 codes
    below are the same gate walk as the active script's A-series, and why they are
    shared between the two measures here.

    B04 is not an error on its own. silv_daily_count is FORWARD ONLY: a date already
    marked in etl_daily_count_loaded is never re-derived by a daily run, so a past
    date's stored value is a point-in-time record of what source said when it was
    first loaded. On @asof = today it should be zero.

    ---------------------------------------------------------------------------------
    REASON CODES

    IN_OFFICIAL_NOT_LAYERCAKE - walked in pipeline order, so reason_code names the
    FIRST thing that stopped the contact. all_reasons carries every code that
    applies.

    The paid-in chain, PAYMENT measure (P01-P06):
      P01  no brnz_subs_status row for this contact and campaign year
      P02  the contact's PAID source row lost the bronze dedupe. Bronze keeps one
           row per (contact, campaign year) ordered by [Renewal Date Adj] desc,
           [Renewal Date] desc, and it does that BEFORE any invoice-position
           filter - so a later non-paid row can evict the paid row and the contact
           never reaches silver at all
      P03  bronze holds a non-paid position while the source dedupe winner IS paid
           - bronze has not caught up. Re-run the bronze load
      P04  bronze holds a paid position but no silv_payment_events row exists
      P05  renewal_date_adj is null, so the payment has no date to count from
      P06  renewal_date_adj is AFTER @asof - the contact becomes paid later

    The paid-in chain, EVENT measure (E01-E04):
      E01  no Join / Renewal / Readmission event at all, in any campaign year
      E02  no Join / Renewal / Readmission event in THIS campaign year, so the
           measure has nothing to count the contact from. The usual cause is that
           the Renewal derivation did not fire - it reads silv_payment_events and
           the settled cash transactions behind them
      E03  the earliest such event in the year is dated AFTER the campaign year
           end, so usp_load_silv_daily_count drops it from stock and flow alike
      E04  the paid-in date is AFTER @asof - the contact is paid in later this year

    The state-range gate, SHARED by both measures (P10-P22):
      P10  no brnz_contact row
      P11  every brnz_contact row for the number is a test record
      P12  no brnz_rics_record row at all               - silv_member_base driver
      P13  latest rics record is Student grade (200000003) - driver. Not raised
           where the driver overrides the grade: the Student status is
           superseded in the enrolment history (vw_student_superseded)
      P14  no brnz_cust_trans row at all                - driver. The one worth
           reading twice on the PAYMENT side: a PAID invoice position for the
           campaign year with no cash transaction anywhere. Paid on paper, never
           transacted
      P15  passed every driver test but has no silv_member_base row - unexpected
      P16  no brnz_enrolment row at all, and no exception fallback date
      P17  brnz_enrolment rows exist but none survives vw_enrolment_base
      P18  qualifying rows exist but no effective enrolment/election date
      P19  dates exist but no Join / Change / Readmission event was emitted
      P20  events exist but no state range was built
      P21  ranges exist but the earliest starts AFTER @asof
      P22  ranges exist, none covers @asof (closed before it, or zero-length)
      P99  unexplained - if this is not zero, the rule set in section 6 needs
           extending. Never leave it non-zero and quote the list as complete

    IN_LAYERCAKE_NOT_OFFICIAL - the pipeline lost nothing here; the official query
    excluded the contact. Identical codes for both measures, because both are about
    the SOURCE side only. What differs between the measures is WHICH contacts land
    here, not why - read event_paid_in_type on the row, and RS-5.

      Q01  no Subs.vwSubsMemberStatuses row at all for this contact and campaign
           year - bronze is holding a row source has dropped
      Q02  source rows exist for the campaign year but none is in a paid position -
           the position has moved out of the paid list, or (on the EVENT measure)
           the contact was counted from a Join or Readmission event rather than
           from money
      Q99  unexplained - same warning as P99

    PAYMENT vs EVENT (RS-5 / RS-6). Both sides here already hold a covering state
    range, so the range gate cancels out and these codes are purely about the
    paid-in test - which is exactly where the two measures are designed to differ.

      M01  EVENT only: paid in from a JOIN event, no payment event for the year.
           The designed first-year divergence
      M02  EVENT only: paid in from a READMISSION event, no payment event
      M03  EVENT only: paid in from a RENEWAL event, no payment event - the Renewal
           was derived from cash the current subs position does not reflect
      M04  EVENT only: a payment event exists but its adjusted renewal date is
           AFTER @asof - PAYMENT starts counting them later this year
      M05  EVENT only: a payment event exists but its adjusted renewal date is null
      M10  PAYMENT only: no Join / Renewal / Readmission event in the campaign year
      M11  PAYMENT only: the paid-in event is dated after the campaign year end
      M12  PAYMENT only: the paid-in date is after @asof while the adjusted renewal
           date has already arrived
      M99  unexplained

    ---------------------------------------------------------------------------------
    OUTPUT
        RS-0  Run context
        RS-1  The assertion, one row per measure: official, Layercake, difference,
              sum of impacts, PASS/FAIL
        RS-2  The bridge for both measures, line by line
        RS-3  Reason summary by measure
        RS-4  THE LIST - one row per unit of difference, per measure
        RS-5  PAYMENT vs EVENT summary - how the two measures differ, by mechanism
        RS-6  PAYMENT vs EVENT list - the contacts behind RS-5

    ---------------------------------------------------------------------------------
    NOTES
      * Read-only. #temp tables only - nothing in the Layercake schema is written,
        so this is safe to run against the live database at any time.
      * Reads the LIVE source view. Run it straight after the daily load: mid-day,
        Q01 / P01 / P03 rows are timing rather than error.
      * @asof defaults to today and that is the only fully meaningful setting. The
        SOURCE side has no as-of dimension - Subs.vwSubsMemberStatuses is a
        current-state view of the campaign year - so an earlier @asof compares
        today's source positions against a historical pipeline state. RS-0 flags it.
      * The campaign year is taken from ref_date_spine for @asof, which is exactly
        what the daily-count join uses, so every side asks about the same year.
      * 'Partially Paid' counts as paid by design: Direct Debit members show as
        Partially Paid for around ten months of the year.
      * THE EVENT MEASURE RESETS TO ZERO EVERY 1 OCTOBER and builds through the
        campaign year. Early in a campaign year it is SUPPOSED to sit far below the
        official number - that is the measure working, not a fault. RS-1's EVENT
        row shows a large positive difference in October and closes through the
        year, almost all of it E04.
      * silv_data_anomaly is read for context only (the anomaly_types column) and is
        optional - the script runs without it.

    HOW TO RUN
    Not deployed - Deploy-Database.ps1 only walks the numbered phase folders. Set
    the knobs below and run it by hand:

        sqlcmd -S <server> -d <db> -U <user> -P <pwd> -i paid-member-difference.sql -b -N -I

    Requires the database project deployed and bronze + silver + gold loaded.
    Its sibling, active-member-difference.sql, does the same job for the active
    number.
*************************************************************************************/

set nocount on;
set xact_abort on;

------------------------------------------------------------------ configuration --
declare @asof             date       = '20250930' --cast(getdate() as date);  -- reconcile as at this date
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
drop table if exists #src, #off, #src_agg, #cover, #paid_cells, #ev_paid, #event_cells,
                     #cohort, #anom_raw, #anom, #rics, #bcontact, #trans, #bsubs, #pay,
                     #enr_raw, #enr, #mb, #ev, #rng, #cov_agg, #facts, #diff, #measures,
					 #student_superseded;


/*====================================================================
    1. THE OFFICIAL LIST, exactly as the agreed query defines it
    ------------------------------------------------------------------
    EVERY subs row for the campaign year is staged, not only the paid
    ones, because bronze's dedupe runs BEFORE the invoice-position
    filter and can evict a paid row - a loss the pipeline can never
    recover from, and one the paid rows alone would not show. bronze_rn
    reproduces that dedupe order exactly.

    This one list is the official side of BOTH measures.
====================================================================*/
select
    cast(b.[Contact No.] as nvarchar(200))  as contact_no,
    b.[Member Invoice Position]             as invoice_position,
    cast(b.[Renewal Date]     as date)      as renewal_date,
    cast(b.[Renewal Date Adj] as date)      as renewal_date_adj,
    cast(iif(b.[Member Invoice Position] in ('Full Concession', 'Fully Paid',
                                             'Partially Paid', 'Pre-Subs Payment'), 1, 0) as int)
                                            as is_paid_position,
    row_number() over (partition by b.[Contact No.], b.[Campaign Year]
                       order by b.[Renewal Date Adj] desc, b.[Renewal Date] desc)
                                            as bronze_rn
into #src
from Subs.vwSubsMemberStatuses b
where b.[Campaign Year] = @cy;

create clustered index cx_src on #src (contact_no);

declare @off_rows      int = (select count(*) from #src where is_paid_position = 1);
declare @off_null_rows int = (select count(*) from #src where is_paid_position = 1 and contact_no is null);

-- the official list collapsed to the contact NUMBER, which is the pipeline's key
select contact_no, count(*) as qualifying_rows
into #off
from #src
where is_paid_position = 1
  and contact_no       is not null
group by contact_no;

create unique clustered index cx_off on #off (contact_no);

declare @off_distinct  int = (select count(*) from #off);
declare @off_dup_extra int = (select isnull(sum(qualifying_rows - 1), 0) from #off);

-- every source row per contact for the campaign year, so a Layercake-only contact
-- can be explained against source, and so the bronze dedupe can be replayed
select
    s.contact_no,
    count(*)                                                          as src_rows,
    sum(s.is_paid_position)                                           as src_paid_rows,
    max(case when s.is_paid_position = 1 then s.invoice_position end) as src_paid_position,
    max(case when s.bronze_rn        = 1 then s.invoice_position end) as src_dedupe_winner_position,
    max(case when s.bronze_rn        = 1 then s.is_paid_position end) as winner_is_paid,
    max(case when s.is_paid_position = 1 then s.renewal_date end)     as src_renewal_date,
    max(case when s.is_paid_position = 1 then s.renewal_date_adj end) as src_renewal_date_adj
into #src_agg
from #src s
where s.contact_no is not null
group by s.contact_no;

create unique clustered index cx_src_agg on #src_agg (contact_no);


/*====================================================================
    2. THE TWO LAYERCAKE LISTS on @asof, each re-derived per contact
       with the exact join rule from step d of
       usp_load_silv_daily_count
    ------------------------------------------------------------------
    Both measures need a state range covering @asof, of ANY grade -
    lapse rows still carry paid counts, so the lapse state is NOT
    excluded here as it is on the active side. They differ only in the
    paid-in test joined to it.

    Half-open interval [valid_from, valid_to). Zero-length ranges cover
    nothing; open-ended ranges count through today, which is why a
    future @asof is refused above.

    ALL covering ranges are kept. The daily-count join groups by
    (region, grade) and counts distinct contacts per cell, so a contact
    holding two covering ranges in different cells is counted TWICE.
    #paid_cells and #event_cells reproduce that exactly: one row per
    contact carrying how many cells it occupies. Their ROW COUNT is the
    contact list, their SUM is the number.
====================================================================*/
select r.contact_no, r.grade, r.region, r.valid_from, r.valid_to, r.state_seq
into #cover
from Layercake.silv_member_state_ranges r
where @asof >= r.valid_from
  and @asof <  isnull(r.valid_to, dateadd(day, 1, @asof));

create clustered index cx_cover on #cover (contact_no);

/*--------------------------------------------------------------------
    2a. PAYMENT measure: a silv_payment_events row for the campaign
        year whose adjusted renewal date is on or before @asof.
        silv_payment_events is keyed on (contact_no, campaign_year), so
        the payment join is 1:1 and cannot fan the count out on its own.
--------------------------------------------------------------------*/
select v.contact_no, count(*) as paid_cells
into #paid_cells
from (
    select distinct c.contact_no, c.region, c.grade
    from #cover c
    join Layercake.silv_payment_events p
      on  p.contact_no    = c.contact_no
      and p.campaign_year = @cy
    where p.renewal_date_adj <= @asof
) v
group by v.contact_no;

create unique clustered index cx_paid_cells on #paid_cells (contact_no);

/*--------------------------------------------------------------------
    2b. EVENT measure: the paid-in event for the campaign year.
        An EXACT copy of step c1 of usp_load_silv_daily_count - the
        same three event types, the same tie-break (Join, then
        Readmission, then Renewal, then event_id), the same clamp to
        the campaign year start, and the same campaign-year-end test.

        The year-end test is applied AFTER the row_number, exactly as
        the module does it: a winner dated past the year end drops the
        contact from the measure rather than falling back to a later
        event. after_cy_end carries that so E03 can name it.

        ref_campaign_year_config is left joined - campaign years before
        the spine have no config row, and both tests are written to
        pass when it is missing.
--------------------------------------------------------------------*/
select
    v.contact_no,
    v.event_type                             as event_paid_in_type,
    v.event_date                             as event_paid_in_event_date,
    iif(v.event_date < cfg.campaign_year_start, cfg.campaign_year_start, v.event_date)
                                             as event_paid_in_date,
    cast(iif(cfg.campaign_year_end is not null and v.event_date > cfg.campaign_year_end, 1, 0) as int)
                                             as after_cy_end
into #ev_paid
from (
    select
        e.contact_no,
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
    where e.event_type    in ('Join', 'Renewal', 'Readmission')
      and e.campaign_year = @cy
) v
left join Layercake.ref_campaign_year_config cfg
    on cfg.campaign_year = v.campaign_year
where v.rn = 1;

create unique clustered index cx_ev_paid on #ev_paid (contact_no);

select v.contact_no, count(*) as event_cells
into #event_cells
from (
    select distinct c.contact_no, c.region, c.grade
    from #cover c
    join #ev_paid ep on ep.contact_no = c.contact_no
    where ep.after_cy_end       = 0
      and ep.event_paid_in_date <= @asof
) v
group by v.contact_no;

create unique clustered index cx_event_cells on #event_cells (contact_no);

/*--------------------------------------------------------------------
    2c. the numbers, per measure
--------------------------------------------------------------------*/
declare @pm_distinct  int = (select count(*) from #paid_cells);
declare @pm_cells     int = (select isnull(sum(paid_cells), 0) from #paid_cells);
declare @pm_overcount int = @pm_cells - @pm_distinct;

declare @ev_distinct  int = (select count(*) from #event_cells);
declare @ev_cells     int = (select isnull(sum(event_cells), 0) from #event_cells);
declare @ev_overcount int = @ev_cells - @ev_distinct;

declare @pm_silver int = isnull((select sum(paid_count)       from Layercake.silv_daily_count where [date] = @asof), 0);
declare @ev_silver int = isnull((select sum(paid_count_event) from Layercake.silv_daily_count where [date] = @asof), 0);

declare @pm_gold int = isnull((select sum(f.PaidMembers)
                               from Layercake.fact_daily_member_count_detail f
                               join Layercake.dim_date d on d.id = f.date_id
                               where d.[date] = @asof), 0);

declare @ev_gold int = isnull((select sum(f.PaidMembersEvent)
                               from Layercake.fact_daily_member_count_detail f
                               join Layercake.dim_date d on d.id = f.date_id
                               where d.[date] = @asof), 0);

declare @pm_anchor     int = iif(@layercake_source = 'GOLD', @pm_gold, @pm_silver);
declare @ev_anchor     int = iif(@layercake_source = 'GOLD', @ev_gold, @ev_silver);
declare @pm_drift      int = @pm_silver - @pm_cells;                                    -- B04, PAYMENT
declare @ev_drift      int = @ev_silver - @ev_cells;                                    -- B04, EVENT
declare @pm_gold_delta int = iif(@layercake_source = 'GOLD', @pm_gold - @pm_silver, 0); -- B05, PAYMENT
declare @ev_gold_delta int = iif(@layercake_source = 'GOLD', @ev_gold - @ev_silver, 0); -- B05, EVENT

declare @pm_difference int = @off_rows - @pm_anchor;
declare @ev_difference int = @off_rows - @ev_anchor;


/*====================================================================
    3. THE COHORT = official list  U  PAYMENT list  U  EVENT list
====================================================================*/
select contact_no
into #cohort
from (
    select contact_no from #off
    union
    select contact_no from #paid_cells
    union
    select contact_no from #event_cells
) v;

create unique clustered index cx_cohort on #cohort (contact_no);


/*====================================================================
    4. THE GATES, one staging step per rule
====================================================================*/

-- 4a. the bronze subs row for the campaign year. The PK is (contact, campaign
--     year), so there is at most one. Soft-deleted rows are staged too, so
--     "gone from bronze" and "never in bronze" can be told apart.
select
    cast(b.[Contact No.] as nvarchar(200)) as contact_no,
    b.[Member Invoice Position]            as bronze_position,
    b.[Renewal Date Adj]                   as bronze_renewal_date_adj,
    b._is_deleted                          as bronze_is_deleted,
    cast(iif(b._is_deleted = 0
             and b.[Member Invoice Position] in ('Full Concession', 'Fully Paid',
                                                 'Partially Paid', 'Pre-Subs Payment'), 1, 0) as int)
                                           as bronze_is_paid
into #bsubs
from Layercake.brnz_subs_status b
join #cohort k on k.contact_no = b.[Contact No.]
where b.[Campaign Year] = @cy;

create unique clustered index cx_bsubs on #bsubs (contact_no);

-- 4b. the derived payment event for the campaign year
select
    p.contact_no,
    p.invoice_position   as pay_invoice_position,
    p.renewal_date_adj   as pay_renewal_date_adj,
    p.payment_date       as pay_payment_date,
    p.payment_source     as pay_payment_source
into #pay
from Layercake.silv_payment_events p
join #cohort k on k.contact_no = p.contact_no
where p.campaign_year = @cy;

create unique clustered index cx_pay on #pay (contact_no);

-- 4c. bronze contact rows, and whether every one of them is a test record
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

-- 4d. latest rics record per membership number - an EXACT copy of the
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

-- 4e. contacts whose Student grade the driver OVERRIDES: the Student status is
--     superseded in the enrolment history (latest Student application ended, a
--     qualifying row created on or after it). Read from the view the driver
--     itself stages, Layercake.vw_student_superseded, so the test here is the
--     driver's own
select cast(v.[Contact No] as nvarchar(200)) as contact_no
into #student_superseded
from Layercake.vw_student_superseded v;

create unique clustered index cx_student_superseded on #student_superseded (contact_no);

-- 4e. transaction history. The driver tests EXISTENCE only - no approved or
--     settled filter, that rule lives in the payment derivation. P14 is the
--     contradiction this produces on the paid side.
select distinct cast(ct.accountnum as nvarchar(200)) as contact_no
into #trans
from Layercake.brnz_cust_trans ct
join #cohort k on k.contact_no = ct.accountnum
where ct._is_deleted = 0;

create unique clustered index cx_trans on #trans (contact_no);

-- 4f. raw enrolment rows (any row at all), which separates P16 from P17
select cast(e.[Contact No] as nvarchar(200)) as contact_no, count(*) as enrolment_rows
into #enr_raw
from Layercake.brnz_enrolment e
join #cohort k on k.contact_no = e.[Contact No]
where e._is_deleted = 0
group by cast(e.[Contact No] as nvarchar(200));

create unique clustered index cx_enr_raw on #enr_raw (contact_no);

-- 4g. QUALIFYING enrolment / election rows, read from the same view the driver
--     reads, so this test cannot drift from it
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

-- 4h. the member base. One row per brnz_contact row, so aggregated.
select
    b.contact_no,
    count(*)                   as base_rows,
    min(b.enrolment_date)      as mb_enrolment_date,
    min(b.election_date)       as mb_election_date,
    max(b.contact_lapsed_date) as mb_contact_lapsed_date,
    max(b.lapsed_date)         as mb_lapsed_date
into #mb
from Layercake.silv_member_base b
join #cohort k on k.contact_no = b.contact_no
group by b.contact_no;

create unique clustered index cx_mb on #mb (contact_no);

-- 4i. events. has_range_event is what opens a STATE RANGE (Join / Change /
--     Readmission); has_paid_in_event is what the EVENT measure counts from
--     (Join / Renewal / Readmission) across every campaign year, which is what
--     separates E01 from E02.
select
    e.contact_no,
    count(*)                                                           as events,
    max(iif(e.event_type in ('Join', 'Change', 'Readmission'), 1, 0))  as has_range_event,
    max(iif(e.event_type in ('Join', 'Renewal', 'Readmission'), 1, 0)) as has_paid_in_event,
    max(iif(e.event_type = 'Readmission', 1, 0))                       as has_readmission,
    max(iif(e.event_type = 'Renewal', 1, 0))                           as has_renewal,
    max(iif(e.event_type = 'Lapse', 1, 0))                             as has_lapse_event
into #ev
from Layercake.silv_membership_events e
join #cohort k on k.contact_no = e.contact_no
group by e.contact_no;

create unique clustered index cx_ev on #ev (contact_no);

-- 4j. every state range the contact has, covering @asof or not
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

-- 4k. the covering ranges, summarised for display. any_non_lapse is what the
--     ACTIVE number reads, carried here so a paid-but-lapsed contact is visible -
--     the EVENT measure in particular keeps counting them.
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

-- 4l. open anomalies, context only. The table is optional, so it is staged
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
       Kept if the contact diverges from the official list on EITHER
       measure. Contacts both measures agree with drop out.
====================================================================*/
select
    k.contact_no,
    cast(iif(o.contact_no  is not null, 1, 0) as bit) as in_official,
    cast(iif(pc.contact_no is not null, 1, 0) as bit) as in_payment,
    cast(iif(ec.contact_no is not null, 1, 0) as bit) as in_event,
    isnull(pc.paid_cells, 0)                          as paid_cells,
    isnull(ec.event_cells, 0)                         as event_cells,

    -- source side
    isnull(sa.src_rows, 0)       as src_rows,
    isnull(sa.src_paid_rows, 0)  as src_paid_rows,
    sa.src_paid_position,
    sa.src_dedupe_winner_position,
    isnull(sa.winner_is_paid, 0) as winner_is_paid,
    sa.src_renewal_date,
    sa.src_renewal_date_adj,

    -- bronze subs + payment event: the PAYMENT paid-in chain
    cast(iif(bs.contact_no is not null, 1, 0) as bit) as has_bronze_subs_row,
    bs.bronze_position,
    bs.bronze_renewal_date_adj,
    bs.bronze_is_deleted,
    isnull(bs.bronze_is_paid, 0) as bronze_is_paid,
    cast(iif(py.contact_no is not null, 1, 0) as bit) as has_payment_event,
    py.pay_invoice_position,
    py.pay_renewal_date_adj,
    py.pay_payment_date,
    py.pay_payment_source,

    -- the EVENT paid-in chain
    cast(iif(ep.contact_no is not null, 1, 0) as bit) as has_event_paid_in,
    ep.event_paid_in_type,
    ep.event_paid_in_event_date,
    ep.event_paid_in_date,
    isnull(ep.after_cy_end, 0)   as event_paid_in_after_cy_end,

    -- driver side
    isnull(bc.bronze_contact_rows, 0) as bronze_contact_rows,
    isnull(bc.bronze_nontest_rows, 0) as bronze_nontest_rows,
    cast(iif(rr.contact_no is not null, 1, 0) as bit) as has_rics_record,
    rr.rics_grade,
    cast(iif(tr.contact_no is not null, 1, 0) as bit) as has_transactions,

    -- silver side
    isnull(mb.base_rows, 0)         as base_rows,
    mb.mb_enrolment_date,
    mb.mb_election_date,
    mb.mb_lapsed_date,
    isnull(er.enrolment_rows, 0)    as enrolment_rows,
    isnull(en.qualifying_rows, 0)   as qualifying_enrolment_rows,
    isnull(ev.events, 0)            as events,
    isnull(ev.has_range_event, 0)   as has_range_event,
    isnull(ev.has_paid_in_event, 0) as has_paid_in_event,
    isnull(ev.has_readmission, 0)   as has_readmission,
    isnull(ev.has_renewal, 0)       as has_renewal,
    isnull(rg.state_ranges, 0)      as state_ranges,
    rg.first_valid_from,
    isnull(ca.covering_ranges, 0)   as covering_ranges,
    isnull(ca.covering_grades, '')  as covering_grades,
    cast(isnull(ca.any_non_lapse, 0) as bit) as active_on_asof,
    an.anomaly_types
into #facts
from #cohort k
left join #off         o  on o.contact_no  = k.contact_no
left join #paid_cells  pc on pc.contact_no = k.contact_no
left join #event_cells ec on ec.contact_no = k.contact_no
left join #src_agg     sa on sa.contact_no = k.contact_no
left join #bsubs       bs on bs.contact_no = k.contact_no
left join #pay         py on py.contact_no = k.contact_no
left join #ev_paid     ep on ep.contact_no = k.contact_no
left join #bcontact    bc on bc.contact_no = k.contact_no
left join #rics        rr on rr.contact_no = k.contact_no
left join #trans       tr on tr.contact_no = k.contact_no
left join #mb          mb on mb.contact_no = k.contact_no
left join #enr_raw     er on er.contact_no = k.contact_no
left join #enr         en on en.contact_no = k.contact_no
left join #ev          ev on ev.contact_no = k.contact_no
left join #rng         rg on rg.contact_no = k.contact_no
left join #cov_agg     ca on ca.contact_no = k.contact_no
left join #anom        an on an.contact_no = k.contact_no
where o.contact_no  is null            -- in one of the measures only
   or pc.contact_no is null            -- diverges on PAYMENT
   or ec.contact_no is null;           -- diverges on EVENT

create unique clustered index cx_facts on #facts (contact_no);


/*====================================================================
    6. THE LIST
====================================================================*/
create table #diff
(
    measure                    varchar(7)     not null,   -- PAYMENT | EVENT
    direction                  varchar(26)    not null,
    count_impact               int            not null,
    reason_code                varchar(4)     not null,
    reason                     nvarchar(1000) not null,
    all_reasons                varchar(160)   null,
    contact_no                 nvarchar(200)  collate database_default null,
    src_rows                   int            null,
    src_paid_rows              int            null,
    src_paid_position          nvarchar(64)   null,
    src_dedupe_winner_position nvarchar(64)   null,
    src_renewal_date           date           null,
    src_renewal_date_adj       date           null,
    has_bronze_subs_row        bit            null,
    bronze_position            nvarchar(64)   null,
    bronze_renewal_date_adj    date           null,
    bronze_is_deleted          bit            null,
    has_payment_event          bit            null,
    pay_invoice_position       nvarchar(64)   null,
    pay_renewal_date_adj       date           null,
    pay_payment_date           date           null,
    pay_payment_source         nvarchar(64)   null,
    has_event_paid_in          bit            null,
    event_paid_in_type         varchar(20)    null,
    event_paid_in_event_date   date           null,
    event_paid_in_date         date           null,
    event_paid_in_after_cy_end int            null,
    bronze_contact_rows        int            null,
    bronze_nontest_rows        int            null,
    has_rics_record            bit            null,
    rics_grade                 int            null,
    has_transactions           bit            null,
    base_rows                  int            null,
    mb_enrolment_date          date           null,
    mb_election_date           date           null,
    mb_lapsed_date             date           null,
    enrolment_rows             int            null,
    qualifying_enrolment_rows  int            null,
    events                     int            null,
    has_range_event            int            null,
    has_readmission            int            null,
    state_ranges               int            null,
    first_valid_from           date           null,
    covering_ranges            int            null,
    covering_grades            varchar(50)    null,
    active_on_asof             bit            null,
    paid_cells                 int            null,
    event_cells                int            null,
    anomaly_types              varchar(200)   null
);

/*--------------------------------------------------------------------
    6a. PAYMENT: in the official list, not in the number   (+1 each)
        The payment chain first (P01-P06), then the state-range gate
        (P10-P22).
--------------------------------------------------------------------*/
insert into #diff
(measure, direction, count_impact, reason_code, reason, all_reasons, contact_no,
 src_rows, src_paid_rows, src_paid_position, src_dedupe_winner_position, src_renewal_date,
 src_renewal_date_adj, has_bronze_subs_row, bronze_position, bronze_renewal_date_adj,
 bronze_is_deleted, has_payment_event, pay_invoice_position, pay_renewal_date_adj,
 pay_payment_date, pay_payment_source, has_event_paid_in, event_paid_in_type,
 event_paid_in_event_date, event_paid_in_date, event_paid_in_after_cy_end,
 bronze_contact_rows, bronze_nontest_rows, has_rics_record, rics_grade, has_transactions,
 base_rows, mb_enrolment_date, mb_election_date, mb_lapsed_date, enrolment_rows,
 qualifying_enrolment_rows, events, has_range_event, has_readmission, state_ranges,
 first_valid_from, covering_ranges, covering_grades, active_on_asof, paid_cells,
 event_cells, anomaly_types)
select
    'PAYMENT',
    'IN_OFFICIAL_NOT_LAYERCAKE',
    1,
    g.code,
    g.reason,
    nullif(stuff(concat(
        iif(x.f01 = 1, ', P01', ''), iif(x.f02 = 1, ', P02', ''), iif(x.f03 = 1, ', P03', ''),
        iif(x.f04 = 1, ', P04', ''), iif(x.f05 = 1, ', P05', ''), iif(x.f06 = 1, ', P06', ''),
        iif(x.f10 = 1, ', P10', ''), iif(x.f11 = 1, ', P11', ''), iif(x.f12 = 1, ', P12', ''),
        iif(x.f13 = 1, ', P13', ''), iif(x.f14 = 1, ', P14', ''), iif(x.f15 = 1, ', P15', ''),
        iif(x.f16 = 1, ', P16', ''), iif(x.f17 = 1, ', P17', ''), iif(x.f18 = 1, ', P18', ''),
        iif(x.f19 = 1, ', P19', ''), iif(x.f20 = 1, ', P20', ''), iif(x.f21 = 1, ', P21', ''),
        iif(x.f22 = 1, ', P22', '')), 1, 2, ''), ''),
    f.contact_no,
    f.src_rows, f.src_paid_rows, f.src_paid_position, f.src_dedupe_winner_position, f.src_renewal_date,
    f.src_renewal_date_adj, f.has_bronze_subs_row, f.bronze_position, f.bronze_renewal_date_adj,
    f.bronze_is_deleted, f.has_payment_event, f.pay_invoice_position, f.pay_renewal_date_adj,
    f.pay_payment_date, f.pay_payment_source, f.has_event_paid_in, f.event_paid_in_type,
    f.event_paid_in_event_date, f.event_paid_in_date, f.event_paid_in_after_cy_end,
    f.bronze_contact_rows, f.bronze_nontest_rows, f.has_rics_record, f.rics_grade, f.has_transactions,
    f.base_rows, f.mb_enrolment_date, f.mb_election_date, f.mb_lapsed_date, f.enrolment_rows,
    f.qualifying_enrolment_rows, f.events, f.has_range_event, f.has_readmission, f.state_ranges,
    f.first_valid_from, f.covering_ranges, f.covering_grades, f.active_on_asof, f.paid_cells,
    f.event_cells, f.anomaly_types
from #facts f
cross apply (select
    -- the PAYMENT paid-in chain
    iif(f.has_bronze_subs_row = 0 or f.bronze_is_deleted = 1, 1, 0)                        as f01,
    iif(f.has_bronze_subs_row = 1 and f.bronze_is_deleted = 0 and f.bronze_is_paid = 0
        and f.winner_is_paid = 0, 1, 0)                                                    as f02,
    iif(f.has_bronze_subs_row = 1 and f.bronze_is_deleted = 0 and f.bronze_is_paid = 0
        and f.winner_is_paid = 1, 1, 0)                                                    as f03,
    iif(f.bronze_is_paid = 1 and f.has_payment_event = 0, 1, 0)                            as f04,
    iif(f.has_payment_event = 1 and f.pay_renewal_date_adj is null, 1, 0)                  as f05,
    iif(f.has_payment_event = 1 and f.pay_renewal_date_adj > @asof, 1, 0)                  as f06,
    -- the state-range gate: the same driver walk as the active count
    iif(f.bronze_contact_rows = 0, 1, 0)                                                   as f10,
    iif(f.bronze_contact_rows > 0 and f.bronze_nontest_rows = 0, 1, 0)                     as f11,
    iif(f.bronze_nontest_rows > 0 and f.has_rics_record = 0, 1, 0)                         as f12,
    iif(f.has_rics_record = 1 and isnull(f.rics_grade, 0) = 200000003
        and not exists (select 1 from #student_superseded ss
                        where ss.contact_no = f.contact_no), 1, 0)                         as f13,
    iif(f.bronze_nontest_rows > 0 and f.has_transactions = 0, 1, 0)                        as f14,
    iif(f.bronze_nontest_rows > 0 and f.has_rics_record = 1 and f.has_transactions = 1
        and (   isnull(f.rics_grade, 0) <> 200000003
             or exists (select 1 from #student_superseded ss
                        where ss.contact_no = f.contact_no))
        and f.base_rows = 0, 1, 0)                                                         as f15,
    iif(f.base_rows > 0 and f.mb_enrolment_date is null and f.mb_election_date is null
        and f.enrolment_rows = 0, 1, 0)                                                    as f16,
    iif(f.base_rows > 0 and f.mb_enrolment_date is null and f.mb_election_date is null
        and f.enrolment_rows > 0 and f.qualifying_enrolment_rows = 0, 1, 0)                as f17,
    iif(f.base_rows > 0 and f.mb_enrolment_date is null and f.mb_election_date is null
        and f.qualifying_enrolment_rows > 0, 1, 0)                                         as f18,
    iif(f.base_rows > 0 and (f.mb_enrolment_date is not null or f.mb_election_date is not null)
        and f.has_range_event = 0, 1, 0)                                                   as f19,
    iif(f.has_range_event = 1 and f.state_ranges = 0, 1, 0)                                as f20,
    iif(f.state_ranges > 0 and f.covering_ranges = 0 and f.first_valid_from > @asof, 1, 0) as f21,
    iif(f.state_ranges > 0 and f.covering_ranges = 0
        and isnull(f.first_valid_from, @asof) <= @asof, 1, 0)                              as f22
) x
cross apply (select
    case
        when x.f01 = 1 then 'P01' when x.f02 = 1 then 'P02' when x.f03 = 1 then 'P03'
        when x.f04 = 1 then 'P04' when x.f05 = 1 then 'P05' when x.f06 = 1 then 'P06'
        when x.f10 = 1 then 'P10' when x.f11 = 1 then 'P11' when x.f12 = 1 then 'P12'
        when x.f13 = 1 then 'P13' when x.f14 = 1 then 'P14' when x.f15 = 1 then 'P15'
        when x.f16 = 1 then 'P16' when x.f17 = 1 then 'P17' when x.f18 = 1 then 'P18'
        when x.f19 = 1 then 'P19' when x.f20 = 1 then 'P20' when x.f21 = 1 then 'P21'
        when x.f22 = 1 then 'P22'
        else 'P99'
    end as code,
    case
        when x.f01 = 1 then N'No live brnz_subs_status row for this contact and campaign year - source has moved since the last bronze load, or the row has been soft-deleted. Re-run the bronze load and re-check.'
        when x.f02 = 1 then N'The contact''s PAID source row lost the bronze dedupe. Bronze keeps one row per (contact, campaign year) ordered by [Renewal Date Adj] desc, [Renewal Date] desc, and does that BEFORE any invoice-position filter - so a later non-paid row evicted the paid row and the contact never reached silver.'
        when x.f03 = 1 then N'Bronze holds a non-paid invoice position while the source dedupe winner IS in a paid position - bronze has not caught up with source. Re-run the bronze load and re-check.'
        when x.f04 = 1 then N'Bronze holds a paid invoice position but no silv_payment_events row exists for the campaign year. Re-run usp_load_silv_payment_events.'
        when x.f05 = 1 then N'The payment event has a NULL adjusted renewal date, so there is no date for the day-by-day paid count to start from. The contact can never be counted paid in any year.'
        when x.f06 = 1 then N'The adjusted renewal date is AFTER the as-of date - the contact becomes paid later in the campaign year. The official query has no as-of dimension and counts them from the moment the position is set.'
        when x.f10 = 1 then N'A paid position exists, but there is no brnz_contact row for this contact number, so no state range could be built and the paid count''s range gate drops the contact.'
        when x.f11 = 1 then N'Every brnz_contact row for this number is flagged as a test record, so the silv_member_base driver excludes it and no state range exists to hang the payment on.'
        when x.f12 = 1 then N'No brnz_rics_record row at all - the silv_member_base driver excludes the contact, so there is no state range and the paid count drops it along with the active count. Logged as NO_RICS_RECORD.'
        when x.f13 = 1 then N'The latest rics record is Student grade (200000003), excluded from the silv_member_base driver, so no state range exists to hang the payment on. Not overridden: no ended Student application with a qualifying row created on or after it (vw_student_superseded).'
        when x.f14 = 1 then N'A PAID invoice position for the campaign year with NO brnz_cust_trans row anywhere - paid on paper, never transacted in cash. The driver excludes the contact, which removes the state range and so the paid count too. Logged as NO_TRANSACTIONS where a valid enrolment exists behind it.'
        when x.f15 = 1 then N'Passes every silv_member_base driver test but has no member base row. Unexpected - re-run usp_load_silv_member_base and re-check.'
        when x.f16 = 1 then N'No brnz_enrolment row at all, and no ref_enrolment_exception fallback date, so no enrolment or election date could be derived and no state range was built.'
        when x.f17 = 1 then N'brnz_enrolment rows exist but none survives the rules in vw_enrolment_base (route allowlist, application-type exclusions, ended-without-election, 14-day cool-off), so no state range was built.'
        when x.f18 = 1 then N'Qualifying enrolment rows exist but no effective enrolment or election date reached silv_member_base. Check the per-contact aggregate in usp_load_silv_member_base.'
        when x.f19 = 1 then N'Dates exist on silv_member_base but no Join / Change / Readmission event was emitted, so nothing opened a state range for the payment to join to.'
        when x.f20 = 1 then N'Range-opening events exist but no state range was built. Re-run usp_load_silv_member_state_ranges.'
        when x.f21 = 1 then N'The earliest state range starts after the as-of date, so there is no range for the payment to join to yet.'
        when x.f22 = 1 then N'State ranges exist but none covers the as-of date - closed before it, or zero-length from a same-day supersede. The paid count joins the same ranges as the active count, so no covering range means no paid count.'
        else N'In the official list, not in the PAYMENT number, and none of the known gates explains it. Extend the rule set in section 6a before quoting this list as complete.'
    end as reason
) g
where f.in_official = 1
  and f.in_payment  = 0;

/*--------------------------------------------------------------------
    6b. PAYMENT: in the number, not in the official list   (-1 each)
--------------------------------------------------------------------*/
insert into #diff
(measure, direction, count_impact, reason_code, reason, all_reasons, contact_no,
 src_rows, src_paid_rows, src_paid_position, src_dedupe_winner_position, src_renewal_date,
 src_renewal_date_adj, has_bronze_subs_row, bronze_position, bronze_renewal_date_adj,
 bronze_is_deleted, has_payment_event, pay_invoice_position, pay_renewal_date_adj,
 pay_payment_date, pay_payment_source, has_event_paid_in, event_paid_in_type,
 event_paid_in_event_date, event_paid_in_date, event_paid_in_after_cy_end,
 bronze_contact_rows, bronze_nontest_rows, has_rics_record, rics_grade, has_transactions,
 base_rows, mb_enrolment_date, mb_election_date, mb_lapsed_date, enrolment_rows,
 qualifying_enrolment_rows, events, has_range_event, has_readmission, state_ranges,
 first_valid_from, covering_ranges, covering_grades, active_on_asof, paid_cells,
 event_cells, anomaly_types)
select
    'PAYMENT',
    'IN_LAYERCAKE_NOT_OFFICIAL',
    -1,
    g.code,
    g.reason,
    nullif(stuff(concat(iif(x.f01 = 1, ', Q01', ''), iif(x.f02 = 1, ', Q02', '')), 1, 2, ''), ''),
    f.contact_no,
    f.src_rows, f.src_paid_rows, f.src_paid_position, f.src_dedupe_winner_position, f.src_renewal_date,
    f.src_renewal_date_adj, f.has_bronze_subs_row, f.bronze_position, f.bronze_renewal_date_adj,
    f.bronze_is_deleted, f.has_payment_event, f.pay_invoice_position, f.pay_renewal_date_adj,
    f.pay_payment_date, f.pay_payment_source, f.has_event_paid_in, f.event_paid_in_type,
    f.event_paid_in_event_date, f.event_paid_in_date, f.event_paid_in_after_cy_end,
    f.bronze_contact_rows, f.bronze_nontest_rows, f.has_rics_record, f.rics_grade, f.has_transactions,
    f.base_rows, f.mb_enrolment_date, f.mb_election_date, f.mb_lapsed_date, f.enrolment_rows,
    f.qualifying_enrolment_rows, f.events, f.has_range_event, f.has_readmission, f.state_ranges,
    f.first_valid_from, f.covering_ranges, f.covering_grades, f.active_on_asof, f.paid_cells,
    f.event_cells, f.anomaly_types
from #facts f
cross apply (select
    iif(f.src_rows = 0, 1, 0)                         as f01,
    iif(f.src_rows > 0 and f.src_paid_rows = 0, 1, 0) as f02
) x
cross apply (select
    case when x.f01 = 1 then 'Q01' when x.f02 = 1 then 'Q02' else 'Q99' end as code,
    case
        when x.f01 = 1 then N'No Subs.vwSubsMemberStatuses row at all for this contact and campaign year - bronze is holding a row source has dropped. Re-run the bronze load; if it persists, the soft-delete sweep is not seeing the deletion.'
        when x.f02 = 1 then N'Source rows exist for this contact and campaign year but none is in a paid invoice position - the position has moved out of the paid list and bronze has not caught up. Re-run the bronze load and re-check.'
        else N'Counted by the PAYMENT measure, excluded by the official query, and no mechanism identified. Extend the rule set in section 6b before quoting this list as complete.'
    end as reason
) g
where f.in_official = 0
  and f.in_payment  = 1;

/*--------------------------------------------------------------------
    6c. EVENT: in the official list, not in the number     (+1 each)
        The event paid-in chain (E01-E04), then the SAME state-range
        gate as the payment side (P10-P22) - both measures pass
        through it, so the codes are deliberately shared.
--------------------------------------------------------------------*/
insert into #diff
(measure, direction, count_impact, reason_code, reason, all_reasons, contact_no,
 src_rows, src_paid_rows, src_paid_position, src_dedupe_winner_position, src_renewal_date,
 src_renewal_date_adj, has_bronze_subs_row, bronze_position, bronze_renewal_date_adj,
 bronze_is_deleted, has_payment_event, pay_invoice_position, pay_renewal_date_adj,
 pay_payment_date, pay_payment_source, has_event_paid_in, event_paid_in_type,
 event_paid_in_event_date, event_paid_in_date, event_paid_in_after_cy_end,
 bronze_contact_rows, bronze_nontest_rows, has_rics_record, rics_grade, has_transactions,
 base_rows, mb_enrolment_date, mb_election_date, mb_lapsed_date, enrolment_rows,
 qualifying_enrolment_rows, events, has_range_event, has_readmission, state_ranges,
 first_valid_from, covering_ranges, covering_grades, active_on_asof, paid_cells,
 event_cells, anomaly_types)
select
    'EVENT',
    'IN_OFFICIAL_NOT_LAYERCAKE',
    1,
    g.code,
    g.reason,
    nullif(stuff(concat(
        iif(x.e01 = 1, ', E01', ''), iif(x.e02 = 1, ', E02', ''), iif(x.e03 = 1, ', E03', ''),
        iif(x.e04 = 1, ', E04', ''),
        iif(x.f10 = 1, ', P10', ''), iif(x.f11 = 1, ', P11', ''), iif(x.f12 = 1, ', P12', ''),
        iif(x.f13 = 1, ', P13', ''), iif(x.f14 = 1, ', P14', ''), iif(x.f15 = 1, ', P15', ''),
        iif(x.f16 = 1, ', P16', ''), iif(x.f17 = 1, ', P17', ''), iif(x.f18 = 1, ', P18', ''),
        iif(x.f19 = 1, ', P19', ''), iif(x.f20 = 1, ', P20', ''), iif(x.f21 = 1, ', P21', ''),
        iif(x.f22 = 1, ', P22', '')), 1, 2, ''), ''),
    f.contact_no,
    f.src_rows, f.src_paid_rows, f.src_paid_position, f.src_dedupe_winner_position, f.src_renewal_date,
    f.src_renewal_date_adj, f.has_bronze_subs_row, f.bronze_position, f.bronze_renewal_date_adj,
    f.bronze_is_deleted, f.has_payment_event, f.pay_invoice_position, f.pay_renewal_date_adj,
    f.pay_payment_date, f.pay_payment_source, f.has_event_paid_in, f.event_paid_in_type,
    f.event_paid_in_event_date, f.event_paid_in_date, f.event_paid_in_after_cy_end,
    f.bronze_contact_rows, f.bronze_nontest_rows, f.has_rics_record, f.rics_grade, f.has_transactions,
    f.base_rows, f.mb_enrolment_date, f.mb_election_date, f.mb_lapsed_date, f.enrolment_rows,
    f.qualifying_enrolment_rows, f.events, f.has_range_event, f.has_readmission, f.state_ranges,
    f.first_valid_from, f.covering_ranges, f.covering_grades, f.active_on_asof, f.paid_cells,
    f.event_cells, f.anomaly_types
from #facts f
cross apply (select
    -- the EVENT paid-in chain
    iif(f.has_event_paid_in = 0 and f.has_paid_in_event = 0, 1, 0)                         as e01,
    iif(f.has_event_paid_in = 0 and f.has_paid_in_event = 1, 1, 0)                         as e02,
    iif(f.has_event_paid_in = 1 and f.event_paid_in_after_cy_end = 1, 1, 0)                as e03,
    iif(f.has_event_paid_in = 1 and f.event_paid_in_after_cy_end = 0
        and f.event_paid_in_date > @asof, 1, 0)                                            as e04,
    -- the state-range gate, shared with the payment side
    iif(f.bronze_contact_rows = 0, 1, 0)                                                   as f10,
    iif(f.bronze_contact_rows > 0 and f.bronze_nontest_rows = 0, 1, 0)                     as f11,
    iif(f.bronze_nontest_rows > 0 and f.has_rics_record = 0, 1, 0)                         as f12,
    iif(f.has_rics_record = 1 and isnull(f.rics_grade, 0) = 200000003
        and not exists (select 1 from #student_superseded ss
                        where ss.contact_no = f.contact_no), 1, 0)                         as f13,
    iif(f.bronze_nontest_rows > 0 and f.has_transactions = 0, 1, 0)                        as f14,
    iif(f.bronze_nontest_rows > 0 and f.has_rics_record = 1 and f.has_transactions = 1
        and (   isnull(f.rics_grade, 0) <> 200000003
             or exists (select 1 from #student_superseded ss
                        where ss.contact_no = f.contact_no))
        and f.base_rows = 0, 1, 0)                                                         as f15,
    iif(f.base_rows > 0 and f.mb_enrolment_date is null and f.mb_election_date is null
        and f.enrolment_rows = 0, 1, 0)                                                    as f16,
    iif(f.base_rows > 0 and f.mb_enrolment_date is null and f.mb_election_date is null
        and f.enrolment_rows > 0 and f.qualifying_enrolment_rows = 0, 1, 0)                as f17,
    iif(f.base_rows > 0 and f.mb_enrolment_date is null and f.mb_election_date is null
        and f.qualifying_enrolment_rows > 0, 1, 0)                                         as f18,
    iif(f.base_rows > 0 and (f.mb_enrolment_date is not null or f.mb_election_date is not null)
        and f.has_range_event = 0, 1, 0)                                                   as f19,
    iif(f.has_range_event = 1 and f.state_ranges = 0, 1, 0)                                as f20,
    iif(f.state_ranges > 0 and f.covering_ranges = 0 and f.first_valid_from > @asof, 1, 0) as f21,
    iif(f.state_ranges > 0 and f.covering_ranges = 0
        and isnull(f.first_valid_from, @asof) <= @asof, 1, 0)                              as f22
) x
cross apply (select
    case
        when x.e01 = 1 then 'E01' when x.e02 = 1 then 'E02' when x.e03 = 1 then 'E03'
        when x.e04 = 1 then 'E04'
        when x.f10 = 1 then 'P10' when x.f11 = 1 then 'P11' when x.f12 = 1 then 'P12'
        when x.f13 = 1 then 'P13' when x.f14 = 1 then 'P14' when x.f15 = 1 then 'P15'
        when x.f16 = 1 then 'P16' when x.f17 = 1 then 'P17' when x.f18 = 1 then 'P18'
        when x.f19 = 1 then 'P19' when x.f20 = 1 then 'P20' when x.f21 = 1 then 'P21'
        when x.f22 = 1 then 'P22'
        else 'P99'
    end as code,
    case
        when x.e01 = 1 then N'No Join / Renewal / Readmission event at all, in any campaign year, so the event-driven measure has nothing to count this contact from. The official query counts them from the subs invoice position alone.'
        when x.e02 = 1 then N'No Join / Renewal / Readmission event in THIS campaign year. The usual cause is that the Renewal derivation did not fire - it reads silv_payment_events and the settled cash transactions behind them, so a paid position with no settled cash reference produces no Renewal.'
        when x.e03 = 1 then N'The earliest Join / Renewal / Readmission event in the campaign year is dated AFTER the campaign year end, so usp_load_silv_daily_count drops it from stock and flow alike. A Renewal falling back to the cash transaction date is the usual way this happens.'
        when x.e04 = 1 then N'The paid-in event is dated after the as-of date - the contact is paid in later this campaign year. The event-driven measure builds through the year, so this closes on its own. Expect a lot of these in October.'
        when x.f10 = 1 then N'A paid-in event exists, but there is no brnz_contact row for this contact number, so no state range could be built and the range gate drops the contact.'
        when x.f11 = 1 then N'Every brnz_contact row for this number is flagged as a test record, so the silv_member_base driver excludes it and no state range exists to hang the event on.'
        when x.f12 = 1 then N'No brnz_rics_record row at all - the silv_member_base driver excludes the contact, so there is no state range and both paid measures drop it along with the active count. Logged as NO_RICS_RECORD.'
        when x.f13 = 1 then N'The latest rics record is Student grade (200000003), excluded from the silv_member_base driver, so no state range exists to hang the event on. Not overridden: no ended Student application with a qualifying row created on or after it (vw_student_superseded).'
        when x.f14 = 1 then N'No brnz_cust_trans row anywhere - the driver excludes the contact, which removes the state range and so both paid measures. Logged as NO_TRANSACTIONS where a valid enrolment exists behind it.'
        when x.f15 = 1 then N'Passes every silv_member_base driver test but has no member base row. Unexpected - re-run usp_load_silv_member_base and re-check.'
        when x.f16 = 1 then N'No brnz_enrolment row at all, and no ref_enrolment_exception fallback date, so no enrolment or election date could be derived and no state range was built.'
        when x.f17 = 1 then N'brnz_enrolment rows exist but none survives the rules in vw_enrolment_base, so no state range was built.'
        when x.f18 = 1 then N'Qualifying enrolment rows exist but no effective enrolment or election date reached silv_member_base. Check the per-contact aggregate in usp_load_silv_member_base.'
        when x.f19 = 1 then N'Dates exist on silv_member_base but no Join / Change / Readmission event was emitted, so nothing opened a state range for the paid-in event to join to.'
        when x.f20 = 1 then N'Range-opening events exist but no state range was built. Re-run usp_load_silv_member_state_ranges.'
        when x.f21 = 1 then N'The earliest state range starts after the as-of date, so there is no range for the paid-in event to join to yet.'
        when x.f22 = 1 then N'State ranges exist but none covers the as-of date - closed before it, or zero-length from a same-day supersede. Both paid measures join the same ranges as the active count, so no covering range means no paid count.'
        else N'In the official list, not in the EVENT number, and none of the known gates explains it. Extend the rule set in section 6c before quoting this list as complete.'
    end as reason
) g
where f.in_official = 1
  and f.in_event    = 0;

/*--------------------------------------------------------------------
    6d. EVENT: in the number, not in the official list     (-1 each)
        The same two source-side mechanisms as the payment side - it
        is the same official query. What differs is WHICH contacts
        land here: read event_paid_in_type, and RS-5.
--------------------------------------------------------------------*/
insert into #diff
(measure, direction, count_impact, reason_code, reason, all_reasons, contact_no,
 src_rows, src_paid_rows, src_paid_position, src_dedupe_winner_position, src_renewal_date,
 src_renewal_date_adj, has_bronze_subs_row, bronze_position, bronze_renewal_date_adj,
 bronze_is_deleted, has_payment_event, pay_invoice_position, pay_renewal_date_adj,
 pay_payment_date, pay_payment_source, has_event_paid_in, event_paid_in_type,
 event_paid_in_event_date, event_paid_in_date, event_paid_in_after_cy_end,
 bronze_contact_rows, bronze_nontest_rows, has_rics_record, rics_grade, has_transactions,
 base_rows, mb_enrolment_date, mb_election_date, mb_lapsed_date, enrolment_rows,
 qualifying_enrolment_rows, events, has_range_event, has_readmission, state_ranges,
 first_valid_from, covering_ranges, covering_grades, active_on_asof, paid_cells,
 event_cells, anomaly_types)
select
    'EVENT',
    'IN_LAYERCAKE_NOT_OFFICIAL',
    -1,
    g.code,
    g.reason,
    nullif(stuff(concat(iif(x.f01 = 1, ', Q01', ''), iif(x.f02 = 1, ', Q02', '')), 1, 2, ''), ''),
    f.contact_no,
    f.src_rows, f.src_paid_rows, f.src_paid_position, f.src_dedupe_winner_position, f.src_renewal_date,
    f.src_renewal_date_adj, f.has_bronze_subs_row, f.bronze_position, f.bronze_renewal_date_adj,
    f.bronze_is_deleted, f.has_payment_event, f.pay_invoice_position, f.pay_renewal_date_adj,
    f.pay_payment_date, f.pay_payment_source, f.has_event_paid_in, f.event_paid_in_type,
    f.event_paid_in_event_date, f.event_paid_in_date, f.event_paid_in_after_cy_end,
    f.bronze_contact_rows, f.bronze_nontest_rows, f.has_rics_record, f.rics_grade, f.has_transactions,
    f.base_rows, f.mb_enrolment_date, f.mb_election_date, f.mb_lapsed_date, f.enrolment_rows,
    f.qualifying_enrolment_rows, f.events, f.has_range_event, f.has_readmission, f.state_ranges,
    f.first_valid_from, f.covering_ranges, f.covering_grades, f.active_on_asof, f.paid_cells,
    f.event_cells, f.anomaly_types
from #facts f
cross apply (select
    iif(f.src_rows = 0, 1, 0)                         as f01,
    iif(f.src_rows > 0 and f.src_paid_rows = 0, 1, 0) as f02
) x
cross apply (select
    case when x.f01 = 1 then 'Q01' when x.f02 = 1 then 'Q02' else 'Q99' end as code,
    case
        when x.f01 = 1 then N'No Subs.vwSubsMemberStatuses row at all for this contact and campaign year, yet the event-driven measure counts them - typically a Join event this campaign year for a member with no subs record at all. Read event_paid_in_type.'
        when x.f02 = 1 then N'Source rows exist for this contact and campaign year but none is in a paid invoice position, yet the event-driven measure counts them. Read event_paid_in_type: a Join means they were counted from enrolment or election rather than from money, which is the designed difference between the two measures.'
        else N'Counted by the EVENT measure, excluded by the official query, and no mechanism identified. Extend the rule set in section 6d before quoting this list as complete.'
    end as reason
) g
where f.in_official = 0
  and f.in_event    = 1;

/*--------------------------------------------------------------------
    6e. THE BRIDGE ROWS, emitted once PER MEASURE so each measure's
        list nets to its own difference independently.
        B01 and B02 are identical for both - one official list.
--------------------------------------------------------------------*/

-- B01: official rows with no contact number. The agreed query counts them; bronze
--      skips them outright (they are unusable downstream - every join keys on the
--      contact number), so they can never match either measure.
insert into #diff (measure, direction, count_impact, reason_code, reason, all_reasons)
select m.measure, 'IN_OFFICIAL_NOT_LAYERCAKE', 1, 'B01',
       N'Official row with a NULL [Contact No.]. The agreed query counts rows; the bronze load skips null contact numbers outright because every downstream join keys on them, so this row can never reach either Layercake measure.',
       'B01'
from #src s
cross join (values ('PAYMENT'), ('EVENT')) m(measure)
where s.is_paid_position = 1
  and s.contact_no       is null;

-- B02: one row per EXTRA official row on the same contact and campaign year. The
--      agreed query counts rows; both Layercake measures count contacts, and
--      bronze keeps exactly one row per key.
insert into #diff (measure, direction, count_impact, reason_code, reason, all_reasons, contact_no,
                   src_rows, src_paid_rows, src_paid_position, src_dedupe_winner_position)
select m.measure, 'IN_OFFICIAL_NOT_LAYERCAKE', 1, 'B02',
       N'Duplicate row in the official list: this contact holds more than one paid-position row for the campaign year. The agreed query counts rows, bronze keeps exactly one row per (contact, campaign year) and both Layercake measures count contacts, so each extra row is one unit of difference.',
       'B02', o.contact_no, sa.src_rows, sa.src_paid_rows, sa.src_paid_position, sa.src_dedupe_winner_position
from #off o
join #src_agg sa on sa.contact_no = o.contact_no
cross apply (select top (case when o.qualifying_rows > 1 then o.qualifying_rows - 1 else 0 end)
                    1 as n
             from sys.all_columns) rep
cross join (values ('PAYMENT'), ('EVENT')) m(measure)
where o.qualifying_rows > 1;

-- B03: one row per EXTRA cell a contact occupies, per measure. The daily-count
--      join groups by (region, grade) and counts distinct contacts per cell, so a
--      contact with two covering ranges in different cells is counted twice. A
--      correctly chained contact has exactly one covering range.
insert into #diff (measure, direction, count_impact, reason_code, reason, all_reasons, contact_no,
                   state_ranges, covering_ranges, covering_grades, paid_cells)
select 'PAYMENT', 'IN_LAYERCAKE_NOT_OFFICIAL', -1, 'B03',
       N'Overlapping state ranges: this contact occupies more than one region/grade cell on the as-of date, so the daily-count join counts its payment more than once. A correctly chained contact has exactly one covering range - re-run usp_load_silv_member_state_ranges and check the event chain.',
       'B03', pc.contact_no, rg.state_ranges, ca.covering_ranges, ca.covering_grades, pc.paid_cells
from #paid_cells pc
left join #rng     rg on rg.contact_no = pc.contact_no
left join #cov_agg ca on ca.contact_no = pc.contact_no
cross apply (select top (case when pc.paid_cells > 1 then pc.paid_cells - 1 else 0 end)
                    1 as n
             from sys.all_columns) rep
where pc.paid_cells > 1;

insert into #diff (measure, direction, count_impact, reason_code, reason, all_reasons, contact_no,
                   state_ranges, covering_ranges, covering_grades, event_cells)
select 'EVENT', 'IN_LAYERCAKE_NOT_OFFICIAL', -1, 'B03',
       N'Overlapping state ranges: this contact occupies more than one region/grade cell on the as-of date, so the daily-count join counts its paid-in event more than once. A correctly chained contact has exactly one covering range - re-run usp_load_silv_member_state_ranges and check the event chain.',
       'B03', ec.contact_no, rg.state_ranges, ca.covering_ranges, ca.covering_grades, ec.event_cells
from #event_cells ec
left join #rng     rg on rg.contact_no = ec.contact_no
left join #cov_agg ca on ca.contact_no = ec.contact_no
cross apply (select top (case when ec.event_cells > 1 then ec.event_cells - 1 else 0 end)
                    1 as n
             from sys.all_columns) rep
where ec.event_cells > 1;

-- B04: stored silv_daily_count versus the per-contact re-derivation above, per
--      measure. Expected to be zero on @asof = today, which is rebuilt every run.
insert into #diff (measure, direction, count_impact, reason_code, reason, all_reasons)
select 'PAYMENT', iif(@pm_drift < 0, 'IN_OFFICIAL_NOT_LAYERCAKE', 'IN_LAYERCAKE_NOT_OFFICIAL'),
       -@pm_drift, 'B04',
       concat(N'Stored silv_daily_count.paid_count on this date is ', @pm_silver,
              N', but re-deriving it per contact from the current silver tables gives ', @pm_cells,
              N'. silv_daily_count is FORWARD ONLY - a date already in etl_daily_count_loaded is never re-derived by a daily run - so on a past date this is the point-in-time record showing through. On today it should be zero. Remedy: exec Layercake.usp_load_silver @RebuildFrom = ''',
              convert(varchar(10), @asof, 23), N'''.'),
       'B04'
where @pm_drift <> 0;

insert into #diff (measure, direction, count_impact, reason_code, reason, all_reasons)
select 'EVENT', iif(@ev_drift < 0, 'IN_OFFICIAL_NOT_LAYERCAKE', 'IN_LAYERCAKE_NOT_OFFICIAL'),
       -@ev_drift, 'B04',
       concat(N'Stored silv_daily_count.paid_count_event on this date is ', @ev_silver,
              N', but re-deriving it per contact from the current silver tables gives ', @ev_cells,
              N'. Same forward-only mechanism as the payment measure. On today it should be zero. Remedy: exec Layercake.usp_load_silver @RebuildFrom = ''',
              convert(varchar(10), @asof, 23), N'''.'),
       'B04'
where @ev_drift <> 0;

-- B05: gold behind silver, per measure. Only ever raised when anchored on GOLD,
--      since the star is a straight SUM of silv_daily_count_detail.
insert into #diff (measure, direction, count_impact, reason_code, reason, all_reasons)
select 'PAYMENT', iif(@pm_gold_delta < 0, 'IN_OFFICIAL_NOT_LAYERCAKE', 'IN_LAYERCAKE_NOT_OFFICIAL'),
       -@pm_gold_delta, 'B05',
       concat(N'The gold star carries PaidMembers = ', @pm_gold, N' on this date and silver carries ', @pm_silver,
              N'. fact_daily_member_count_detail is a straight SUM of silv_daily_count_detail, so they should agree. Remedy: exec Layercake.usp_load_gold.'),
       'B05'
where @pm_gold_delta <> 0;

insert into #diff (measure, direction, count_impact, reason_code, reason, all_reasons)
select 'EVENT', iif(@ev_gold_delta < 0, 'IN_OFFICIAL_NOT_LAYERCAKE', 'IN_LAYERCAKE_NOT_OFFICIAL'),
       -@ev_gold_delta, 'B05',
       concat(N'The gold star carries PaidMembersEvent = ', @ev_gold, N' on this date and silver carries ', @ev_silver,
              N'. Same mechanism as the payment measure. Remedy: exec Layercake.usp_load_gold.'),
       'B05'
where @ev_gold_delta <> 0;


/*====================================================================
    7. PAYMENT vs EVENT
       The two measures against each other rather than against the
       official list. Both sides already hold a covering state range,
       so the range gate cancels out and these codes are purely about
       the paid-in test - which is exactly where the two measures are
       designed to differ.

       Row count identity: EVENT_ONLY contacts minus PAYMENT_ONLY
       contacts is the gap between the two Layercake contact counts.
====================================================================*/
select
    k.contact_no,
    cast(iif(pc.contact_no is not null, 1, 0) as bit) as in_payment,
    cast(iif(ec.contact_no is not null, 1, 0) as bit) as in_event,
    cast(iif(o.contact_no  is not null, 1, 0) as bit) as in_official,
    g.comparison,
    g.code                                            as reason_code,
    g.reason,
    cast(iif(py.contact_no is not null, 1, 0) as bit) as has_payment_event,
    py.pay_invoice_position,
    py.pay_renewal_date_adj,
    ep.event_paid_in_type,
    ep.event_paid_in_event_date,
    ep.event_paid_in_date,
    isnull(ep.after_cy_end, 0)                        as event_paid_in_after_cy_end,
    isnull(ca.covering_grades, '')                    as covering_grades,
    cast(isnull(ca.any_non_lapse, 0) as bit)          as active_on_asof
into #measures
from (
    select contact_no from #paid_cells
    union
    select contact_no from #event_cells
) k
left join #paid_cells  pc on pc.contact_no = k.contact_no
left join #event_cells ec on ec.contact_no = k.contact_no
left join #off         o  on o.contact_no  = k.contact_no
left join #pay         py on py.contact_no = k.contact_no
left join #ev_paid     ep on ep.contact_no = k.contact_no
left join #cov_agg     ca on ca.contact_no = k.contact_no
cross apply (select
    iif(ec.contact_no is not null and pc.contact_no is null, 1, 0) as event_only,
    iif(pc.contact_no is not null and ec.contact_no is null, 1, 0) as payment_only
) d
cross apply (select
    -- EVENT only: counted from an event, not (yet) from money
    iif(d.event_only = 1 and py.contact_no is not null and py.pay_renewal_date_adj > @asof, 1, 0)   as m04,
    iif(d.event_only = 1 and py.contact_no is not null and py.pay_renewal_date_adj is null, 1, 0)   as m05,
    iif(d.event_only = 1 and py.contact_no is null and ep.event_paid_in_type = 'Join', 1, 0)        as m01,
    iif(d.event_only = 1 and py.contact_no is null and ep.event_paid_in_type = 'Readmission', 1, 0) as m02,
    iif(d.event_only = 1 and py.contact_no is null and ep.event_paid_in_type = 'Renewal', 1, 0)     as m03,
    -- PAYMENT only: money moved but the event measure has nothing to count from
    iif(d.payment_only = 1 and ep.contact_no is null, 1, 0)                                         as m10,
    iif(d.payment_only = 1 and ep.after_cy_end = 1, 1, 0)                                           as m11,
    iif(d.payment_only = 1 and isnull(ep.after_cy_end, 0) = 0
        and ep.event_paid_in_date > @asof, 1, 0)                                                    as m12
) x
cross apply (select
    case
        when x.m04 = 1 then 'M04' when x.m05 = 1 then 'M05' when x.m01 = 1 then 'M01'
        when x.m02 = 1 then 'M02' when x.m03 = 1 then 'M03'
        when x.m10 = 1 then 'M10' when x.m11 = 1 then 'M11' when x.m12 = 1 then 'M12'
        else 'M99'
    end as code,
    iif(d.event_only = 1, 'EVENT_ONLY', 'PAYMENT_ONLY') as comparison,
    case
        when x.m04 = 1 then N'EVENT counts this contact, PAYMENT does not yet: a payment event exists but its adjusted renewal date is after the as-of date. The two measures converge later this campaign year.'
        when x.m05 = 1 then N'EVENT counts this contact, PAYMENT never will this year: the payment event has a NULL adjusted renewal date, so the payment-driven count has no date to start from.'
        when x.m01 = 1 then N'EVENT counts this contact from a JOIN event and there is no payment event at all for the campaign year. Join is enrolment-dated for Candidates and election-dated for RPQ direct entries, so this is the designed first-year difference between the two measures - counted as paid before any money moved.'
        when x.m02 = 1 then N'EVENT counts this contact from a READMISSION event with no payment event for the campaign year. Readmission is itself payment-derived, so check whether the subs position has since moved.'
        when x.m03 = 1 then N'EVENT counts this contact from a RENEWAL event with no payment event for the campaign year - the Renewal was derived from a cash transaction the current subs invoice position does not reflect.'
        when x.m10 = 1 then N'PAYMENT counts this contact, EVENT does not: there is no Join / Renewal / Readmission event in this campaign year for the measure to count from. The usual cause is that the Renewal derivation did not fire.'
        when x.m11 = 1 then N'PAYMENT counts this contact, EVENT does not: the earliest paid-in event in the campaign year is dated after the campaign year end, so usp_load_silv_daily_count drops it.'
        when x.m12 = 1 then N'PAYMENT counts this contact, EVENT does not yet: the paid-in event is dated after the as-of date while the adjusted renewal date has already arrived.'
        else N'The two measures disagree on this contact and no mechanism was identified. Extend the rule set in section 7.'
    end as reason
) g
where d.event_only   = 1
   or d.payment_only = 1;

create unique clustered index cx_measures on #measures (contact_no);


/*====================================================================
    8. OUTPUT
====================================================================*/
declare @pm_impact int = (select isnull(sum(count_impact), 0) from #diff where measure = 'PAYMENT');
declare @ev_impact int = (select isnull(sum(count_impact), 0) from #diff where measure = 'EVENT');

-- RS-0: run context
select
    'RS-0 run context'              as result_set,
    @asof                           as asof_date,
    @cy                             as campaign_year,
    @layercake_source               as layercake_source,
    @silver_asof                    as silver_loaded_through,
    iif(@asof = @today, 'yes',
        'NO - the source side is current-state, so this compares today''s source positions against a historical pipeline state')
                                    as asof_is_today,
    iif(@has_anom = 1, 'yes', 'no') as anomaly_table_present;

-- RS-1: the assertion, one row per measure. Read this first; if either row is not
-- PASS, that measure's list is not safe to quote.
select 'RS-1 count reconciliation' as result_set, v.*
from (
    select
        'PAYMENT'      as measure,
        'paid_count / PaidMembers - the subs invoice position, the same data the official query reads' as measure_definition,
        @off_rows      as official_paid,
        @pm_anchor     as layercake_paid,
        @pm_difference as difference,
        @pm_impact     as sum_of_count_impact,
        (select count(*) from #diff where measure = 'PAYMENT') as rows_in_list,
        iif(@pm_impact = @pm_difference,
            'PASS - the list accounts for every unit of the difference',
            'FAIL - the list does not net to the difference; do not use it until this reads PASS') as verdict
    union all
    select
        'EVENT',
        'paid_count_event / PaidMembersEvent - Join + Renewal + Readmission, resets each 1 October and builds through the year',
        @off_rows,
        @ev_anchor,
        @ev_difference,
        @ev_impact,
        (select count(*) from #diff where measure = 'EVENT'),
        iif(@ev_impact = @ev_difference,
            'PASS - the list accounts for every unit of the difference',
            'FAIL - the list does not net to the difference; do not use it until this reads PASS')
) v
order by v.measure desc;

-- RS-2: the bridge for both measures, line by line
select 'RS-2 bridge' as result_set, measure, seq, step, value, note
from (values
    ('PAYMENT',  1, 'Official paid (rows in Subs.vwSubsMemberStatuses)', @off_rows,       'The agreed query, exactly as written'),
    ('PAYMENT',  2, '  less rows with no contact number (B01)',          -@off_null_rows, 'Skipped outright by the bronze load'),
    ('PAYMENT',  3, '  less extra rows on the same contact+year (B02)',  -@off_dup_extra, 'The agreed query counts rows, not contacts'),
    ('PAYMENT',  4, '= Official paid contacts',                          @off_distinct,   'Distinct contact numbers'),
    ('PAYMENT',  5, 'Layercake PAYMENT contacts',                        @pm_distinct,    'Covering state range AND a payment event whose adjusted renewal date has arrived'),
    ('PAYMENT',  6, '  contact-level difference',                        @off_distinct - @pm_distinct, 'Equals the (+1) rows minus the (-1) rows'),
    ('PAYMENT',  7, 'Layercake PAYMENT contacts',                        @pm_distinct,    ''),
    ('PAYMENT',  8, '  plus extra region/grade cells (B03)',             @pm_overcount,   'Overlapping state ranges counted more than once'),
    ('PAYMENT',  9, '= Re-derived cell total',                           @pm_cells,       'What the daily-count join produces from current silver'),
    ('PAYMENT', 10, '  plus stored-vs-derived drift (B04)',              @pm_drift,       'Forward-only load; zero on today'),
    ('PAYMENT', 11, '= silv_daily_count.paid_count',                     @pm_silver,      ''),
    ('PAYMENT', 12, '  plus gold behind silver (B05)',                   @pm_gold_delta,  'Only applied when anchored on GOLD'),
    ('PAYMENT', 13, '= Layercake PAYMENT (the anchor)',                  @pm_anchor,      'The number this measure reconciles to'),
    ('EVENT',    1, 'Official paid (rows in Subs.vwSubsMemberStatuses)', @off_rows,       'The same agreed query - one official list, two measures'),
    ('EVENT',    2, '  less rows with no contact number (B01)',          -@off_null_rows, 'Skipped outright by the bronze load'),
    ('EVENT',    3, '  less extra rows on the same contact+year (B02)',  -@off_dup_extra, 'The agreed query counts rows, not contacts'),
    ('EVENT',    4, '= Official paid contacts',                          @off_distinct,   'Distinct contact numbers'),
    ('EVENT',    5, 'Layercake EVENT contacts',                          @ev_distinct,    'Covering state range AND a Join/Renewal/Readmission paid-in date that has arrived'),
    ('EVENT',    6, '  contact-level difference',                        @off_distinct - @ev_distinct, 'Equals the (+1) rows minus the (-1) rows'),
    ('EVENT',    7, 'Layercake EVENT contacts',                          @ev_distinct,    ''),
    ('EVENT',    8, '  plus extra region/grade cells (B03)',             @ev_overcount,   'Overlapping state ranges counted more than once'),
    ('EVENT',    9, '= Re-derived cell total',                           @ev_cells,       'What the daily-count join produces from current silver'),
    ('EVENT',   10, '  plus stored-vs-derived drift (B04)',              @ev_drift,       'Forward-only load; zero on today'),
    ('EVENT',   11, '= silv_daily_count.paid_count_event',               @ev_silver,      ''),
    ('EVENT',   12, '  plus gold behind silver (B05)',                   @ev_gold_delta,  'Only applied when anchored on GOLD'),
    ('EVENT',   13, '= Layercake EVENT (the anchor)',                    @ev_anchor,      'The number this measure reconciles to')
) v(measure, seq, step, value, note)
order by measure desc, seq;

-- RS-3: reason summary by measure
select
    'RS-3 reasons'               as result_set,
    d.measure,
    d.direction,
    d.reason_code,
    count(*)                     as rows_in_list,
    count(distinct d.contact_no) as contacts,
    sum(d.count_impact)          as count_impact,
    min(d.reason)                as reason
from #diff d
group by d.measure, d.direction, d.reason_code
order by d.measure desc, sum(d.count_impact) desc, d.reason_code;

-- RS-4: THE LIST. One row per unit of difference, per measure.
select
    'RS-4 list'  as result_set,
    d.measure,
    d.direction,
    d.count_impact,
    d.reason_code,
    d.all_reasons,
    d.contact_no,
    d.reason,
    d.src_rows,
    d.src_paid_rows,
    d.src_paid_position,
    d.src_dedupe_winner_position,
    d.src_renewal_date,
    d.src_renewal_date_adj,
    d.has_bronze_subs_row,
    d.bronze_position,
    d.bronze_renewal_date_adj,
    d.bronze_is_deleted,
    d.has_payment_event,
    d.pay_invoice_position,
    d.pay_renewal_date_adj,
    d.pay_payment_date,
    d.pay_payment_source,
    d.has_event_paid_in,
    d.event_paid_in_type,
    d.event_paid_in_event_date,
    d.event_paid_in_date,
    d.event_paid_in_after_cy_end,
    d.bronze_contact_rows,
    d.bronze_nontest_rows,
    d.has_rics_record,
    d.rics_grade,
    d.has_transactions,
    d.base_rows,
    d.mb_enrolment_date,
    d.mb_election_date,
    d.mb_lapsed_date,
    d.enrolment_rows,
    d.qualifying_enrolment_rows,
    d.events,
    d.has_range_event,
    d.has_readmission,
    d.state_ranges,
    d.first_valid_from,
    d.covering_ranges,
    d.covering_grades,
    d.active_on_asof,
    d.paid_cells,
    d.event_cells,
    d.anomaly_types
from #diff d
order by d.measure desc, d.direction, d.reason_code, d.contact_no;

-- RS-5: PAYMENT vs EVENT summary. The two measures explained against each other
-- rather than against the official list. EVENT_ONLY contacts minus PAYMENT_ONLY
-- contacts is exactly the gap between the two Layercake contact counts.
select
    'RS-5 measures compared'             as result_set,
    m.comparison,
    m.reason_code,
    count(*)                             as contacts,
    sum(cast(m.in_official as int))      as also_in_official,
    sum(iif(m.active_on_asof = 1, 1, 0)) as also_active_on_asof,
    min(m.reason)                        as reason
from #measures m
group by m.comparison, m.reason_code
order by m.comparison, m.reason_code;

-- RS-5b: the same in one line
select
    'RS-5b measures compared - totals' as result_set,
    @pm_distinct                                                        as payment_contacts,
    @ev_distinct                                                        as event_contacts,
    @ev_distinct - @pm_distinct                                         as event_minus_payment,
    (select count(*) from #measures where comparison = 'EVENT_ONLY')    as event_only_contacts,
    (select count(*) from #measures where comparison = 'PAYMENT_ONLY')  as payment_only_contacts,
    iif(@ev_distinct - @pm_distinct
        = (select count(*) from #measures where comparison = 'EVENT_ONLY')
        - (select count(*) from #measures where comparison = 'PAYMENT_ONLY'),
        'PASS - the two comparison lists account for the whole gap between the measures',
        'FAIL - the comparison lists do not net to the gap between the measures')
                                                                        as verdict;

-- RS-6: the contacts behind RS-5
select
    'RS-6 measures compared - list' as result_set,
    m.comparison,
    m.reason_code,
    m.contact_no,
    m.in_official,
    m.in_payment,
    m.in_event,
    m.reason,
    m.has_payment_event,
    m.pay_invoice_position,
    m.pay_renewal_date_adj,
    m.event_paid_in_type,
    m.event_paid_in_event_date,
    m.event_paid_in_date,
    m.event_paid_in_after_cy_end,
    m.covering_grades,
    m.active_on_asof
from #measures m
order by m.comparison, m.reason_code, m.contact_no;

drop table if exists #src, #off, #src_agg, #cover, #paid_cells, #ev_paid, #event_cells,
                     #cohort, #anom_raw, #anom, #rics, #bcontact, #trans, #bsubs, #pay,
                     #enr_raw, #enr, #mb, #ev, #rng, #cov_agg, #facts, #diff, #measures;
go

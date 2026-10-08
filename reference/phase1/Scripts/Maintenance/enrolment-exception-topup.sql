/*************************************************************************************
    Layercake.ref_enrolment_exception - INSERT-ONLY top-up
    ---------------------------------------------------------------------------------
    !! SUPERSEDED (20260928_02). YOU ALMOST CERTAINLY DO NOT NEED THIS SCRIPT.
    !!
    !! Every silver load now does this top-up automatically:
    !!     Layercake.usp_load_ref_enrolment_exception   (silver module 8a)
    !!     04_Programmability/StoredProcedures/Silver/
    !! It is insert-only in exactly the same way, and it additionally flags a
    !! captured contact whose qualifying enrolment/election row has since
    !! appeared (superseded_at / superseded_reason) and logs a new capture to
    !! etl_daily_count_pending_rebuild. Running usp_run_daily_load - or just
    !! usp_load_ref_enrolment_exception on its own - is the supported way to
    !! capture newly-qualifying contacts.
    !!
    !! WHY IT IS STILL HERE: it reads the SOURCE views directly, so it can
    !! capture ahead of a bronze load, on a database whose bronze is stale, or
    !! when you want to see the cohort before committing to a full run.
    !!
    !! WHAT TO WATCH IF YOU DO USE IT: the qualifying rules below are a
    !! HAND-COPIED duplicate of Layercake.vw_enrolment_base, needed only
    !! because this script predates bronze. The pipeline module reads that view
    !! and holds no copy, and the phase 03 seed that held the third copy is
    !! retired - so this is the ONLY remaining duplicate, kept in step by hand.
    !! If it has drifted, this script will capture a different cohort from the
    !! one the pipeline would. Check the view before trusting the output, and
    !! prefer the module wherever bronze is current.
    ---------------------------------------------------------------------------------
    Run it when you want to capture contacts who have STARTED to qualify since
    the last capture (e.g. data corrections in CE, or a driver change such as
    20260910_01 that admits a wider population) WITHOUT waiting for a load. It
    is INSERT-ONLY - existing rows are never updated or deleted, so no contact
    already captured can lose their derived history. If you want the existing
    rows RE-DERIVED under the current rules instead, truncate the table and run
    a silver load; the module captures the whole cohort from scratch.

    Rows inserted here are stamped _capture_source = 'topup', so they are
    distinguishable from the module's own captures afterwards. The module picks
    them up for supersession / re-opening like any other row.

    Safe to re-run. Nothing happens if there is nothing new.

    NOT part of the deploy. Run it by hand:
        sqlcmd -S <server> -d <db> -U <user> -P <pwd> -i enrolment-exception-topup.sql -b -N -I

    Run BEFORE the next silver load if you want the additions in the next refresh.
    Requires migrations 20260910_01 (the campaign-year audit columns) and
    20260928_02 (the lifecycle columns) to have been applied.

    A capture made here is a RETROSPECTIVE CHANGE and this script does not log
    one - the derived dates are usually years old, and the daily-count walk
    will not rebuild dates it has already marked loaded. The next silver load
    picks the change up for today, and the state-range module logs the earliest
    affected date; check and apply it as usual:

        select * from Layercake.etl_daily_count_pending_rebuild
        where applied_at is null;
*************************************************************************************/

set nocount on;
go

-- campaign year Y = 01 Oct (Y-1) .. 30 Sep (Y)
declare @today      date = cast(getdate() as date);
declare @current_cy int  = year(@today) + iif(month(@today) >= 10, 1, 0);

declare @paid_position table (position varchar(18) primary key);
insert into @paid_position values ('Full Concession'), ('Fully Paid'), ('Partially Paid'), ('Pre-Subs Payment');

/*----------------------------------------------------------------
    1. THE DRIVER
       a. every (contact, campaign year) with a paid position, as far
          back as the subs view goes, up to the current year - minus
          anyone already captured (insert-only)
----------------------------------------------------------------*/
select distinct
    cast(s.[Contact No.] as nvarchar(200)) as contact_no,
    s.[Campaign Year]                      as campaign_year
into #paid_year
from Subs.vwSubsMemberStatuses s
where s.[Contact No.] is not null
  and s.[Campaign Year] is not null
  and s.[Campaign Year] <= @current_cy
  and s.[Member Invoice Position] in (select position from @paid_position)
  and not exists (select 1 from Layercake.ref_enrolment_exception x
                  where x.contact_no = s.[Contact No.]);

create unique clustered index cx_paid_year on #paid_year (contact_no, campaign_year);

/*----------------------------------------------------------------
       b. the per-year grid: a row = the contact is ACTIVE in that
          campaign year (paid it, or paid the one before)
----------------------------------------------------------------*/
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

create unique clustered index cx_contact_year on #contact_year (contact_no, campaign_year);

/*----------------------------------------------------------------
       c. condensed to one row per contact
----------------------------------------------------------------*/
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

create unique clustered index cx_active on #active (contact_no);

/*----------------------------------------------------------------
    2. ONE contact record per driver contact number
----------------------------------------------------------------*/
select v.contact_no, v.ContactId, v.MemberGrade_Description,
       v.election_date_on_contact, v.contact_created_date
into #contact
from (
    select
        cast(c.Rics_contactno as nvarchar(200)) as contact_no,
        c.ContactId,
        c.MemberGrade_Description,
        cast(c.Rics_ElectionDate as date)       as election_date_on_contact,
        cast(c.CreatedOn         as date)       as contact_created_date,
        row_number() over (partition by c.Rics_contactno
                           order by iif(c.StateCode = 0, 0, 1), c.CreatedOn, c.ContactId) as rn
    from CE.vwContact c
    where c.Rics_contactno is not null
      and exists (select 1 from #active a where a.contact_no = c.Rics_contactno)
      and not exists (select 1 from ce.tblcontact_test_records tst
                      where tst.contactid = c.ContactId)
) v
where v.rn = 1;

create unique clustered index cx_contact on #contact (contact_no);

/*----------------------------------------------------------------
    3. EVERY source enrolment row for the cohort, scored against the
       qualifying rules of Layercake.vw_enrolment_base (copied - keep
       in step with the view and with the seed script)
----------------------------------------------------------------*/
select
    cast(e.[Contact No] as nvarchar(200))                                                  as contact_no,
    cast(iif(e.[Enrolment Date] < '19800101', '19800101', e.[Enrolment Date]) as date)     as enrolment_date,
    cast(e.[Election Date] as date)                                                        as election_date,
    e.[Application Type]                                                                   as application_type,
    -- PART 1 - enrolment-supplying row under the full valid-view rules
    case when e.[Enrolment Date] is not null
          and e.[Route ID] in (
              '0504153D-6716-4C23-874E-32E2E2C4E3BF',   -- APC Other
              'B0CDFF73-5825-4E73-9852-EBC6B88448E1',   -- APC Prelim
              'E2231B53-7181-4AD8-BE15-3DAED8F0727F',   -- APC Research
              '6942A086-7EF8-48E7-993F-B0148F419117',   -- APC Structured Training 12
              '916E1056-C88B-4055-88A3-9FD0B57A98E7',   -- APC Structured Training 24
              '058D1F92-BD26-48AC-8603-8CC98B7DDA8E',   -- Associate Assessment
              'D4AC2D23-E733-4B2D-9693-2D1D2A0ACF46',   -- Senior Professional Assessment - 2017
              '7B867DC6-8F1F-4503-8A07-BFABDDD03CB2',   -- Specialist Assessment
              '2037C0AD-008D-48EE-B05A-9C90B4D61504')   -- Academic
          and e.[Application Type] is not null
          and e.[Application Type] not in (
              'Chartered Alternative Designation',
              'Alternative Designation',
              'Apprenticeship',
              'Credential Application',
              'Fellowship',
              'Honorary',
              'Re-admission',
              'Scheme',
              'Student')
          and not (e.[Election Date] is null and e.[End Date] is not null)
          and (e.[End Date] is null
               or e.[End Date] > dateadd(day, 14, iif(e.[Enrolment Date] < '19800101', '19800101', e.[Enrolment Date])))
         then 1 else 0 end                                                                 as qualifies_enrolment,
    -- PART 2 - election-supplying row (NOT IN semantics: null type -> 0)
    case when e.[Election Date] is not null
          and e.[Application Type] not in (
              'Student',
              'Scheme',
              'Chartered Alternative Designation',
              'Accreditation Application',
              'Additional Role',
              'Alternative Designation',
              'Appeal',
              'Apprenticeship',
              'Complaint Report',
              'Concession',
              'Credential Application',
              'Deceased',
              'Deferral Application',
              'Fixed Penalty Review',
              'Mentor',
              'Re-admission',
              'Recognised Qualification',
              'Removal',
              'Resignation',
              'Route Change',
              'Fellowship')
          and isnull(rt.apuk_name, '') <> 'Registered Valuer Top Up'
         then 1 else 0 end                                                                 as qualifies_election
into #enr
from synapse_ce.vwEnrolments e
left join synapse_ce.apuk_route rt
    on rt.apuk_routeid = e.[Route ID]
where e.[Contact No] is not null
  and exists (select 1 from #active a where a.contact_no = e.[Contact No]);

create clustered index cx_enr on #enr (contact_no);

/*----------------------------------------------------------------
    4. Per contact: does anything qualify, and the earliest date of
       each kind on ANY row
----------------------------------------------------------------*/
select
    contact_no,
    count(*)                 as source_enrolment_rows,
    max(qualifies_enrolment) as has_qualifying_enrolment,
    max(qualifies_election)  as has_qualifying_election,
    -- STUDENT: a Student application row never supplies a date (see seed header)
    min(iif(isnull(application_type, '') <> 'Student', enrolment_date, null)) as earliest_enrolment_date,
    min(iif(isnull(application_type, '') <> 'Student', election_date,  null)) as earliest_election_date
into #enr_contact
from #enr
group by contact_no;

create unique clustered index cx_enr_contact on #enr_contact (contact_no);

/*----------------------------------------------------------------
    5. Capture (insert-only: #paid_year already excludes captured rows)
----------------------------------------------------------------*/
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
    a.contact_no,
    c.ContactId,
    c.MemberGrade_Description,
    d.derived_enrolment_date,
    d.derived_election_date,
    d.enrolment_date_source,
    d.election_date_source,
    1,                                  -- the driver IS the subs view
    a.first_active_campaign_year,
    a.last_active_campaign_year,
    a.first_paid_campaign_year,
    a.last_paid_campaign_year,
    a.active_campaign_years,
    a.paid_campaign_years,
    a.is_active_current,
    a.is_paid_current,
    isnull(e.source_enrolment_rows, 0),
    'topup'
from #active a
join #contact c
    on c.contact_no = a.contact_no
left join #enr_contact e
    on e.contact_no = a.contact_no
-- rule 2: Elected or Enrolled
cross apply (select
    iif(e.earliest_election_date is not null
        or isnull(c.MemberGrade_Description, '') <> 'Candidate', 1, 0) as is_elected
) k
-- rule 3: the dates and where each came from
cross apply (select
    coalesce(e.earliest_enrolment_date,
             iif(k.is_elected = 0, c.contact_created_date, null))            as derived_enrolment_date,
    case when e.earliest_enrolment_date is not null then 'Enrolment row (non-qualifying)'
         when k.is_elected = 0                       then 'Contact CreatedOn' end as enrolment_date_source,
    case when k.is_elected = 1
         then coalesce(e.earliest_election_date, c.election_date_on_contact, c.contact_created_date) end
                                                                             as derived_election_date,
    case when k.is_elected = 0                        then null
         when e.earliest_election_date is not null    then 'Enrolment row (non-qualifying)'
         when c.election_date_on_contact is not null  then 'Rics_ElectionDate'
         else 'Contact CreatedOn (no election date)' end                     as election_date_source
) d
where isnull(e.has_qualifying_enrolment, 0) = 0
  and isnull(e.has_qualifying_election,  0) = 0
  and (d.derived_enrolment_date is not null or d.derived_election_date is not null);

print concat(@@rowcount, ' new exception rows captured (current campaign year ', @current_cy, ').');

drop table #paid_year, #contact_year, #active, #contact, #enr, #enr_contact;
go

/*====================================================================
    Review the additions
====================================================================*/
select
    iif(derived_election_date is not null, 'Elected', 'Enrolled')   as classification,
    member_grade,
    enrolment_date_source,
    election_date_source,
    count(*)                                                        as contacts,
    sum(iif(source_enrolment_rows = 0, 1, 0))                       as no_enrolment_rows_at_all,
    sum(iif(is_active_current = 1, 1, 0))                           as active_current_cy,
    sum(iif(is_paid_current = 1, 1, 0))                             as paid_current_cy,
    min(first_active_campaign_year)                                 as earliest_active_cy,
    min(coalesce(derived_election_date, derived_enrolment_date))    as earliest_derived_date,
    max(coalesce(derived_election_date, derived_enrolment_date))    as latest_derived_date
from Layercake.ref_enrolment_exception
group by iif(derived_election_date is not null, 'Elected', 'Enrolled'),
         member_grade, enrolment_date_source, election_date_source
order by classification, member_grade, enrolment_date_source, election_date_source;

-- the two review cohorts described in the seed header
select
    count(*)                                                          as captured,
    sum(iif(x.is_active_current = 0, 1, 0))                           as not_active_current_cy,
    sum(iif(x.is_active_current = 0 and c.Rics_LapsedDate is null, 1, 0))
                                                                      as not_active_and_no_lapse_date,
    sum(iif(d.earliest_derived_date > datefromparts(x.first_active_campaign_year - 1, 10, 1), 1, 0))
                                                                      as derived_date_after_first_active_cy
from Layercake.ref_enrolment_exception x
left join CE.vwContact c
    on c.ContactId = x.contact_id
cross apply (select
    case when x.derived_enrolment_date is null then x.derived_election_date
         when x.derived_election_date is null then x.derived_enrolment_date
         when x.derived_enrolment_date < x.derived_election_date then x.derived_enrolment_date
         else x.derived_election_date end as earliest_derived_date
) d;

-- worth eyeballing: created-date fallbacks for elected members, and any
-- suspiciously recent derived dates (a 2026 created date on a long-standing
-- member says the CE record was recreated, not that they joined in 2026)
select top (50) *
from Layercake.ref_enrolment_exception
where election_date_source = 'Contact CreatedOn (no election date)'
order by derived_election_date desc;
go

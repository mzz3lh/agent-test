/*====================================================================
    Layercake.usp_load_silv_member_base
    Silver layer - loads one table
====================================================================*/

/*====================================================================
    8. Layercake.silv_member_base   (was #mbase)
    ------------------------------------------------------------------
    The per-contact base every downstream silver derivation reads.
    Full re-derive: truncate + insert in one transaction, so a failure
    leaves the previous run's content intact.

    #rics_record feeds it and is used nowhere else, so it stays as a
    #temp table inside this module. #enr_base is staged from
    Layercake.vw_enrolment_base, which holds the qualifying-row rules
    themselves - module 10 reads the same view so the anomaly report
    cannot drift from the driver.

    v6 SOURCING: dates come from a per-contact aggregate of #enr_base.
      enrolment_date: earliest clamped enrolment date across ALL staged
          rows - Part-1 rows AND enrolment dates riding on Part-2
          election rows, EXCEPT RPQ rows, which supply none (a direct
          entry never enrolled - the rule and the reason are in the
          view). So a contact whose only enrolment date sat on an RPQ
          election row lands here with enrolment_date null, and module 9
          derives the Join/RPQ it should always have had.
      election_date:  earliest election date across Part-2 rows.
      is_rpq:         from the row that supplied the earliest election
          date (an RPQ-flagged row wins a date tie).
    ENROLMENT EXCEPTIONS (07): where the aggregate finds nothing, the
    curated ref_enrolment_exception dates are coalesced in - real rows
    always win, the fallback self-retires. Since 20260928_02 that table
    is maintained by the pipeline (module 8a,
    usp_load_ref_enrolment_exception, runs immediately before this one)
    rather than captured once by a phase 03 seed, which is what stopped
    a daily load and a from-scratch rebuild disagreeing on the most
    recent day's counts. Nothing here changed: the coalesce is per date
    and real rows still win, and superseded_at on the exception row is
    DELIBERATELY NOT TESTED below. A superseded row is already inert
    wherever real data covers it, and it is still filling a real gap
    wherever the real rows supply only one of the two dates - testing
    the flag would reopen that gap.
    ENROLMENT AFTER THE FIRST PAID YEAR (subs-history backdating): the
    recorded enrolment date (real row or 07 fallback) is then compared
    with the contact's FIRST PAID campaign year in silv_payment_events.
    Where the recorded date sits in a LATER campaign year, the source
    says "joined" years after the subs history says they were paying,
    and derived as recorded the Join landed in a year they had not
    paid - counting them as paid from the Join event - with the earlier
    payments falling through as Renewals before any Join. So the
    enrolment date is BACKDATED to the first paid year: the payment
    event's date in that year (renewal_date_adj, else the cash
    transaction date, clamped inside the year; the year start when
    neither is known). The Join then lands where the paying started,
    every later paid year derives as a Renewal, and the recorded year
    gets no Join of its own - the contact counts as paid there only if
    a paid position exists for it. Same campaign year = no change (the
    Join year IS the first paid year already).
    The ELECTION date gets the same treatment ONLY where there is no
    enrolment date at all: the election is then the Join anchor (a
    Join/RPQ, or the Change that opens the state range), and a recorded
    election in a later campaign year than the first paid one produced
    the same "joiner after years of Renewals". Where an enrolment date
    exists the election is never moved - the enrolment is the anchor
    and the grade change stays where the source put it.
    ENROLMENT BEFORE THE FIRST PAID YEAR (subs-history forward-dating):
    the same rule in the other direction. A contact with a valid
    enrolment in CY N but NO paid position for N, whose first paid
    position is a LATER campaign year, got its Join in N - a year they
    had not paid - and the first paid year fell through as a Renewal.
    The first paid year is the join year, so the enrolment date is
    moved FORWARD to it, to the same join date the backdating uses.
    BOUNDED BY THE PAYMENT HISTORY, and the bound is load-bearing:
    silv_payment_events only reaches back as far as the subs history
    that was loaded (CY2022 at the time of writing), so for a member
    who enrolled before that, "first paid year" is just the first year
    of data and says nothing about when they started paying. Unbounded,
    the rule would move every long-standing member's Join into the
    first loaded year. So a date is only moved forward where its
    recorded campaign year is ON OR AFTER the earliest campaign year in
    silv_payment_events (@pay_floor_cy) - only there is "no payment in
    the recorded year" evidence of anything. Backdating needs no bound:
    a payment EARLIER than the recorded date is always evidence.
    The ELECTION date is moved forward in two cases:
      * no enrolment date at all - the election is the Join anchor, so
        it takes the rule exactly as the enrolment date would (the
        mirror of the backdated case above);
      * the enrolment date WAS moved forward and the recorded election
        sits before the new join date - left there, the Change would
        precede the Join, open the state range in the unpaid year the
        rule exists to close, and the later Join would drop the member
        back to Candidate. The election is carried to the join date, so
        the two land on the same day and the day ends elected (module
        11 orders enrolment before election). An election on or after
        the join date is not touched.
    Kept visible, like the 07 exceptions: recorded_enrolment_date /
    recorded_election_date hold the date the source recorded and
    enrolment_from_subs_history / election_from_subs_history mark the
    row, in either direction (recorded > effective = backdated,
    recorded < effective = moved forward); module 10 reports the
    cohorts as ENROLMENT_AFTER_FIRST_PAID / ELECTION_AFTER_FIRST_PAID
    and ENROLMENT_BEFORE_FIRST_PAID / ELECTION_BEFORE_FIRST_PAID.
    Note the lapse invalidation below tests the MOVED date. Backdated:
    a contact lapse between the first paid year and the recorded
    enrolment now stands as a real Lapse rather than being treated as
    stale - the member did lapse, and a later payment re-opens the
    state range as a Readmission. Moved forward: a contact lapse
    BEFORE the new join date is invalidated as stale, like any other
    lapse that predates the Join (STALE_LAPSE_IGNORED in module 10).

    DRIVER EXCLUSIONS:
      * Student grade (200000003) on the latest rics record - 'Rules to
        note' #2 - UNLESS the Student status is SUPERSEDED in the
        enrolment history: the most recently created Student application
        is ended, and a qualifying enrolment/election row was created on
        or after it (Layercake.vw_student_superseded, where the test is
        defined). The grade is stale in that case - the Student row is
        closed and an APC / Associate row opened, typically minutes
        apart on the same day, and the rics record never moved - so the
        contact is kept and treated as any other member-base row.
      * NO RICS RECORD AT ALL - a contact with no row in
        brnz_rics_record has no membership record behind it, so it is
        not a member by the source definition and produces no events.
        The excluded cohort is logged as NO_RICS_RECORD by
        usp_load_silv_data_anomaly (module 10) for feedback to the
        client, and the same test is repeated on the payment-derived
        Readmission in module 9 - that is the only event that can open
        a state range without a silv_member_base row.
      * NO TRANSACTION HISTORY - a contact with no row in
        brnz_cust_trans has never transacted, so it is not a valid
        contact and counts as neither active nor paid. Same treatment
        as the rics-record exclusion: no member base row, no events, no
        state range, and the test repeated on the Readmission in module
        9. The PAID count needs no separate test - it is derived from
        the same state-range join as the active count, so a contact
        with no range is dropped from both.
        Reported as NO_TRANSACTIONS by module 10, but only where the
        contact HAS a valid enrolment or election - a contact with
        neither is not a member on any reading, so removing it is not
        an anomaly worth reporting.
====================================================================*/
create or alter procedure Layercake.usp_load_silv_member_base
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id     bigint,
            @ins        int,
            @del        int,
            @rc         int,
            @substep_ts datetime2(3),
            @err        nvarchar(4000),
            @pay_floor_cy int,
            @step       nvarchar(128);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'silver', 'silv_member_base', @log_id output;
        set @substep_ts = sysdatetime();

        -- latest rics record per membership number, excluding test contacts.
        -- The Student grade (apuk_membergrade = 200000003) is NOT pre-filtered
        -- here: the latest record's grade is carried through so the driver
        -- below can exclude Student contacts outright.
        -- This row set is also the driver's DEFINITION OF "has a rics record":
        -- a contact number absent from it has no membership record at all.
        -- statecode = 0 deliberately NOT applied - deactivated records would
        -- otherwise drop lapse dates (open issue with Raj).
        select *
        into #rics_record
        from (
            select
                rec.apuk_ricsmembershipnumber,
                rec.apuk_lapseddate,
                rec.apuk_retirementdate,
                rec.apuk_lapsecode,
                rec.apuk_membergrade,
                row_number() over (partition by rec.apuk_ricsmembershipnumber order by rec.ModifiedOn desc) n
            from Layercake.brnz_rics_record rec
            where rec._is_deleted = 0
              and rec.apuk_ricsmembershipnumber is not null
              and not exists (select 1
                              from Layercake.brnz_contact_test_record tst
                              where tst.contactid = rec.apuk_contactid
                                and tst._is_deleted = 0)
        ) v
        where v.n = 1;
        set @rc = @@rowcount;

        create unique clustered index cx_rics on #rics_record (apuk_ricsmembershipnumber);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #rics_record (latest per member)', @rc, @substep_ts output;

        -- v6: enrolment source rows, staged once into #enr_base so the
        -- per-contact aggregate, the lineage resolver and the RPQ flag all
        -- read the SAME row set.
        --
        -- THE RULES THEMSELVES LIVE IN Layercake.vw_enrolment_base - part 1
        -- (valid enrolments) and part 2 (elections), with every rule and its
        -- history commented there. They moved out of this module so
        -- usp_load_silv_data_anomaly can apply the identical test when it
        -- decides whether an EXCLUDED contact nevertheless had a valid
        -- enrolment or election. It is a view, so the plan is the same as
        -- when the two statements sat here.
        -- Materialised into a #temp because it is read three times below.
        select *
        into #enr_base
        from Layercake.vw_enrolment_base;
        set @rc = @@rowcount;

        create clustered index cx_enr_base on #enr_base ([Contact No]);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #enr_base (enrolment + election rows)', @rc, @substep_ts output;

        -- contacts whose Student status is superseded in the enrolment
        -- history: the latest Student application is ended and a qualifying
        -- row was created on or after it. The rule lives in
        -- Layercake.vw_student_superseded, shared with module 10 and the
        -- reconciliation scripts. Staged so the driver's Student test below
        -- is a seek, and so the cohort size lands in the progress log. The
        -- view is one row per contact; the unique index holds it to that.
        select [Contact No] as contact_no
        into #student_superseded
        from Layercake.vw_student_superseded;
        set @rc = @@rowcount;

        create unique clustered index cx_student_superseded on #student_superseded (contact_no);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #student_superseded (Student grade overridden)', @rc, @substep_ts output;

        -- the contact's FIRST PAID campaign year, and the date a payment event
        -- in it carries in module 9 (renewal_date_adj, else the cash
        -- transaction date) clamped inside that campaign year
        -- (01 Oct Y-1 .. 30 Sep Y), falling back to the year start when
        -- neither date is known. The driver below moves a recorded
        -- enrolment date that sits in a DIFFERENT campaign year to this
        -- date: backdated from a later year, forward-dated from an earlier
        -- one (the forward move bounded by @pay_floor_cy, staged next).
        -- Read from silv_payment_events (module 7, built before this module)
        -- so "paid" stays defined in exactly one place. One row per contact;
        -- the unique index asserts it.
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
        ) v
        cross apply (select datefromparts(v.campaign_year - 1, 10, 1) as cy_start,
                            datefromparts(v.campaign_year,     9, 30) as cy_end) cy
        cross apply (select cast(coalesce(v.renewal_date_adj, v.payment_date, cy.cy_start) as date) as d) d
        where v.rn = 1;
        set @rc = @@rowcount;

        create unique clustered index cx_first_paid on #first_paid (contact_no);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #first_paid (first paid campaign year per contact)', @rc, @substep_ts output;

        -- the FLOOR of the payment history: the earliest campaign year
        -- silv_payment_events holds for anyone. A recorded date is only
        -- moved FORWARD to the first paid year where its own campaign year
        -- is on or after this - before it there is no subs history to be
        -- missing from, so "first paid later" is the edge of the data, not a
        -- fact about the member (see the header). Derived, not configured,
        -- so loading earlier subs history widens the rule by itself; the
        -- value goes into the progress log because a stray early payment row
        -- would widen it too, and that should be visible. Null on an empty
        -- payment table: every comparison below is then false, nothing moves.
        select @pay_floor_cy = min(first_paid_cy) from #first_paid;
        set @step = concat(N'payment history floor: CY', isnull(cast(@pay_floor_cy as nvarchar(10)), N' (none)'),
                           N' (forward-dating bound)');
        exec Layercake.usp_etl_log_progress @log_id, @step, null, @substep_ts output;

        begin tran;

        -- full re-derive: the previous content is replaced wholesale inside
        -- this transaction, so a failure leaves the last good version in place
        select @del = count(*) from Layercake.silv_member_base;
        truncate table Layercake.silv_member_base;

        insert into Layercake.silv_member_base
        (contact_id, contact_no, enrolment_date, election_date, is_rpq, election_enr_id,
         enrolment_from_exception, election_from_exception,
         recorded_enrolment_date, enrolment_from_subs_history,
         recorded_election_date, election_from_subs_history,
         contact_lapsed_date, lapsed_date,
         lapse_reason_id, lapse_reason_name, retirement_date, source_enr_id, rpq_variant_id,
         country_id, gender_id)
        select
            c.ContactId                             as contact_id,
            c.Rics_contactno                        as contact_no,
            dts.enrolment_date                      as enrolment_date,
            dts.election_date                       as election_date,
            isnull(cast(elec.is_rpq as int), 0)     as is_rpq,
            elec.[ENR ID]                           as election_enr_id,
            iif(e.[Enrolment Date] is null and x.derived_enrolment_date is not null, 1, 0) as enrolment_from_exception,
            iif(e.[Election Date]  is null and x.derived_election_date  is not null, 1, 0) as election_from_exception,
            -- the dates the source recorded, kept ONLY where moved (either
            -- direction: recorded > effective = backdated, < = moved forward)
            iif(bk.enr_moved  = 1, rd.recorded_enrolment_date, null) as recorded_enrolment_date,
            bk.enr_moved                            as enrolment_from_subs_history,
            iif(bk.elec_moved = 1, rd.recorded_election_date,  null) as recorded_election_date,
            bk.elec_moved                           as election_from_subs_history,
            -- raw contact lapse date, kept for the stale-lapse anomaly check
            cast(c.Rics_LapsedDate as date)         as contact_lapsed_date,
            -- contact-level lapse date, invalidated if the member re-enrolled/
            -- was elected since lapsing (checked against the EFFECTIVE dates:
            -- coalesced, then moved to the first paid year - see the header)
            iif(c.Rics_LapsedDate < dts.enrolment_date or c.Rics_LapsedDate < dts.election_date,
                null, cast(c.Rics_LapsedDate as date)) as lapsed_date,
            isnull(lr.id, 0)                        as lapse_reason_id,
            lr.reason_name                          as lapse_reason_name,
            cast(rec.apuk_retirementdate as date)   as retirement_date,
            lin.[ENR ID]                            as source_enr_id,
            isnull(rv.id, 0)                        as rpq_variant_id,
            isnull(ctry.id, 0)                      as country_id,
            isnull(g.id, 0)                         as gender_id
        from Layercake.brnz_contact c
        left join (
            -- v6 aggregate over the staged rows (see #enr_base above)
            select
                [Contact No],
                min(enrolment_date) as [Enrolment Date],
                min(election_date)  as [Election Date]
            from #enr_base
            group by [Contact No]
        ) e
            on c.Rics_contactno = e.[Contact No]
        -- enrolment exception backfill (07): curated fallback dates for the
        -- migration-gap contacts. Maintained by module 8a
        -- (usp_load_ref_enrolment_exception), which runs immediately before
        -- this module on every silver load. superseded_at is not tested - see
        -- the header.
        left join Layercake.ref_enrolment_exception x
            on x.contact_no = c.Rics_contactno
        -- recorded dates: real enrolment rows first, exception fallback
        -- second. A real row appearing later automatically supersedes the
        -- exception.
        cross apply (select
            coalesce(e.[Enrolment Date], x.derived_enrolment_date) as recorded_enrolment_date,
            coalesce(e.[Election Date],  x.derived_election_date)  as recorded_election_date
        ) rd
        -- subs-history date correction (see the header): the recorded dates
        -- are compared with the first paid campaign year. Campaign year of a
        -- date = its year, +1 from October.
        left join #first_paid fp
            on fp.contact_no = c.Rics_contactno
        cross apply (select
            year(rd.recorded_enrolment_date) + iif(month(rd.recorded_enrolment_date) >= 10, 1, 0) as enr_cy,
            year(rd.recorded_election_date)  + iif(month(rd.recorded_election_date)  >= 10, 1, 0) as elec_cy
        ) rcy
        -- which way, if at all, the JOIN ANCHOR moves: the enrolment date
        -- where one exists, else the election date. -1 = backdated (first
        -- paid year is EARLIER than the recorded one - always evidence),
        -- +1 = moved forward (first paid year is LATER, and the recorded
        -- year is inside the payment history, so its missing payment is
        -- evidence too), 0 = stays as recorded. No first paid year at all
        -- (fp null) compares false throughout and lands on 0.
        cross apply (select
            case when fp.first_paid_cy < rcy.enr_cy  then -1
                 when fp.first_paid_cy > rcy.enr_cy  and rcy.enr_cy  >= @pay_floor_cy then 1
                 else 0 end as enr_dir,
            case when rd.recorded_enrolment_date is not null then 0   -- the enrolment is the anchor
                 when fp.first_paid_cy < rcy.elec_cy then -1
                 when fp.first_paid_cy > rcy.elec_cy and rcy.elec_cy >= @pay_floor_cy then 1
                 else 0 end as elec_anchor_dir
        ) dir
        cross apply (select
            iif(dir.enr_dir <> 0, 1, 0) as enr_moved,
            -- the election moves as the anchor (no enrolment date), or is
            -- CARRIED forward with an enrolment that moved past it - never
            -- with a backdated one, and never when it already sits on or
            -- after the new join date
            iif(   dir.elec_anchor_dir <> 0
                or (dir.enr_dir = 1 and rd.recorded_election_date < fp.join_date),
                1, 0) as elec_moved
        ) bk
        -- effective dates: each moved to the first paid year's join date
        -- where its flag above fired, else as recorded.
        cross apply (select
            iif(bk.enr_moved  = 1, fp.join_date, rd.recorded_enrolment_date) as enrolment_date,
            iif(bk.elec_moved = 1, fp.join_date, rd.recorded_election_date)  as election_date
        ) dts
        -- lineage: the #enr_base row that supplied the earliest qualifying
        -- date, tie-broken deterministically on created datetime then ENR ID.
        -- Guaranteed one row per contact, so the per-contact event derivation
        -- cannot fan out. Kept on the REAL aggregate (e), not the coalesced
        -- dates: an exception-sourced date has no enrolment row to point at,
        -- so source_enr_id stays null and rpq_variant resolves to N/A.
        outer apply (
            select top (1) v.[ENR ID], v.[Route ID]
            from #enr_base v
            where v.[Contact No] = c.Rics_contactno
              and (   (e.[Enrolment Date] is not null and v.enrolment_date = e.[Enrolment Date])
                   or (e.[Enrolment Date] is null     and v.election_date  = e.[Election Date]))
            order by v.[Created DateTime], v.[ENR ID]
        ) lin
        -- the election row that supplied the earliest election date: carries
        -- the is_rpq flag (an RPQ-flagged row wins a same-date tie) and the
        -- ENR ID used in anomaly details
        outer apply (
            select top (1) v.[ENR ID], v.is_rpq
            from #enr_base v
            where v.[Contact No]  = c.Rics_contactno
              and v.election_date = e.[Election Date]
            order by v.is_rpq desc, v.[Created DateTime], v.[ENR ID]
        ) elec
        left join Layercake.silv_ref_rpq_variant rv
            on  lin.[Route ID] = rv.variant_id
        left join #rics_record rec
            on c.Rics_contactno = rec.apuk_ricsmembershipnumber
        left join Layercake.silv_ref_lapse_reason lr
            on rec.apuk_lapsecode = lr.lapse_code
        left join Layercake.silv_ref_country ctry
            on c.rics_countryid = ctry.country_id
        left join Layercake.silv_ref_gender g
            on c.GenderCode = g.gender_code
        where c._is_deleted = 0
          and c.Rics_contactno is not null
          -- No rics record at all -> not a member by the source definition.
          -- #rics_record already holds exactly one row per membership number
          -- (test contacts removed), so a null here means brnz_rics_record
          -- carries nothing for this contact number: no grade, no lapse code,
          -- no retirement date to test. Logged as NO_RICS_RECORD by module 10.
          and rec.apuk_ricsmembershipnumber is not null
          -- Student rics-grade exclusion applied to the DRIVER: a contact
          -- whose latest membership record is Student grade produces no
          -- events at all. Null grades on a record that EXISTS are kept.
          -- OVERRIDDEN where the enrolment history shows the Student status
          -- superseded (#student_superseded above): the grade is stale, and
          -- the contact is a member-base row like any other.
          and (   isnull(rec.apuk_membergrade, 0) <> 200000003
               or exists (select 1
                          from #student_superseded ss
                          where ss.contact_no = c.Rics_contactno))
          -- No transaction history at all -> not a valid contact. A contact
          -- with no row in brnz_cust_trans has never transacted, so it is
          -- counted as neither active nor paid. No approved/settled filter
          -- here: the test is the EXISTENCE of a transaction, not whether it
          -- cleared (the payment derivation in module 7 keeps its own
          -- approved = 1 rule). Soft-deleted rows do not count - the source
          -- no longer carries them. Logged as NO_TRANSACTIONS by module 10
          -- where a valid enrolment or election exists.
          and exists (select 1
                      from Layercake.brnz_cust_trans ct
                      where ct.accountnum  = c.Rics_contactno
                        and ct._is_deleted = 0)
          and not exists (select 1
                          from Layercake.brnz_contact_test_record tst
                          where tst.contactid = c.ContactId
                            and tst._is_deleted = 0);
        set @ins = @@rowcount;

        commit;
        exec Layercake.usp_etl_log_progress @log_id, N'rebuild silv_member_base (per-contact base)', @ins, @substep_ts output;
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

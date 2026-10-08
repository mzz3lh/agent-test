/*====================================================================
    Layercake.usp_load_silv_membership_events
    Silver layer - loads one table
====================================================================*/

/*====================================================================
    9. Layercake.silv_membership_events
    ------------------------------------------------------------------
    Full re-derive into #ev_stage, then diff-sync on event_nk (a
    deterministic natural key per event). event_id stays stable for
    unchanged rows.

    Event split (RPQ first, then Change):
      Join/Candidate - contact has an enrolment date. That is the
                       EFFECTIVE date from silv_member_base: real row,
                       else 07 fallback, then MOVED by module 8 to the
                       first paid campaign year where the recorded date
                       sits in a different one, so the Join lands where
                       the paying started. Backdated from a later year
                       (ENROLMENT_AFTER_FIRST_PAID in module 10); moved
                       forward from an earlier year that has no paid
                       position, but only where that year is inside the
                       payment history (ENROLMENT_BEFORE_FIRST_PAID) -
                       the bound and the reason for it are in module 8.
      Join/RPQ       - THE DIRECT ENTRY BRANCH: an election with NO
                       enrolment date anywhere. That is the entire test.
                       is_rpq decides only the SUBTYPE now ('RPQ' where a
                       source row evidences the route, else 'Direct
                       Entry'); it used to gate the branch, and gated it
                       wrongly three separate ways - a 07-curated
                       election has no real row to read the flag off, an
                       RPQ row's own enrolment date defeated the test
                       upstream, and a direct entry on any route the flag
                       does not name scored 0 like the rest. A Change
                       then fired instead, asserting a candidacy that
                       nothing in the source supports.
                       The election date is
                       the EFFECTIVE one too: with no enrolment date it
                       is the Join anchor, so module 8 moves it to the
                       first paid campaign year under the same rule
                       (ELECTION_AFTER_FIRST_PAID / ELECTION_BEFORE_
                       FIRST_PAID). The same moved date reaches the
                       Change below for a non-RPQ election-only contact,
                       and an election that an enrolment was moved
                       forward past is carried to the same join date.
      Join/Subscription - THE PAYMENT-DERIVED JOIN, for a contact who
                       has a paid position but NEITHER date, so neither
                       branch above can fire. In practice that is a
                       contact module 8 dropped from the base: Student
                       grade on the latest rics record, or no rics
                       record at all. They used to emit a lone Renewal -
                       a renewal of a membership that had never begun -
                       counting as neither active nor paid (no Join, so
                       no state range) while still appearing in the
                       renewal numbers, with nothing reporting it.
                       THE SUBSCRIPTION IS THE JOIN when nothing else
                       evidences one, and it lands on the FIRST payment
                       event, so every later paid year renews.
                       Repeats Readmission's NO TRANSACTION HISTORY
                       guard - it is the other event that opens a state
                       range with no member base row - but deliberately
                       NOT its NO RICS RECORD guard, that cohort being
                       the larger half of what the branch exists to fix.
                       Grade N/A by construction, which is why module 11
                       gives the subtype its own state mapping. A
                       matching Lapse is derived below off the same
                       contact-level date, because the Lapse rule proper
                       reads silv_member_base and so can never reach
                       these contacts.
      ALL THREE Join types also require the contact to have a VALID PAYMENT:
                       at least one row in silv_payment_events, i.e. a
                       paid invoice position in Subs.vwSubsMemberStatuses
                       (via brnz_subs_status) for ANY campaign year. A
                       contact who has never held a paid position gets no
                       Join, so no state range opens on the enrolment /
                       election date alone. Contact-level, not join-year:
                       a payment in a later year still qualifies. The
                       dropped cohort is logged as JOIN_NO_PAYMENT by
                       usp_load_silv_data_anomaly. Join/Subscription
                       satisfies it by construction - the event IS a
                       silv_payment_events row - so it carries no test
                       of its own, as Readmission does not.
      Change         - an election WITH an enrolment date: the exact
                       complement of Join/RPQ. The enrolment is the
                       candidacy the member moves out of, so without one
                       there is no Change to make (the missing-enrolment
                       cohort is still logged by
                       usp_load_silv_data_anomaly).
      Lapse          - contact-level lapse date, stale-date invalidation
                       already applied in silv_member_base. Derived in
                       TWO inserts: the rule proper off the base, and a
                       second one for the Join/Subscription cohort the
                       base does not hold - same date, same
                       invalidation, measured against the join date.
                       Without the second, nothing could close the range
                       that Join opens.
      Readmission    - payment in CY N, none in CY N-1, and EITHER at
                       least one payment earlier still (a returning
                       payer) OR the contact already held a Join in a
                       campaign year before N while CY N-1 sits inside
                       the payment history (a member of long standing
                       whose first paid position is N - see the second
                       limb at the insert). Also requires a
                       brnz_rics_record row AND a brnz_cust_trans row:
                       it is the only event that opens a state range
                       without a silv_member_base row, so both module-8
                       driver exclusions have to be repeated here. The
                       valid-payment test the Join events carry is
                       satisfied by construction: the event IS a
                       silv_payment_events row.
      Renewal        - EVERY other payment event, except one in the
                       contact's Join campaign year. Derived LAST, and
                       that order is load-bearing: it reads the Join
                       year and the Readmission years back out of
                       #ev_stage, so the two payment-derived types stay
                       mutually exclusive. VALID PAYMENT, by
                       construction and PER CAMPAIGN YEAR: a Renewal in
                       CY N exists only where silv_payment_events holds
                       a row for (contact, N), i.e. a paid invoice
                       position in Subs.vwSubsMemberStatuses for THAT
                       year. Last year's payment keeps the state range
                       open (nothing closes it but a Lapse), but it
                       does not renew this year - that needs this
                       year's paid position. Tighter than the Join
                       test, which is contact-level.

    IN-YEAR READMISSION NEEDS A REAL LAPSE. The subtype is carried by
    BOTH payment-derived events (Readmission and Renewal) and decided by
    ONE test, staged as #lapse_cy: does the contact hold a Lapse event in
    the SAME campaign year as the payment, dated on or before it? That
    is what an in-year readmission is - lapsed during the year, paid up
    before it ended - and it is the only reading the data supports.
    It used to be a date window: any payment dated between the campaign
    year's bulk lapse date and 30 Sep. THE BULK LAPSE DATE IS CONCEPTUAL.
    It is when members WOULD be lapsed for non-payment, not a record that
    any particular member WAS, so the window tagged every late payer as
    readmitted whether or not a lapse had ever been recorded against
    them. ref_campaign_year_config is no longer read here at all.
    One test for both event types deliberately: which of the two claims
    a given campaign year is an ordering detail of this module, and the
    same member circumstance must not label differently because of it.

    RENEWAL HAS NO PRIOR-YEAR TEST. It used to require a payment in
    CY N-1, which meant a payment whose history had a gap produced no
    event at all. Source payment history has gaps, so that test was
    reading a data problem as a business fact; a payment is now taken at
    face value as a renewal unless it is the first subscription (the
    Join year) or already emitted as a Readmission.

    Diff-sync order is DELETE -> UPDATE -> INSERT. See the comment at
    the sync: the filtered unique index on source_enr_id makes the order
    load-bearing whenever an event is re-keyed.

    Reads Layercake.silv_member_base (built by module 8) and
    Layercake.silv_payment_events (module 7).
====================================================================*/
create or alter procedure Layercake.usp_load_silv_membership_events
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id       bigint,
            @ins          int,
            @upd          int,
            @del          int,
            @rc           int,
            @substep_ts   datetime2(3),
            @err          nvarchar(4000),
            @pay_floor_cy int,
            @step         nvarchar(128);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'silver', 'silv_membership_events', @log_id output;
        set @substep_ts = sysdatetime();
        begin tran;

        -- staging table keyed on the natural key. If two ACTIVE contacts ever
        -- share a Rics_contactno, a per-contact event derivation fans out and
        -- this PK fails the load loudly (by design - fix the duplicate contact
        -- rather than silently double count).
        create table #ev_stage
        (
            event_nk             nvarchar(220) not null primary key,
            event_type           varchar(20) not null,
            event_subtype        varchar(20) not null,
            event_date           date not null,
            source_enr_id        uniqueidentifier null,
            contact_no           nvarchar(200) not null,
            grade_id             int not null,
            assessment_route_id  int not null,
            rpq_variant_id       int not null,
            hpb_id               int not null,
            country_id           int not null,
            gender_id            int not null,
            membership_status_id int not null,
            campaign_year        int not null,
            campaign_quarter     char(2) not null
        );

        -- Join / Candidate: one event per contact. The earliest qualifying
        -- (clamped) enrolment date is the event date - including enrolment
        -- dates riding on election rows (v6), but NOT on RPQ election rows:
        -- a direct entry supplies no enrolment date, so it falls through to
        -- Join/RPQ below instead of landing here (the rule is in
        -- vw_enrolment_base part 2).
        -- event_nk is contact-keyed so the event survives the lineage pointer
        -- moving to a different row.
        -- Candidate rows carry membership_status_id = 0 (N/A) per P2-16.
        -- VALID PAYMENT REQUIRED: see the where clause. A contact with no
        -- paid subs position in any campaign year gets no Join event.
        -- b.enrolment_date is the EFFECTIVE date: where the recorded one sat
        -- in a different campaign year from the contact's first paid position
        -- (later; or earlier, inside the payment history), module 8 has
        -- already moved it to that first paid year, so the Join (and #join_cy
        -- below, which the Renewal rule excludes) is the first paid year and
        -- every later paid year renews.
        insert into #ev_stage
        (event_nk, event_type, event_subtype, event_date, source_enr_id, contact_no, grade_id, assessment_route_id,
         rpq_variant_id, hpb_id, country_id, gender_id, membership_status_id, campaign_year, campaign_quarter)
        select
            N'JC:' + b.contact_no,
            'Join',
            'Candidate',
            b.enrolment_date,
            b.source_enr_id,            -- enrolment row that supplied the event date (lineage only)
            b.contact_no,
            mg.id,
            0,                          -- TODO: assessment route not yet mapped from source
            b.rpq_variant_id,
            0,                          -- TODO: hpb reference table still to be built
            b.country_id,
            b.gender_id,
            0,                          -- Candidate rows carry N/A (P2-16)
            case when month(b.enrolment_date) >= 10 then year(b.enrolment_date) + 1 else year(b.enrolment_date) end,
            case when month(b.enrolment_date) in (10,11,12) then 'Q1'
                 when month(b.enrolment_date) in (1,2,3)    then 'Q2'
                 when month(b.enrolment_date) in (4,5,6)    then 'Q3'
                 when month(b.enrolment_date) in (7,8,9)    then 'Q4'
                 else 'NK' end
        from Layercake.silv_member_base b
        inner join Layercake.silv_ref_membership_grade mg
            on  mg.grade_name = 'Candidate'
        where b.enrolment_date is not null
          -- NO VALID PAYMENT: the contact must hold at least one paid
          -- invoice position in Subs.vwSubsMemberStatuses (brnz_subs_status),
          -- read through silv_payment_events so the paid-position list is
          -- defined in exactly one place (module 7). Any campaign year
          -- counts - the test is that the contact has ever paid, not that
          -- they paid in the join year. Without it an enrolment date alone
          -- opened a state range and put a never-paid contact into the
          -- active count. Logged as JOIN_NO_PAYMENT by module 10.
          and exists (select 1
                      from Layercake.silv_payment_events p
                      where p.contact_no = b.contact_no);
        set @rc = @@rowcount;
        exec Layercake.usp_etl_log_progress @log_id, N'derive events: Join/Candidate', @rc, @substep_ts output;

        -- Join / RPQ - the DIRECT ENTRY branch. Identified FIRST, and the test
        -- is now the whole of it: an election with NO enrolment date anywhere.
        -- THE ELECTION IS THE JOIN when nothing preceded it. A Change event
        -- means Candidate -> Qualified, so it only means anything if there WAS
        -- a candidacy; with no enrolment date there never was one, and a
        -- Change asserted a transition out of a state the member was never in
        -- while emitting no Join at all. Such a contact was never counted as a
        -- joiner (members_joined reads event_type = 'Join'), opened a state
        -- range without the valid-payment test every Join carries, and - the
        -- reason this surfaced - had no Join campaign year, so a first payment
        -- years later could not be read as a Readmission (module 9's
        -- Readmission second limb needs join_cy) and fell through as a plain
        -- Renewal instead.
        -- is_rpq NO LONGER DECIDES THE BRANCH, only the subtype. It was the
        -- test, and it fails three ways: it is resolved by matching a REAL
        -- election row so a 07-curated contact always scores 0; an RPQ row's
        -- own enrolment date used to defeat it upstream (fixed in the view);
        -- and a direct entry on any route the flag does not name (it knows
        -- only 'Recognised Professional Qualification' and Assoc/Associate
        -- RPQ) scored 0 as well. None of those is evidence of a candidacy.
        -- SUBTYPE carries what is actually known: 'RPQ' only where the source
        -- row says so, else 'Direct Entry'. The event is the same either way -
        -- the member joined at Qualified grade - but the route is not, and
        -- labelling an unevidenced entry 'RPQ' would overstate a number that
        -- reports segment on. rpq_variant_id resolves to 0 (N/A) there too.
        -- MUST STAY THE EXACT COMPLEMENT OF THE CHANGE TEST BELOW, which
        -- repeats this condition negated. Split them and a contact gets both
        -- events, or neither.
        -- Mutually exclusive with Join/Candidate by construction.
        -- Status is evaluated at the election date (not getdate()), defaulting
        -- to Practising.
        insert into #ev_stage
        (event_nk, event_type, event_subtype, event_date, source_enr_id, contact_no, grade_id, assessment_route_id,
         rpq_variant_id, hpb_id, country_id, gender_id, membership_status_id, campaign_year, campaign_quarter)
        select
            N'JR:' + b.contact_no,
            'Join',
            -- evidenced route, or an honest 'Direct Entry' (see above)
            iif(b.is_rpq = 1, 'RPQ', 'Direct Entry'),
            b.election_date,
            b.source_enr_id,            -- enrolment row that supplied the event date (lineage only)
            b.contact_no,
            mg.id,
            0,                          -- TODO: assessment route not yet mapped from source
            b.rpq_variant_id,
            0,                          -- TODO: hpb reference table still to be built
            b.country_id,
            b.gender_id,
            isnull(ms.id, 1),
            case when month(b.election_date) >= 10 then year(b.election_date) + 1 else year(b.election_date) end,
            case when month(b.election_date) in (10,11,12) then 'Q1'
                 when month(b.election_date) in (1,2,3)    then 'Q2'
                 when month(b.election_date) in (4,5,6)    then 'Q3'
                 when month(b.election_date) in (7,8,9)    then 'Q4'
                 else 'NK' end
        from Layercake.silv_member_base b
        inner join Layercake.silv_ref_membership_grade mg
            on  mg.grade_name = 'Qualified'
        left join Layercake.silv_ref_membership_status ms
            on  ms.status_name = iif(b.retirement_date <= b.election_date, 'Retired', 'Practising')
        where b.enrolment_date is null
          and b.election_date is not null
          -- NO VALID PAYMENT: same test as Join/Candidate above, for the same
          -- reason - a direct-entry election with no paid subs position
          -- behind it must not open a state range. Note the Change insert
          -- below tests the base flags, not the staged events, so a dropped
          -- Join/RPQ does NOT fall through into Change. Logged as
          -- JOIN_NO_PAYMENT by module 10.
          and exists (select 1
                      from Layercake.silv_payment_events p
                      where p.contact_no = b.contact_no);
        set @rc = @@rowcount;
        exec Layercake.usp_etl_log_progress @log_id, N'derive events: Join/RPQ', @rc, @substep_ts output;

        -- Change (Candidate -> Qualified on election). v6: AFTER the RPQ
        -- events are identified, EVERY other qualifying election lands here.
        -- A CHANGE NOW REQUIRES AN ENROLMENT DATE, which is the whole of the
        -- complement above: the event means Candidate -> Qualified, and the
        -- enrolment date IS the candidacy it moves out of. An election with no
        -- enrolment anywhere is a direct entry and takes Join/RPQ instead -
        -- whatever its application type says, and whether the election is a
        -- real row or 07-curated. Nothing lands here without both dates.
        -- ELECTION_NO_ENROLMENT (module 10) keeps its exact test and still
        -- reports the unevidenced cohort - an elected contact with no
        -- enrolment record IS worth feeding back to the client - but it now
        -- records a direct-entry Join derived in the absence of enrolment
        -- data, not a Change emitted without a Join.
        -- Composition movement only - it never alters total Active/Paid
        -- counts, just grade-segmented ones.
        insert into #ev_stage
        (event_nk, event_type, event_subtype, event_date, source_enr_id, contact_no, grade_id, assessment_route_id,
         rpq_variant_id, hpb_id, country_id, gender_id, membership_status_id, campaign_year, campaign_quarter)
        select
            N'CH:' + b.contact_no,
            'Change',
            'Election',
            b.election_date,
            null,
            b.contact_no,
            mg.id,                          -- grade AFTER the change (Qualified)
            0, 0, 0,
            b.country_id,
            b.gender_id,
            isnull(ms.id, 0),
            case when month(b.election_date) >= 10 then year(b.election_date) + 1 else year(b.election_date) end,
            case when month(b.election_date) in (10,11,12) then 'Q1'
                 when month(b.election_date) in (1,2,3)    then 'Q2'
                 when month(b.election_date) in (4,5,6)    then 'Q3'
                 when month(b.election_date) in (7,8,9)    then 'Q4'
                 else 'NK' end
        from Layercake.silv_member_base b
        inner join Layercake.silv_ref_membership_grade mg
            on  mg.grade_name = 'Qualified'
        left join Layercake.silv_ref_membership_status ms
            on  ms.status_name = iif(b.retirement_date <= b.election_date, 'Retired', 'Practising')
        where b.election_date is not null
          -- the exact complement of the Join/RPQ test above, and it has to
          -- stay that way (see the note there)
          and b.enrolment_date is not null;
        set @rc = @@rowcount;
        exec Layercake.usp_etl_log_progress @log_id, N'derive events: Change', @rc, @substep_ts output;

        -- Staged out of #ev_stage before the payment-derived Join below, which
        -- filters on it: an insert must never read its own target table, and
        -- staging keeps the dependency visible. One row per contact - the two
        -- branches above are contact-keyed and mutually exclusive, and the
        -- unique index asserts it.
        select contact_no
        into #join_based
        from #ev_stage
        where event_type = 'Join';
        set @rc = @@rowcount;

        create unique clustered index cx_join_based on #join_based (contact_no);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #join_based (contacts with a Join from an enrolment/election date)', @rc, @substep_ts output;

        -- THE PAYMENT-DERIVED JOIN COHORT, with the first payment event that
        -- carries it and the contact attributes both that Join and its Lapse
        -- need.
        -- A contact lands here by holding a paid subs position while taking
        -- NEITHER branch above. Both need a date - Candidate an enrolment
        -- date, RPQ an election date - so such a contact has neither, and in
        -- practice has no silv_member_base row at all: module 8 drops a
        -- contact whose latest rics record carries the Student grade, and one
        -- that carries no rics record at all. Such a contact used to emit a
        -- lone Renewal - a renewal of a membership that had never begun. No
        -- Join meant no state range, so they counted as neither active nor
        -- paid while still appearing in the renewal numbers, and nothing
        -- reported it.
        -- READ FROM brnz_contact AND brnz_rics_record, not silv_member_base,
        -- precisely because the cohort is the contacts that base does not
        -- hold. One contact row per contact NUMBER under module 8a's
        -- tie-break (live record first, then oldest CreatedOn, then
        -- ContactId); the cross apply drops a contact number whose every row
        -- is a test record, which must not become a member. The rics record
        -- is outer applied - half this cohort has none, which is the point.
        -- NO TRANSACTION HISTORY is repeated here for the reason Readmission
        -- repeats it: this is the only other event that opens a state range
        -- with no silv_member_base row behind it, and a paid invoice position
        -- is not cash. NO RICS RECORD is deliberately NOT repeated - that
        -- cohort is the larger half of what this branch exists to fix.
        -- silv_payment_events is keyed on (contact_no, campaign_year) and
        -- every row carries a date, so ranking on the campaign year alone
        -- picks exactly one row per contact.
        select
            fp.contact_no,
            fp.campaign_year,
            fp.join_date,
            -- contact-level lapse date, invalidated where it predates the
            -- join, exactly as silv_member_base invalidates a stale lapse
            iif(cast(c.Rics_LapsedDate as date) < fp.join_date, null,
                cast(c.Rics_LapsedDate as date))   as lapsed_date,
            lr.reason_name                         as lapse_reason_name,
            isnull(ctry.id, 0)                     as country_id,
            isnull(g.id, 0)                        as gender_id
        into #pay_join
        from (
            select p.contact_no,
                   p.campaign_year,
                   cast(isnull(p.renewal_date_adj, p.payment_date) as date) as join_date,
                   row_number() over (partition by p.contact_no
                                      order by p.campaign_year) as rn
            from Layercake.silv_payment_events p
            where not exists (select 1 from #join_based j
                              where j.contact_no = p.contact_no)
              and exists (select 1
                          from Layercake.brnz_cust_trans ct
                          where ct.accountnum  = p.contact_no
                            and ct._is_deleted = 0)
        ) fp
        cross apply (
            select top (1) cc.Rics_LapsedDate, cc.rics_countryid, cc.GenderCode
            from Layercake.brnz_contact cc
            where cc.Rics_contactno = fp.contact_no
              and cc._is_deleted    = 0
              and not exists (select 1
                              from Layercake.brnz_contact_test_record tst
                              where tst.contactid   = cc.ContactId
                                and tst._is_deleted = 0)
            order by iif(cc.StateCode = 0, 0, 1), cc.CreatedOn, cc.ContactId
        ) c
        outer apply (
            select top (1) r.apuk_lapsecode
            from Layercake.brnz_rics_record r
            where r.apuk_ricsmembershipnumber = fp.contact_no
              and r._is_deleted = 0
            order by r.ModifiedOn desc
        ) rec
        left join Layercake.silv_ref_lapse_reason lr
            on  lr.lapse_code = rec.apuk_lapsecode
        left join Layercake.silv_ref_country ctry
            on  ctry.country_id = c.rics_countryid
        left join Layercake.silv_ref_gender g
            on  g.gender_code = c.GenderCode
        where fp.rn = 1;
        set @rc = @@rowcount;

        create unique clustered index cx_pay_join on #pay_join (contact_no);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #pay_join (paying contacts with no Join from a date)', @rc, @substep_ts output;

        -- Join / Subscription - THE PAYMENT-DERIVED JOIN.
        -- THE SUBSCRIPTION IS THE JOIN when nothing else evidences one. The
        -- first paid position is the point the contact became a member on the
        -- only record that exists for them, so it is the Join and every later
        -- paid year renews - #join_cy below picks this event up with the other
        -- two, so the Renewal rule excludes its campaign year like any other
        -- join year.
        -- THE SUBTYPE CLAIMS NOTHING IT CANNOT SHOW: 'Subscription' says a
        -- paid position and no route, grade or candidacy - the same honesty
        -- 'Direct Entry' carries on the branch above.
        -- GRADE IS ALWAYS N/A, by construction: a contact with an enrolment or
        -- an election date would have taken a branch above. That is why module
        -- 11 gives this subtype its own state mapping - the catch-all Join arm
        -- there opens the ELECTED state, and these members are not elected.
        -- Status N/A for the same reason: no election, so no grade to hold.
        -- campaign_year from the subs status, as Renewal takes it, not
        -- re-derived from the date.
        insert into #ev_stage
        (event_nk, event_type, event_subtype, event_date, source_enr_id, contact_no, grade_id, assessment_route_id,
         rpq_variant_id, hpb_id, country_id, gender_id, membership_status_id, campaign_year, campaign_quarter)
        select
            N'JS:' + j.contact_no,
            'Join',
            'Subscription',
            j.join_date,
            null,                       -- no enrolment row behind it
            j.contact_no,
            mg.id,                      -- N/A (see above)
            0, 0, 0,
            j.country_id,
            j.gender_id,
            0,                          -- N/A: no election, so no status held
            j.campaign_year,
            case when month(j.join_date) in (10,11,12) then 'Q1'
                 when month(j.join_date) in (1,2,3)    then 'Q2'
                 when month(j.join_date) in (4,5,6)    then 'Q3'
                 when month(j.join_date) in (7,8,9)    then 'Q4'
                 else 'NK' end
        from #pay_join j
        inner join Layercake.silv_ref_membership_grade mg
            on  mg.grade_name = 'N/A';
        set @rc = @@rowcount;
        exec Layercake.usp_etl_log_progress @log_id, N'derive events: Join/Subscription', @rc, @substep_ts output;

        -- Lapse. Event date from the contact-level lapse date (with the
        -- stale-date invalidation already applied in silv_member_base), reason
        -- resolved from the option set. Never inferred from absence of a
        -- renewal payment.
        insert into #ev_stage
        (event_nk, event_type, event_subtype, event_date, source_enr_id, contact_no, grade_id, assessment_route_id,
         rpq_variant_id, hpb_id, country_id, gender_id, membership_status_id, campaign_year, campaign_quarter)
        select
            N'LA:' + b.contact_no,
            'Lapse',
            left(isnull(b.lapse_reason_name, 'Not recorded'), 20),   -- Resigned / Deceased / Expelled / Removed / ...
            b.lapsed_date,
            null,
            b.contact_no,
            mg.id,                          -- grade AT the point of lapse
            0, 0, 0,
            b.country_id,
            b.gender_id,
            isnull(ms.id, 0),
            case when month(b.lapsed_date) >= 10 then year(b.lapsed_date) + 1 else year(b.lapsed_date) end,
            case when month(b.lapsed_date) in (10,11,12) then 'Q1'
                 when month(b.lapsed_date) in (1,2,3)    then 'Q2'
                 when month(b.lapsed_date) in (4,5,6)    then 'Q3'
                 when month(b.lapsed_date) in (7,8,9)    then 'Q4'
                 else 'NK' end
        from Layercake.silv_member_base b
        inner join Layercake.silv_ref_membership_grade mg
            on  mg.grade_name = case when b.election_date <= b.lapsed_date then 'Qualified'
                                     when b.enrolment_date is not null then 'Candidate'
                                     else 'N/A' end
        left join Layercake.silv_ref_membership_status ms
            on  ms.status_name = case when b.election_date <= b.lapsed_date
                                      then iif(b.retirement_date <= b.lapsed_date, 'Retired', 'Practising')
                                      else 'N/A' end
        where b.lapsed_date is not null;
        set @rc = @@rowcount;
        exec Layercake.usp_etl_log_progress @log_id, N'derive events: Lapse', @rc, @substep_ts output;

        -- Lapse for the PAYMENT-DERIVED JOINERS. The Lapse above reads
        -- silv_member_base, and the whole point of Join/Subscription is the
        -- contacts that base does not hold - so without this insert nothing
        -- could ever close the range that Join opens, and every payment-
        -- derived joiner would count as active for ever.
        -- SCOPED TO CONTACTS WITH NO silv_member_base ROW: where one exists
        -- the insert above has already emitted 'LA:' + contact_no, and the
        -- #ev_stage primary key would fail the load rather than double count.
        -- A base row carrying NEITHER date is the one case the two inserts
        -- read differently - module 8 cannot invalidate a stale lapse against
        -- dates that are both null, so such a contact could hold a Lapse
        -- before its Join/Subscription. No contact is in that state today
        -- (the base row would need both dates null AND a paid position); if
        -- one appears, the invalidation belongs in module 8 beside the
        -- others, not here.
        -- Same contact-level date as above, with the same stale-lapse
        -- invalidation - applied in #pay_join, against the join date rather
        -- than an enrolment/election date, because the join date is the only
        -- membership date these contacts have.
        -- Grade and status N/A, matching the Join: there was no election, so
        -- there is no grade held at the point of lapse.
        insert into #ev_stage
        (event_nk, event_type, event_subtype, event_date, source_enr_id, contact_no, grade_id, assessment_route_id,
         rpq_variant_id, hpb_id, country_id, gender_id, membership_status_id, campaign_year, campaign_quarter)
        select
            N'LA:' + j.contact_no,
            'Lapse',
            left(isnull(j.lapse_reason_name, 'Not recorded'), 20),
            j.lapsed_date,
            null,
            j.contact_no,
            mg.id,                          -- N/A (see above)
            0, 0, 0,
            j.country_id,
            j.gender_id,
            0,                              -- N/A
            case when month(j.lapsed_date) >= 10 then year(j.lapsed_date) + 1 else year(j.lapsed_date) end,
            case when month(j.lapsed_date) in (10,11,12) then 'Q1'
                 when month(j.lapsed_date) in (1,2,3)    then 'Q2'
                 when month(j.lapsed_date) in (4,5,6)    then 'Q3'
                 when month(j.lapsed_date) in (7,8,9)    then 'Q4'
                 else 'NK' end
        from #pay_join j
        inner join Layercake.silv_ref_membership_grade mg
            on  mg.grade_name = 'N/A'
        where j.lapsed_date is not null
          and not exists (select 1
                          from Layercake.silv_member_base b
                          where b.contact_no = j.contact_no);
        set @rc = @@rowcount;
        exec Layercake.usp_etl_log_progress @log_id, N'derive events: Lapse (payment-derived joiners)', @rc, @substep_ts output;
        -- [P2-11 open item with Alex: the Removed lapse code rule. Current
        --  behaviour: a Removed member whose lapse date predates a subsequent
        --  enrolment/election has the lapse invalidated in silv_member_base
        --  (no Lapse event); otherwise the Lapse event stands.]

        -- Both payment-derived events below read the Join and Lapse events
        -- staged above, so the two lookups are lifted out of #ev_stage FIRST -
        -- an insert must never read its own target table, and staging keeps
        -- the dependency visible. #readmit_cy, which only Renewal needs, is
        -- staged further down once Readmission has run.
        --
        -- #join_cy: the contact's Join campaign year. Readmission's second
        -- limb tests it; Renewal excludes it.
        select contact_no, min(campaign_year) as join_cy
        into #join_cy
        from #ev_stage
        where event_type = 'Join'          -- Candidate, RPQ or Subscription,
                                           -- mutually exclusive per contact
        group by contact_no;
        set @rc = @@rowcount;

        create unique clustered index cx_join_cy on #join_cy (contact_no);

        -- #lapse_cy: the contact's Lapse, with the campaign year it fell in.
        -- This is the whole of the In-Year Readmission test - an ACTUAL
        -- recorded lapse, not the conceptual bulk lapse date (see the header).
        -- One row per contact: silv_member_base carries a single contact-level
        -- lapse date, and the event_nk PK on #ev_stage ('LA:' + contact_no)
        -- holds it to that, so the unique index below cannot fail unless that
        -- invariant breaks - in which case it should fail loudly.
        select contact_no, campaign_year, event_date as lapse_date
        into #lapse_cy
        from #ev_stage
        where event_type = 'Lapse';
        set @rc = @rc + @@rowcount;

        create unique clustered index cx_lapse_cy on #lapse_cy (contact_no);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #join_cy + #lapse_cy (payment-event inputs)', @rc, @substep_ts output;

        -- The FLOOR of the payment history: the earliest campaign year
        -- silv_payment_events holds for anyone, defined exactly as module 8
        -- defines it. Readmission's second limb is bounded by it, and the
        -- bound is load-bearing - see the insert. Derived, not configured, so
        -- loading earlier subs history moves it by itself; logged because a
        -- stray early payment row would move it too, and that should be
        -- visible. Null on an empty payment table: the comparison is then
        -- false and the second limb never fires.
        select @pay_floor_cy = min(campaign_year) from Layercake.silv_payment_events;
        set @step = concat(N'payment history floor: CY', isnull(cast(@pay_floor_cy as nvarchar(10)), N' (none)'),
                           N' (Readmission long-standing-member bound)');
        exec Layercake.usp_etl_log_progress @log_id, @step, null, @substep_ts output;

        -- Readmission. Derived from event history (the CE lapse date is
        -- removed from the record on readmission): a payment in CY N with NO
        -- payment in CY N-1, plus evidence that the contact was a member
        -- before N. That evidence comes two ways, the two limbs of the OR
        -- below:
        --   * AN EARLIER PAYMENT (CY < N-1) - a returning payer. The original
        --     rule, unchanged.
        --   * A JOIN IN AN EARLIER CAMPAIGN YEAR, where CY N-1 is INSIDE the
        --     payment history (N-1 >= @pay_floor_cy). A member of long
        --     standing whose FIRST paid position in the warehouse is N: no
        --     earlier payment exists to satisfy the first limb, but the Join
        --     event says they were a member, and the subs history covers N-1
        --     and does not carry them, so the gap is real.
        --     THE FLOOR BOUND IS LOAD-BEARING, for the reason module 8 gives
        --     for the same bound: silv_payment_events only reaches back as far
        --     as the subs history that was loaded, so for a member who joined
        --     before it, absence from an earlier year is the edge of the data
        --     and not a fact about them. Unbounded, this limb would readmit
        --     EVERY long-standing member in the floor year itself - they have
        --     no payment in floor-1 because nobody does. Bounding it to
        --     N-1 >= floor means the missing year is one the warehouse can
        --     actually see, which is the whole of the evidence.
        --     Members who joined ON OR AFTER the floor never reach this limb:
        --     module 8 has already moved their enrolment forward to the first
        --     paid year, so their Join year IS N and join_cy < N is false.
        -- SUBTYPE: In-Year Readmission where the contact's Lapse falls in the
        -- same campaign year on or before this payment (#lapse_cy), else
        -- Standard. An actual recorded lapse, never the bulk lapse date - see
        -- the header. Same test as Renewal below, deliberately.
        -- DERIVED BEFORE RENEWAL, deliberately: Renewal now fires on any
        -- payment event, so these two would both claim this payment. This one
        -- is the more specific reading AND the only payment-derived event that
        -- opens a state range, so it wins and Renewal skips the year.
        -- It keeps the prior-year test that Renewal has dropped, and that plus
        -- the membership evidence above is the difference between them. The
        -- same gaps in payment history that made the test unusable as a Renewal
        -- filter make this an over-firing INCLUSION rule: a continuously paid
        -- member with one missing year reads as a readmission. It stands
        -- because it is what re-opens the state range - the open validation
        -- item below is exactly this question.
        -- [Open validation item with Alex/Maxine: cross-check a sample against
        --  readmission fee payments to confirm this derivation.]
        -- VALID PAYMENT: the Join events above require a silv_payment_events
        -- row for the contact. This event is DERIVED FROM silv_payment_events,
        -- so it carries a paid Subs.vwSubsMemberStatuses position by
        -- construction and needs no separate test.
        insert into #ev_stage
        (event_nk, event_type, event_subtype, event_date, source_enr_id, contact_no, grade_id, assessment_route_id,
         rpq_variant_id, hpb_id, country_id, gender_id, membership_status_id, campaign_year, campaign_quarter)
        select
            N'RA:' + p.contact_no + N':' + cast(p.campaign_year as nvarchar(6)),
            'Readmission',
            case when exists (select 1
                              from #lapse_cy l
                              where l.contact_no    = p.contact_no
                                and l.campaign_year = p.campaign_year
                                and l.lapse_date   <= d.event_date)
                 then 'In-Year Readmission' else 'Standard' end,
            d.event_date,
            null,
            p.contact_no,
            mg.id,
            0, 0, 0,
            isnull(b.country_id, 0),
            isnull(b.gender_id, 0),
            isnull(ms.id, 0),
            p.campaign_year,
            case when month(d.event_date) in (10,11,12) then 'Q1'
                 when month(d.event_date) in (1,2,3)    then 'Q2'
                 when month(d.event_date) in (4,5,6)    then 'Q3'
                 when month(d.event_date) in (7,8,9)    then 'Q4'
                 else 'NK' end
        from Layercake.silv_payment_events p
        cross apply (select cast(isnull(p.renewal_date_adj, p.payment_date) as date) as event_date) d
        left join Layercake.silv_member_base b
            on  b.contact_no = p.contact_no
        inner join Layercake.silv_ref_membership_grade mg
            on  mg.grade_name = case when b.election_date <= d.event_date then 'Qualified'
                                     when b.enrolment_date is not null then 'Candidate'
                                     else 'N/A' end
        left join Layercake.silv_ref_membership_status ms
            on  ms.status_name = case when b.election_date <= d.event_date
                                      then iif(b.retirement_date <= d.event_date, 'Retired', 'Practising')
                                      else 'N/A' end
        where d.event_date is not null
          and not exists (select 1 from Layercake.silv_payment_events pp
                          where pp.contact_no = p.contact_no
                            and pp.campaign_year = p.campaign_year - 1)
          -- member before N, evidenced either way (see the comment above)
          and (   exists (select 1 from Layercake.silv_payment_events h
                          where h.contact_no = p.contact_no
                            and h.campaign_year < p.campaign_year - 1)
               or (    p.campaign_year - 1 >= @pay_floor_cy
                   and exists (select 1 from #join_cy j
                               where j.contact_no = p.contact_no
                                 and j.join_cy    < p.campaign_year)))
          -- NO RICS RECORD: module 8 drops these contacts from
          -- silv_member_base, but Readmission is the ONE event that opens a
          -- state range with no member base row behind it (silv_member_base is
          -- LEFT joined above), so without this the payment alone would put
          -- them straight back into the active count. Same test as the module
          -- 8 driver, including the test-contact filter #rics_record applies.
          -- Renewal deliberately keeps its left join: Renewal events never
          -- open or close a state range, so they cannot affect the count.
          and exists (select 1
                      from Layercake.brnz_rics_record rec
                      where rec.apuk_ricsmembershipnumber = p.contact_no
                        and rec._is_deleted = 0
                        and not exists (select 1
                                        from Layercake.brnz_contact_test_record rtst
                                        where rtst.contactid = rec.apuk_contactid
                                          and rtst._is_deleted = 0))
          -- NO TRANSACTION HISTORY: the module 8 driver drops these contacts
          -- too, for the same reason and with the same consequence - so the
          -- same guard is repeated on the same event. A payment event derives
          -- from brnz_subs_status (invoice position), NOT from cash, so a
          -- contact with a paid subs position and no cash transaction at all
          -- would otherwise be readmitted into the active count by an invoice
          -- position alone.
          and exists (select 1
                      from Layercake.brnz_cust_trans ct
                      where ct.accountnum  = p.contact_no
                        and ct._is_deleted = 0);
        set @rc = @@rowcount;
        exec Layercake.usp_etl_log_progress @log_id, N'derive events: Readmission', @rc, @substep_ts output;

        -- The last thing Renewal needs out of #ev_stage: the years Readmission
        -- has just claimed. #join_cy and #lapse_cy, which Renewal also reads,
        -- were staged before the Readmission insert because that insert needs
        -- them too. Staged rather than read inline, so the Renewal insert never
        -- reads its own target table and the dependency is visible.
        -- unique by construction: silv_payment_events is keyed on
        -- (contact_no, campaign_year) and Readmission emits at most one row per
        -- payment event. The index asserts it.
        select contact_no, campaign_year
        into #readmit_cy
        from #ev_stage
        where event_type = 'Readmission';
        set @rc = @@rowcount;

        create unique clustered index cx_readmit_cy on #readmit_cy (contact_no, campaign_year);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #readmit_cy (Renewal exclusion)', @rc, @substep_ts output;

        -- Renewal (incl. In-Year Readmission). Signal: ANY payment event,
        -- with two exceptions -
        --   * the contact's JOIN campaign year (#join_cy): the first
        --     subscription is the subscription, not a renewal of it. Taken
        --     from the Join EVENT, so events stay the single source of the
        --     rule. A contact with no Join event at all has no year to
        --     exclude and every payment renews.
        --   * a year already claimed by a Readmission above: that IS the
        --     payment event, already emitted under the more specific type, and
        --     it is the one that re-opens the state range. Deriving both would
        --     count one payment twice.
        -- NO PRIOR-YEAR TEST. It used to require a payment in CY N-1, which
        -- silently dropped every payment whose history had a gap - and source
        -- payment history has gaps, so "no payment last year" is evidence of
        -- nothing. Dropping it is the point of this rule.
        -- Event date = renewal_date_adj (guaranteed inside the campaign year),
        -- else the cash transaction date. SUBTYPE: In-Year Readmission where
        -- the contact's Lapse falls in the same campaign year on or before
        -- this payment (#lapse_cy), else Standard - the same test Readmission
        -- above applies, and an ACTUAL lapse rather than the conceptual bulk
        -- lapse date (see the header). ref_campaign_year_config is no longer
        -- read here: with the date window gone there is nothing left to take
        -- from it, and a campaign year the spine does not cover is no longer a
        -- special case at all.
        -- Corporate renewals arrive via the same payment signal.
        -- silv_member_base left-joined so a paid contact with no member base
        -- still surfaces (grade N/A) rather than being dropped.
        -- VALID PAYMENT, PER CAMPAIGN YEAR: like Readmission, this event IS a
        -- silv_payment_events row, so the paid Subs.vwSubsMemberStatuses
        -- position (Full Concession / Fully Paid / Partially Paid / Pre-Subs
        -- Payment, the list module 7 owns) is there by construction - and it
        -- is the position for p.campaign_year specifically, because that is
        -- the row's key. A member whose last paid position is CY N-1 stays
        -- ACTIVE through CY N (only a Lapse closes the state range) but gets
        -- NO Renewal for CY N until a paid position for N exists. That is the
        -- rule, and it needs no exists() test here: there is no row to emit
        -- from. Do not add one against silv_member_base or the state ranges -
        -- this insert deliberately has no active-membership precondition
        -- (see the left join above).
        insert into #ev_stage
        (event_nk, event_type, event_subtype, event_date, source_enr_id, contact_no, grade_id, assessment_route_id,
         rpq_variant_id, hpb_id, country_id, gender_id, membership_status_id, campaign_year, campaign_quarter)
        select
            N'RN:' + p.contact_no + N':' + cast(p.campaign_year as nvarchar(6)),
            'Renewal',
            case when exists (select 1
                              from #lapse_cy l
                              where l.contact_no    = p.contact_no
                                and l.campaign_year = p.campaign_year
                                and l.lapse_date   <= d.event_date)
                 then 'In-Year Readmission' else 'Standard' end,
            d.event_date,
            null,
            p.contact_no,
            mg.id,
            0, 0, 0,
            isnull(b.country_id, 0),
            isnull(b.gender_id, 0),
            isnull(ms.id, 0),
            p.campaign_year,                -- from the subs status, not re-derived from the date
            case when month(d.event_date) in (10,11,12) then 'Q1'
                 when month(d.event_date) in (1,2,3)    then 'Q2'
                 when month(d.event_date) in (4,5,6)    then 'Q3'
                 when month(d.event_date) in (7,8,9)    then 'Q4'
                 else 'NK' end
        from Layercake.silv_payment_events p
        left join #join_cy jn
            on  jn.contact_no = p.contact_no
        cross apply (select cast(isnull(p.renewal_date_adj, p.payment_date) as date) as event_date) d
        left join Layercake.silv_member_base b
            on  b.contact_no = p.contact_no
        inner join Layercake.silv_ref_membership_grade mg
            on  mg.grade_name = case when b.election_date <= d.event_date then 'Qualified'
                                     when b.enrolment_date is not null then 'Candidate'
                                     else 'N/A' end
        left join Layercake.silv_ref_membership_status ms
            on  ms.status_name = case when b.election_date <= d.event_date
                                      then iif(b.retirement_date <= d.event_date, 'Retired', 'Practising')
                                      else 'N/A' end
        where d.event_date is not null
          -- not the join year
          and (jn.join_cy is null or p.campaign_year <> jn.join_cy)
          -- not a year the Readmission above already claimed
          and not exists (select 1
                          from #readmit_cy r
                          where r.contact_no    = p.contact_no
                            and r.campaign_year = p.campaign_year);
        set @rc = @@rowcount;
        exec Layercake.usp_etl_log_progress @log_id, N'derive events: Renewal', @rc, @substep_ts output;

        -- diff-sync on event_nk. ORDER IS LOAD-BEARING: delete, then update,
        -- then insert. The filtered unique index ux_silv_membership_events_enr
        -- (source_enr_id where not null) is enforced per STATEMENT, so any run
        -- that re-keys an event under a new event_nk while keeping the same
        -- source_enr_id must remove the old row before the new row inserts, or
        -- the insert fails with a duplicate key on that index.

        -- events no longer derivable (source row soft-deleted / status
        -- changed / event re-keyed under a new event_nk)
        delete tgt
        from Layercake.silv_membership_events tgt
        where not exists (select 1 from #ev_stage s where s.event_nk = tgt.event_nk);
        set @del = @@rowcount;
        exec Layercake.usp_etl_log_progress @log_id, N'sync: delete', @del, @substep_ts output;

        -- update changed payloads in place (event_id preserved)
        update tgt
        set event_type           = s.event_type,
            event_subtype        = s.event_subtype,
            event_date           = s.event_date,
            source_enr_id        = s.source_enr_id,
            contact_no           = s.contact_no,
            grade_id             = s.grade_id,
            assessment_route_id  = s.assessment_route_id,
            rpq_variant_id       = s.rpq_variant_id,
            hpb_id               = s.hpb_id,
            country_id           = s.country_id,
            gender_id            = s.gender_id,
            membership_status_id = s.membership_status_id,
            campaign_year        = s.campaign_year,
            campaign_quarter     = s.campaign_quarter
        from Layercake.silv_membership_events tgt
        join #ev_stage s on s.event_nk = tgt.event_nk
        where exists (select s.event_type, s.event_subtype, s.event_date, s.source_enr_id, s.contact_no,
                             s.grade_id, s.assessment_route_id, s.rpq_variant_id, s.hpb_id,
                             s.country_id, s.gender_id, s.membership_status_id,
                             s.campaign_year, s.campaign_quarter
                      except
                      select tgt.event_type, tgt.event_subtype, tgt.event_date, tgt.source_enr_id, tgt.contact_no,
                             tgt.grade_id, tgt.assessment_route_id, tgt.rpq_variant_id, tgt.hpb_id,
                             tgt.country_id, tgt.gender_id, tgt.membership_status_id,
                             tgt.campaign_year, tgt.campaign_quarter);
        set @upd = @@rowcount;
        exec Layercake.usp_etl_log_progress @log_id, N'sync: update', @upd, @substep_ts output;

        insert into Layercake.silv_membership_events
        (event_nk, event_type, event_subtype, event_date, source_enr_id, contact_no, grade_id, assessment_route_id,
         rpq_variant_id, hpb_id, country_id, gender_id, membership_status_id, campaign_year, campaign_quarter)
        select s.event_nk, s.event_type, s.event_subtype, s.event_date, s.source_enr_id, s.contact_no, s.grade_id,
               s.assessment_route_id, s.rpq_variant_id, s.hpb_id, s.country_id, s.gender_id,
               s.membership_status_id, s.campaign_year, s.campaign_quarter
        from #ev_stage s
        where not exists (select 1 from Layercake.silv_membership_events t
                          where t.event_nk = s.event_nk);
        set @ins = @@rowcount;
        exec Layercake.usp_etl_log_progress @log_id, N'sync: insert', @ins, @substep_ts output;

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

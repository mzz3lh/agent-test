/*====================================================================
    Layercake.usp_load_silv_data_anomaly
    Silver layer - loads one table
====================================================================*/

/*====================================================================
    10. Layercake.silv_data_anomaly
    ------------------------------------------------------------------
    Rows where the data does not match the agreed rules. Re-derived
    every run and synced on anomaly_nk ('<type>:<contact_no>'). Never
    hard-deleted: a row that stops being detected is stamped
    resolved_at, and re-opened if it recurs.

    Rules 1-4 read silv_member_base: the events are still emitted
    exactly as derived (module 9) - the anomaly log records WHERE the
    derivation had to tolerate bad data, it never changes the
    derivation.

    Rules 5 and 6 are the exception, and read brnz_contact directly.
    Those contacts are EXCLUDED from silv_member_base by module 8, so by
    the time this module runs they are not in the base to be found - the
    whole point of both rules is to name the cohort each exclusion
    removed so it can be fed back to the client.

    Rule 6 (NO_TRANSACTIONS) fires only where the removed contact HAD a
    valid enrolment or election - a contact with neither is not a member
    on any reading, so its removal is not worth reporting. That test is
    the module 8 driver's own, read from Layercake.vw_enrolment_base
    so the two cannot drift apart, plus the 07 curated fallback dates.

    Rule 7 (JOIN_NO_PAYMENT) records the third exclusion, which lives
    in module 9 rather than the driver: a contact IN silv_member_base
    that would take a Join branch (Candidate or RPQ) but has no row in
    silv_payment_events - no paid invoice position in
    Subs.vwSubsMemberStatuses in any campaign year - so module 9 emits
    no Join and no state range opens. The branch test is repeated here
    against the same base columns module 9 reads, so it cannot drift.
    IT IS A COPY, SO IT MOVES WHEN MODULE 9 MOVES: the RPQ branch there
    now also takes an elected-only 07 contact (election_from_exception),
    and this rule was widened in the same commit. Such a contact used to
    get a Change regardless of payment, so nothing was ever withheld to
    report; now the Join carries the valid-payment test like any other,
    and a 07 contact with no paid position lands here instead of opening
    a state range on curated dates alone.

    Rule 8 (ENROLMENT_AFTER_FIRST_PAID) records a correction module 8
    makes rather than an exclusion: the recorded enrolment date (real
    row or 07 fallback) sat in a later campaign year than the contact's
    first paid position, so the driver backdated it to the first paid
    year and kept the recorded date alongside. Read straight from the
    two silv_member_base columns that carry the correction, so it
    cannot drift from the driver. Rule 9 (ELECTION_AFTER_FIRST_PAID)
    is the same for a contact with NO enrolment date, whose election
    is the Join anchor and was backdated instead.

    Rules 10 and 11 (ENROLMENT_BEFORE_FIRST_PAID / ELECTION_BEFORE_
    FIRST_PAID) are the same correction in the other direction: the
    recorded date sat in a campaign year with no paid position, EARLIER
    than the first paid one, and module 8 moved it forward - only where
    the recorded year is inside the payment history. The same two base
    columns carry both directions; recorded > effective is rules 8/9,
    recorded < effective is rules 10/11. Rule 11 also covers an
    election carried forward with its enrolment.

    Depends on silv_member_base (module 8), silv_payment_events
    (module 7), brnz_contact, brnz_cust_trans, vw_enrolment_base and
    vw_student_superseded; it is independent of module 9.
====================================================================*/
create or alter procedure Layercake.usp_load_silv_data_anomaly
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
            @err        nvarchar(4000);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'silver', 'silv_data_anomaly', @log_id output;
        set @substep_ts = sysdatetime();

        /* ---- rule 6 inputs, staged before the transaction opens --------
           Rule 6 reports contacts the module 8 driver removed for having no
           transaction history, so it has to reconstruct the two driver tests
           that decide who WOULD have been in the base: a qualifying
           enrolment/election, and the rics-record pair (a record exists, and
           its grade is not Student - or the Student status is superseded,
           which is the driver's override). Anything failing those was
           removed for a different reason and is not this rule's business.
           --------------------------------------------------------------- */

        -- a. per-contact qualifying dates, from the SAME row set module 8
        --    reads. vw_enrolment_base holds the rules; this is module 8's
        --    aggregate over it, minus the lineage/RPQ resolution rule 6 has
        --    no use for.
        select
            v.[Contact No]        as contact_no,
            min(v.enrolment_date) as enrolment_date,
            min(v.election_date)  as election_date
        into #qual_enr
        from Layercake.vw_enrolment_base v
        where v.[Contact No] is not null
        group by v.[Contact No];
        set @rc = @@rowcount;

        create unique clustered index cx_qual_enr on #qual_enr (contact_no);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #qual_enr (contacts with a qualifying enrolment/election)', @rc, @substep_ts output;

        -- b. latest rics record per membership number, test contacts removed.
        --    Mirrors #rics_record in module 8 exactly - see the note there on
        --    why statecode is not applied.
        select apuk_ricsmembershipnumber, apuk_membergrade
        into #rics_latest
        from (
            select
                rec.apuk_ricsmembershipnumber,
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

        create unique clustered index cx_rics_latest on #rics_latest (apuk_ricsmembershipnumber);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #rics_latest (latest rics record per member)', @rc, @substep_ts output;

        -- c. contacts whose Student grade the driver overrides: the Student
        --    status is superseded in the enrolment history. The SAME view
        --    module 8 stages (Layercake.vw_student_superseded), so the two
        --    cannot drift.
        select [Contact No] as contact_no
        into #student_superseded
        from Layercake.vw_student_superseded;
        set @rc = @@rowcount;

        create unique clustered index cx_student_superseded on #student_superseded (contact_no);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #student_superseded (Student grade overridden)', @rc, @substep_ts output;

        begin tran;

        select
            cast(concat(v.anomaly_type, N':', v.contact_no) as nvarchar(240)) as anomaly_nk,
            v.anomaly_type,
            v.contact_no,
            v.source_enr_id,
            v.detail
        into #anom_stage
        from (
            -- 1. Non-RPQ election with no qualifying enrolment date anywhere:
            --    the rules say it should have an enrolment. SAME TEST AS
            --    BEFORE, different consequence to report. Module 9 used to
            --    emit a Change with no Join for these; it now reads the
            --    election as a DIRECT ENTRY and emits Join/RPQ with subtype
            --    'Direct Entry', because a Change needs a candidacy to move
            --    out of and there is no enrolment date to be one. The cohort
            --    is still worth feeding back to the client - an elected member
            --    with no enrolment record is a data gap whatever the pipeline
            --    does with it - and this row is now the record of an inference
            --    made in its absence, which is exactly the cohort whose
            --    subtype reads 'Direct Entry' rather than 'RPQ'.
            --    Exception-backfilled (07) election dates are skipped - that
            --    cohort is already curated.
            select
                cast('ELECTION_NO_ENROLMENT' as varchar(40)) as anomaly_type,
                b.contact_no,
                b.election_enr_id                            as source_enr_id,
                cast(concat(N'Non-RPQ election on ', convert(nvarchar(10), b.election_date, 23),
                            N' but no qualifying enrolment date found; derived as a direct-entry ',
                            N'Join (subtype Direct Entry) - the application type does not evidence ',
                            N'RPQ, so the absent enrolment may be a source gap')
                     as nvarchar(400))                       as detail
            from Layercake.silv_member_base b
            where b.election_date is not null
              and b.enrolment_date is null
              and b.is_rpq = 0
              and b.election_from_exception = 0

            union all

            -- 2. Ordering rule broken: the election date precedes the
            --    enrolment date (events are emitted as derived - the Join
            --    lands AFTER the Change - so the source dates need review).
            select
                'ELECTION_BEFORE_ENROLMENT',
                b.contact_no,
                b.election_enr_id,
                concat(N'Election date ', convert(nvarchar(10), b.election_date, 23),
                       N' precedes enrolment date ', convert(nvarchar(10), b.enrolment_date, 23),
                       N'; events emitted as derived - review source dates')
            from Layercake.silv_member_base b
            where b.enrolment_date is not null
              and b.election_date  is not null
              and b.election_date  <  b.enrolment_date

            union all

            -- 3. RPQ-flagged election but a qualifying enrolment also exists:
            --    an RPQ direct entry should not have enrolled. Treated as
            --    Join/Candidate + Change (the enrolment wins), logged for
            --    review.
            select
                'RPQ_WITH_ENROLMENT',
                b.contact_no,
                b.election_enr_id,
                concat(N'RPQ-flagged election on ', convert(nvarchar(10), b.election_date, 23),
                       N' but a qualifying enrolment exists (', convert(nvarchar(10), b.enrolment_date, 23),
                       N'); treated as Join/Candidate + Change, not Join/RPQ')
            from Layercake.silv_member_base b
            where b.is_rpq = 1
              and b.enrolment_date is not null
              and b.election_date  is not null

            union all

            -- 4. Contact lapse date precedes the derived enrolment/election:
            --    treated as stale (the member re-joined since lapsing), so no
            --    Lapse event was emitted. On a true readmission CE removes
            --    the lapse date, so a surviving stale date is a data mismatch.
            select
                'STALE_LAPSE_IGNORED',
                b.contact_no,
                null,
                concat(N'Contact lapse date ', convert(nvarchar(10), b.contact_lapsed_date, 23),
                       N' precedes the derived enrolment/election date - treated as stale; no Lapse event emitted')
            from Layercake.silv_member_base b
            where b.contact_lapsed_date is not null
              and b.lapsed_date is null

            union all

            -- 5. No rics record at all: brnz_rics_record carries nothing for
            --    this contact number, so there is no grade, lapse code or
            --    retirement date behind the contact and it is not a member by
            --    the source definition. Module 8 excludes it from the driver
            --    and module 9 excludes it from the payment-derived
            --    Readmission, so it produces no events, no state range and no
            --    active count - this row is the record of who was removed.
            --    Read from brnz_contact (NOT silv_member_base) for exactly
            --    that reason, under the same driver filters module 8 applies.
            --    Aggregated to the contact NUMBER: two active contact rows
            --    sharing one number would otherwise break the anomaly_nk.
            select
                'NO_RICS_RECORD',
                c.Rics_contactno,
                null,
                -- cast, as rule 1 does: brnz_contact.Rics_contactno is
                -- nvarchar(100), so a pathological contact number could
                -- otherwise overflow silv_data_anomaly.detail on insert
                cast(concat(N'No row in brnz_rics_record for membership number ', c.Rics_contactno,
                            N' (contact id ', min(cast(c.ContactId as nvarchar(36))),
                            N'; active contact rows ', count(*),
                            N') - no grade, lapse code or retirement date exists, so the contact is',
                            N' excluded from silv_member_base and from the active count')
                     as nvarchar(400))
            from Layercake.brnz_contact c
            where c._is_deleted = 0
              and c.Rics_contactno is not null
              and not exists (select 1
                              from Layercake.brnz_contact_test_record tst
                              where tst.contactid = c.ContactId
                                and tst._is_deleted = 0)
              -- mirrors #rics_record in module 8: a rics row whose own contact
              -- is test-flagged does not count as a membership record
              and not exists (select 1
                              from Layercake.brnz_rics_record rec
                              where rec.apuk_ricsmembershipnumber = c.Rics_contactno
                                and rec._is_deleted = 0
                                and not exists (select 1
                                                from Layercake.brnz_contact_test_record rtst
                                                where rtst.contactid = rec.apuk_contactid
                                                  and rtst._is_deleted = 0))
            group by c.Rics_contactno

            union all

            -- 6. No transaction history at all: brnz_cust_trans carries no row
            --    for this membership number, so the contact has never
            --    transacted and is not a valid contact. Module 8 excludes it
            --    from the driver and module 9 excludes it from the
            --    payment-derived Readmission, so it produces no events, no
            --    state range, no active count and - because the paid count is
            --    derived from that same range join - no paid count either.
            --    REPORTED ONLY WHERE IT CONTRADICTS SOMETHING: the contact has
            --    a valid enrolment or election (or curated 07 fallback dates)
            --    and would otherwise have been in the base. A contact with no
            --    transactions AND no qualifying enrolment is not a member on
            --    any reading, so reporting its removal would bury the real
            --    cases in the client-facing list.
            --    The other driver exclusions are applied here too, so this
            --    type means "removed by the TRANSACTION test", not just
            --    "removed": no-rics-record contacts belong to rule 5, and
            --    Student-grade contacts (unless superseded) were never in
            --    the base regardless.
            --    Aggregated to the contact NUMBER, as rule 5 is.
            select
                'NO_TRANSACTIONS',
                c.Rics_contactno,
                null,
                cast(concat(N'No rows in brnz_cust_trans for membership number ', c.Rics_contactno,
                            N' (contact id ', min(cast(c.ContactId as nvarchar(36))),
                            N') but a valid ',
                            case when d.enrolment_date is not null and d.election_date is not null
                                      then concat(N'enrolment ', convert(nvarchar(10), d.enrolment_date, 23),
                                                  N' and election ', convert(nvarchar(10), d.election_date, 23))
                                 when d.enrolment_date is not null
                                      then concat(N'enrolment ', convert(nvarchar(10), d.enrolment_date, 23))
                                 else concat(N'election ', convert(nvarchar(10), d.election_date, 23)) end,
                            iif(q.contact_no is null, N' (curated 07 fallback dates)', N''),
                            N' exists - never transacted, so excluded from silv_member_base and counted as neither active nor paid')
                     as nvarchar(400))
            from Layercake.brnz_contact c
            -- the driver's own qualifying-date test: real rows first, 07
            -- curated fallback second, exactly as silv_member_base coalesces
            left join #qual_enr q
                on q.contact_no = c.Rics_contactno
            left join Layercake.ref_enrolment_exception x
                on x.contact_no = c.Rics_contactno
            cross apply (select
                coalesce(q.enrolment_date, x.derived_enrolment_date) as enrolment_date,
                coalesce(q.election_date,  x.derived_election_date)  as election_date
            ) d
            where c._is_deleted = 0
              and c.Rics_contactno is not null
              and not exists (select 1
                              from Layercake.brnz_contact_test_record tst
                              where tst.contactid = c.ContactId
                                and tst._is_deleted = 0)
              -- the transaction test itself, identical to the module 8 driver
              and not exists (select 1
                              from Layercake.brnz_cust_trans ct
                              where ct.accountnum  = c.Rics_contactno
                                and ct._is_deleted = 0)
              -- would have passed the OTHER driver exclusions: a rics record
              -- exists and its grade is not Student (or the Student status is
              -- superseded - the driver's override, staged as
              -- #student_superseded)
              and exists (select 1
                          from #rics_latest r
                          where r.apuk_ricsmembershipnumber = c.Rics_contactno
                            and (   isnull(r.apuk_membergrade, 0) <> 200000003
                                 or exists (select 1
                                            from #student_superseded ss
                                            where ss.contact_no = c.Rics_contactno)))
              -- ...and had something valid behind it
              and (d.enrolment_date is not null or d.election_date is not null)
            group by c.Rics_contactno, d.enrolment_date, d.election_date, q.contact_no

            union all

            -- 7. Join with no valid payment: the contact is in the base and
            --    would take a Join branch - Join/Candidate (an enrolment
            --    date) or Join/RPQ (an election with no enrolment date),
            --    the same split module 9 makes, which between them is
            --    every contact holding either date - but silv_payment_events
            --    holds nothing for it, so no paid invoice position exists in
            --    Subs.vwSubsMemberStatuses for ANY campaign year. Module 9
            --    withholds the Join, so no state range opens on the
            --    enrolment / election date and the contact is not counted
            --    as active from it. Lapse and (for a Candidate) Change are
            --    still emitted as derived - this row records only that the
            --    Join was withheld. Read from silv_member_base: unlike rules
            --    5 and 6 the contact is still in the base.
            select
                'JOIN_NO_PAYMENT',
                b.contact_no,
                b.source_enr_id,
                cast(concat(N'Would take ',
                            iif(b.enrolment_date is not null, N'Join/Candidate on ', N'Join/RPQ on '),
                            convert(nvarchar(10), isnull(b.enrolment_date, b.election_date), 23),
                            iif(   (b.enrolment_date is not null and b.enrolment_from_exception = 1)
                                or (b.enrolment_date is null     and b.election_from_exception  = 1),
                                N' (curated 07 fallback date)', N''),
                            N' but no paid invoice position exists in Subs.vwSubsMemberStatuses for any campaign year',
                            N' - Join withheld, no state range opened on it')
                     as nvarchar(400))
            from Layercake.silv_member_base b
            where (b.enrolment_date is not null or b.election_date is not null)
              and not exists (select 1
                              from Layercake.silv_payment_events p
                              where p.contact_no = b.contact_no)

            union all

            -- 8. Enrolment recorded AFTER the first paid campaign year: the
            --    recorded enrolment date (real row or 07 fallback) sits in a
            --    later campaign year than the contact's first paid position in
            --    silv_payment_events - the source says "joined" years after the
            --    subs history says they were paying. Module 8 backdated the
            --    enrolment date to the first paid year (the recorded date is
            --    kept on the base row), so module 9 emits the Join there, every
            --    later paid year derives as a Renewal, and the recorded year
            --    gets no Join of its own - it counts as paid only if a paid
            --    position exists for it. Tolerated and corrected, not
            --    excluded: this row makes the correction visible and feeds the
            --    cohort back to the client, as the 07 exceptions are.
            select
                'ENROLMENT_AFTER_FIRST_PAID',
                b.contact_no,
                b.source_enr_id,
                cast(concat(N'Recorded enrolment date ', convert(nvarchar(10), b.recorded_enrolment_date, 23),
                            iif(b.enrolment_from_exception = 1, N' (curated 07 fallback date)', N''),
                            N' is in CY ', year(b.recorded_enrolment_date) + iif(month(b.recorded_enrolment_date) >= 10, 1, 0),
                            N' but the first paid position is in CY ', year(b.enrolment_date) + iif(month(b.enrolment_date) >= 10, 1, 0),
                            N' - enrolment backdated to ', convert(nvarchar(10), b.enrolment_date, 23),
                            N': Join emitted there, later paid years derive as Renewals')
                     as nvarchar(400))
            from Layercake.silv_member_base b
            where b.enrolment_from_subs_history = 1
              -- the flag marks a move in EITHER direction; backdated = the
              -- recorded date is the later one. Rule 10 takes the other half.
              and b.recorded_enrolment_date > b.enrolment_date

            union all

            -- 9. Election recorded AFTER the first paid campaign year, with no
            --    enrolment date at all: the election is the Join anchor (a
            --    Join/RPQ, or the Change that opens the state range), and the
            --    recorded date sits in a later campaign year than the contact's
            --    first paid position. Module 8 backdated the election date the
            --    same way it backdates an enrolment date (the recorded date is
            --    kept on the base row), so the Join / Change lands where the
            --    paying started and every later paid year derives as a
            --    Renewal. Never fires where an enrolment date exists - the
            --    election is not moved in that case.
            select
                'ELECTION_AFTER_FIRST_PAID',
                b.contact_no,
                b.election_enr_id,
                cast(concat(N'Recorded election date ', convert(nvarchar(10), b.recorded_election_date, 23),
                            iif(b.election_from_exception = 1, N' (curated 07 fallback date)', N''),
                            N' (no enrolment date) is in CY ', year(b.recorded_election_date) + iif(month(b.recorded_election_date) >= 10, 1, 0),
                            N' but the first paid position is in CY ', year(b.election_date) + iif(month(b.election_date) >= 10, 1, 0),
                            N' - election backdated to ', convert(nvarchar(10), b.election_date, 23),
                            N': ', iif(b.is_rpq = 1, N'Join/RPQ', N'Change'),
                            N' emitted there, later paid years derive as Renewals')
                     as nvarchar(400))
            from Layercake.silv_member_base b
            where b.election_from_subs_history = 1
              -- backdated half only, as rule 8; rule 11 takes the other
              and b.recorded_election_date > b.election_date

            union all

            -- 10. Enrolment recorded BEFORE the first paid campaign year: the
            --    mirror of rule 8. The recorded enrolment date (real row or 07
            --    fallback) sits in a campaign year the contact holds NO paid
            --    position for, and the first paid position is a later year.
            --    Derived as recorded, the Join landed in the unpaid year and
            --    the first paid year fell through as a Renewal. Module 8 moved
            --    the enrolment date FORWARD to the first paid year, so the
            --    Join lands there and only the years after it renew. Fires
            --    only where the recorded year is inside the payment history
            --    (module 8's @pay_floor_cy bound) - a member who enrolled
            --    before the subs history begins is not moved and not reported.
            select
                'ENROLMENT_BEFORE_FIRST_PAID',
                b.contact_no,
                b.source_enr_id,
                cast(concat(N'Recorded enrolment date ', convert(nvarchar(10), b.recorded_enrolment_date, 23),
                            iif(b.enrolment_from_exception = 1, N' (curated 07 fallback date)', N''),
                            N' is in CY ', year(b.recorded_enrolment_date) + iif(month(b.recorded_enrolment_date) >= 10, 1, 0),
                            N', which has no paid position; the first paid position is in CY ',
                            year(b.enrolment_date) + iif(month(b.enrolment_date) >= 10, 1, 0),
                            N' - enrolment moved forward to ', convert(nvarchar(10), b.enrolment_date, 23),
                            N': Join emitted there, later paid years derive as Renewals')
                     as nvarchar(400))
            from Layercake.silv_member_base b
            where b.enrolment_from_subs_history = 1
              and b.recorded_enrolment_date < b.enrolment_date

            union all

            -- 11. Election recorded BEFORE the first paid campaign year. Two
            --    cases, told apart by whether an enrolment date exists:
            --    * none - the election is the Join anchor (Join/RPQ, or the
            --      Change that opens the state range) and was moved forward
            --      exactly as rule 10's enrolment date is, under the same
            --      payment-history bound; the mirror of rule 9.
            --    * one exists and was itself moved forward (rule 10) past the
            --      recorded election - the election was CARRIED to the same
            --      join date, so the Change does not precede the Join and
            --      open the state range in the unpaid year.
            select
                'ELECTION_BEFORE_FIRST_PAID',
                b.contact_no,
                b.election_enr_id,
                cast(concat(N'Recorded election date ', convert(nvarchar(10), b.recorded_election_date, 23),
                            iif(b.election_from_exception = 1, N' (curated 07 fallback date)', N''),
                            iif(b.enrolment_date is null,
                                concat(N' (no enrolment date) is in CY ',
                                       year(b.recorded_election_date) + iif(month(b.recorded_election_date) >= 10, 1, 0),
                                       N', which has no paid position; the first paid position is in CY ',
                                       year(b.election_date) + iif(month(b.election_date) >= 10, 1, 0),
                                       N' - election moved forward to ', convert(nvarchar(10), b.election_date, 23),
                                       N': ', iif(b.is_rpq = 1, N'Join/RPQ', N'Change'),
                                       N' emitted there, later paid years derive as Renewals'),
                                concat(N' precedes the enrolment date as moved forward to the first paid campaign year (',
                                       convert(nvarchar(10), b.enrolment_date, 23),
                                       N', ENROLMENT_BEFORE_FIRST_PAID) - election carried to the same date so the Change',
                                       N' does not precede the Join')))
                     as nvarchar(400))
            from Layercake.silv_member_base b
            where b.election_from_subs_history = 1
              and b.recorded_election_date < b.election_date
        ) v;
        set @rc = @@rowcount;

        create unique clustered index cx_anom_stage on #anom_stage (anomaly_nk);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #anom_stage (rule checks)', @rc, @substep_ts output;

        -- re-detected: refresh the payload, bump last_seen_at, re-open if it
        -- had been marked resolved
        update tgt
        set detail        = s.detail,
            source_enr_id = s.source_enr_id,
            last_seen_at  = sysdatetime(),
            resolved_at   = null
        from Layercake.silv_data_anomaly tgt
        join #anom_stage s
          on  s.anomaly_nk = tgt.anomaly_nk;
        set @upd = @@rowcount;
        exec Layercake.usp_etl_log_progress @log_id, N'anomalies: refresh re-detected', @upd, @substep_ts output;

        -- newly detected
        insert into Layercake.silv_data_anomaly
        (anomaly_nk, anomaly_type, contact_no, source_enr_id, detail)
        select s.anomaly_nk, s.anomaly_type, s.contact_no, s.source_enr_id, s.detail
        from #anom_stage s
        where not exists (select 1 from Layercake.silv_data_anomaly t
                          where t.anomaly_nk = s.anomaly_nk);
        set @ins = @@rowcount;
        exec Layercake.usp_etl_log_progress @log_id, N'anomalies: new', @ins, @substep_ts output;

        -- no longer detected (source data fixed, or the rule no longer
        -- fires): stamp resolved_at, keep the row for audit
        update tgt
        set resolved_at = sysdatetime()
        from Layercake.silv_data_anomaly tgt
        where tgt.resolved_at is null
          and not exists (select 1 from #anom_stage s
                          where s.anomaly_nk = tgt.anomaly_nk);
        set @del = @@rowcount;
        exec Layercake.usp_etl_log_progress @log_id, N'anomalies: resolved', @del, @substep_ts output;

        commit;
        -- rows_deleted carries the RESOLVED count: nothing is ever hard-deleted here
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

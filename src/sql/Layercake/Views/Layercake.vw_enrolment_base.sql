/*====================================================================
    Layercake.vw_enrolment_base
    Silver layer - view
====================================================================*/

/*====================================================================
    THE QUALIFYING ENROLMENT / ELECTION ROW SET  (was #enr_base,
    inline inside usp_load_silv_member_base)
    ------------------------------------------------------------------
    One row per brnz_enrolment row that qualifies under EITHER the
    valid-enrolment rules (part 1) or the election rules (part 2). This
    is the single definition of "a valid enrolment or election" in the
    whole pipeline.

    IT LIVES HERE BECAUSE TWO MODULES NEED IT:
      * module 8  (usp_load_silv_member_base) stages it into #enr_base
        and derives the per-contact enrolment/election dates from it;
      * module 10 (usp_load_silv_data_anomaly) needs the same test to
        decide whether a contact the driver EXCLUDED nevertheless had a
        valid enrolment or election - which is what makes the exclusion
        worth reporting.
    These rules change (routes added 04/03/2024, the 14-day cool-off,
    the expanded application-type list), so a second copy would drift
    and the anomaly report would silently stop matching the driver.

    NOTE ON THE OBJECT FORM: this is a plain view - it is expanded into
    the calling query and optimised as part of it, exactly as the
    original sub-select was, so it costs nothing over inlining the two
    statements at each call site. It takes no parameters, so a view is
    all the callers ever needed; it is deliberately NOT a function,
    because the deployment account on the client database has no rights
    to create one. Callers that read it more than once should still
    SELECT INTO a #temp and index it, as module 8 does.

    PART 1 - ENROLMENT-SUPPLYING rows, under the FULL valid-view rules.
    Notes vs the RICS valid-enrolment view - the client's own definition
    upstream, not this object:
      * Application types are matched by NAME (bronze lands the display
        name, not the Application Type ID that view filters on). NULL
        application types are excluded - that view's NOT IN does the
        same (its "IS NULL temp inclusion" is commented out there).
      * Direct Entry is deliberately NOT in the exclusion list
        (removed from that view 06/03/2024, US 55324-related).
      * Enrolment dates before 1980-01-01 are CLAMPED to 1980-01-01,
        exactly as that view does.
      * 14-day cool-off (U/S 55339): a row whose End Date falls within
        14 days of the (clamped) enrolment date is a cooling-off
        cancellation, i.e. a non-payer - excluded.
      * No state-code filter, mirroring that view (taken out 17/11/2023).
    election_date is deliberately null on these rows: an election can
    only be supplied by a Part-2 row. These rows are never RPQ.

    PART 2 - ELECTION-SUPPLYING rows. The valid-enrolment rules do NOT
    apply to elections. Filters per 'Correct logic for join events':
      * election date present;
      * EXPANDED application-type exclusion list (21 types), NOT IN
        semantics so a NULL application type is excluded;
      * the 'Registered Valuer Top Up' route never supplies an election.
    is_rpq flags a Recognised Professional Qualification application, or
    an Assoc application on the Associate RPQ route.
    The row's own enrolment date (when present, clamped) is carried and
    feeds the per-contact earliest-enrolment aggregate - EXCEPT on an RPQ
    row, which carries none. An RPQ application IS a direct entry: the
    member never enrolled as a candidate, so a date in that row's
    Enrolment Date column is an artefact of how the application record
    was created, not a candidacy. It used to be carried unconditionally,
    and that defeated the Join/RPQ rule in module 9 - that rule asks for
    an election with no QUALIFYING enrolment date anywhere, but tests
    silv_member_base.enrolment_date, which this aggregate feeds. A direct
    entry whose election row happened to carry an enrolment date was
    therefore derived as Join/Candidate + Change rather than Join/RPQ,
    and module 10 logged it as RPQ_WITH_ENROLMENT on the strength of a
    "qualifying enrolment" that had never passed the Part-1 rules.
    A REAL candidacy is unaffected: it has a Part-1 row of its own, and
    the aggregate still finds it. So does a date riding on a NON-RPQ
    election row - only the direct-entry case is excluded.

    A contact can appear on both sides, and the same ENR ID can appear
    once per side - that is by design, and module 8's per-contact
    aggregate is what collapses it.
====================================================================*/
create or alter view Layercake.vw_enrolment_base
as
    -- Part 1 of 2: ENROLMENT-SUPPLYING rows
    -- (this branch names every column - a view takes its column names
    --  from the first arm of the union, so part 2 does not repeat them)
    select
        e.[ENR ID],
        e.[Contact No],
        d.enrolment_date,                       -- clamped, cast to date
        cast(null as date) as election_date,
        e.[Status Code],
        e.[Route ID],
        rt.apuk_name       as route_name,
        e.[Application Type],
        e.[Created DateTime],
        cast(0 as bit)     as is_rpq
    from Layercake.brnz_enrolment e
    left join Layercake.brnz_route rt
        on  rt.apuk_routeid = e.[Route ID]
        and rt._is_deleted  = 0
    cross apply (select cast(iif(e.[Enrolment Date] < '19800101', '19800101', e.[Enrolment Date]) as date) as enrolment_date) d
    where e._is_deleted = 0
      and e.[Enrolment Date] is not null
      -- route allowlist (Route replaces Enrolment Type as per meeting 17/11/2023)
      and e.[Route ID] in (
          '0504153D-6716-4C23-874E-32E2E2C4E3BF',   -- APC Other
          'B0CDFF73-5825-4E73-9852-EBC6B88448E1',   -- APC Prelim
          'E2231B53-7181-4AD8-BE15-3DAED8F0727F',   -- APC Research
          '6942A086-7EF8-48E7-993F-B0148F419117',   -- APC Structured Training 12
          '916E1056-C88B-4055-88A3-9FD0B57A98E7',   -- APC Structured Training 24
          '058D1F92-BD26-48AC-8603-8CC98B7DDA8E',   -- Associate Assessment
          'D4AC2D23-E733-4B2D-9693-2D1D2A0ACF46',   -- Senior Professional Assessment - 2017
          '7B867DC6-8F1F-4503-8A07-BFABDDD03CB2',   -- Specialist Assessment
          '2037C0AD-008D-48EE-B05A-9C90B4D61504')   -- Academic (added 04/03/2024, US 55324)
      -- application-type exclusions (by name; nulls excluded - see note above)
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
      -- ended without an election -> not a valid enrolment
      and not (e.[Election Date] is null and e.[End Date] is not null)
      -- 14-day cool-off cancellation -> non-payer, excluded (U/S 55339)
      and (e.[End Date] is null or e.[End Date] > dateadd(day, 14, d.enrolment_date))

    union all

    -- Part 2 of 2: ELECTION-SUPPLYING rows
    select
        e.[ENR ID],
        e.[Contact No],
        -- no enrolment date off an RPQ row - a direct entry never enrolled
        -- (see the header). Clamped as in part 1 on every other row.
        cast(case when r.is_rpq = 1 then null
                  else iif(e.[Enrolment Date] < '19800101', '19800101', e.[Enrolment Date])
             end as date),
        cast(e.[Election Date] as date),
        e.[Status Code],
        e.[Route ID],
        rt.apuk_name,
        e.[Application Type],
        e.[Created DateTime],
        r.is_rpq
    from Layercake.brnz_enrolment e
    left join Layercake.brnz_route rt
        on  rt.apuk_routeid = e.[Route ID]
        and rt._is_deleted  = 0
    -- computed once: the flag is both a returned column and the test that
    -- decides whether this row supplies an enrolment date
    cross apply (select cast(case when e.[Application Type] = 'Recognised Professional Qualification'
                                    or (e.[Application Type] = 'Assoc' and rt.apuk_name = 'Associate RPQ')
                                  then 1 else 0 end as bit) as is_rpq) r
    where e._is_deleted = 0
      and e.[Election Date] is not null
      -- expanded exclusion list (nulls excluded by NOT IN semantics)
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
      and isnull(rt.apuk_name, '') <> 'Registered Valuer Top Up';

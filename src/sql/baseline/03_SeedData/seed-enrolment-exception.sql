/*************************************************************************************
    Layercake.ref_enrolment_exception - RETIRED (20260928_02)
    ---------------------------------------------------------------------------------
    THIS FILE NO LONGER CAPTURES ANYTHING. It is kept in phase 03 as a
    deliberate no-op so that the reason the capture left is where anyone
    adding a phase 03 capture back would look for it.

    THE CAPTURE NOW LIVES IN THE PIPELINE:
        Layercake.usp_load_ref_enrolment_exception   (silver module 8a)
        04_Programmability/StoredProcedures/Silver/

    Read that module's header for the driver, the derivation rules, the
    lifecycle and the review queries. Everything this file used to document is
    there, against the objects that own each rule rather than against
    hand-copied duplicates of them.

    ---------------------------------------------------------------------------------
    WHY IT MOVED

    This file populated the table only when it was EMPTY, and nothing in
    usp_run_daily_load ever touched it again. That made the table a frozen
    point-in-time snapshot on a live database, and a re-derivation against
    today's source on a -Fresh / -Reset Data rebuild. The two disagreed, and
    the disagreement showed up as a small, slowly growing variance on the most
    recent day's active and paid member counts:

      * A rebuild captured every contact who had started paying, or whose CE
        data had been corrected, since the original snapshot. A daily load
        did not.
      * An uncaptured contact of this kind does not merely lack a date. With
        no qualifying Layercake.vw_enrolment_base row AND no exception row,
        usp_load_silv_member_base gives it a null enrolment date and a null
        election date; both Join branches in usp_load_silv_membership_events
        require one of those; no Join means no state range; and the active
        count and BOTH paid counts are gated by the state-range join. So the
        contact is in none of them.

    There was a second, quieter reason. Phase 03 runs before bronze exists, so
    this file had to read the SOURCE views (Subs.vwSubsMemberStatuses,
    CE.vwContact, synapse_ce.vwEnrolments) and carry its own hand-copied copy
    of the qualifying rules - every route id and application type from
    vw_enrolment_base, repeated here and again in the maintenance top-up
    script. Three copies of one rule set, kept in step by hand. The silver
    module runs after bronze, so it reads vw_enrolment_base itself and carries
    no copy of anything: a fresh database and a live one now derive the same
    cohort by construction, which is the whole point of the move.

    ---------------------------------------------------------------------------------
    WHAT THIS MEANS OPERATIONALLY

      * A BLANK DATABASE gets no exception rows at deploy time. It gets them
        on the first `exec Layercake.usp_run_daily_load` instead, derived from
        bronze under the current rules. Since that first run is also the full
        historical backfill, the counts it produces already include them.
      * -Reset Data / truncate-all.sql still clear the table, and the next
        daily load re-captures it. `Deploy-Database.ps1 -Phase 03` no longer
        does - it is still required for the id-0 'N/A' seed rows.
      * EXISTING ROWS ON A LIVE DATABASE ARE UNTOUCHED by the move. The module
        is insert-only for captures, so no contact already captured loses or
        changes the dates their history was built on.
      * The one behaviour that is genuinely gone: this file's ability to
        RE-DERIVE the whole table under current rules by truncating it and
        running phase 03. To do that now, truncate the table and run a silver
        load - the module will capture the whole cohort from scratch. Treat it
        the way -Fresh is treated: test databases, and expect a retrospective
        rebuild to follow.

    The table definition, and the lifecycle the module implements, are in
    02_Tables/Silver/Layercake.ref_enrolment_exception.sql.
*************************************************************************************/

set nocount on;
go

print 'seed-enrolment-exception.sql: RETIRED, no action taken.';
print '  ref_enrolment_exception is maintained by Layercake.usp_load_ref_enrolment_exception';
print '  on every silver load. See this file''s header for why the phase 03 capture went.';
go

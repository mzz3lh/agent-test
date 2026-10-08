/*====================================================================
    Layercake.usp_etl_log_pending_rebuild
    Control - ETL logging / progress
====================================================================*/

/*************************************************************************************
    12 - SILVER MODULES: one stored procedure per silver table
    ---------------------------------------------------------------------------------
    Splits the monolithic Layercake.usp_load_silver (02_usp_load_silver_v9.sql)
    into fourteen independent modules plus one shared helper. The orchestrator
    that calls them in order lives in 14_orchestrators.sql and keeps the name
    Layercake.usp_load_silver with an unchanged signature.

    All derivation logic is carried over verbatim from v9. Two structural
    changes were REQUIRED to make the modules independent - both are described
    in full below, because they are the only places where behaviour could
    differ from the monolith.

    ---------------------------------------------------------------------------------
    CHANGE 1: #mbase is now a persisted table, Layercake.silv_member_base
    ---------------------------------------------------------------------------------
    In the monolith, #mbase (the per-contact base: effective enrolment/election
    dates, lapse state, country/gender/rpq keys) was built once inside the
    membership-events step and then reused by the member-profile and annual-rate
    steps. A #temp table cannot cross a procedure boundary, so it is now built by
    its own module - usp_load_silv_member_base - into a real table, and the four
    consumers read that table instead:

        usp_load_silv_membership_events    (all six event derivations)
        usp_load_silv_data_anomaly         (all four rule checks)
        usp_load_silv_member_profile       (the profile stage)
        usp_load_silv_annual_rate_base     (boundary headcounts)

    The derivation itself is byte-for-byte the v9 #mbase query; only the target
    changed. #enr_base and #rics_record, which feed it and are used nowhere else,
    stay as #temp tables inside that module.

    COST: one extra table write per run (one row per eligible contact). The
    build is unchanged - it ran once per run before and still does.

    NOT UNIQUE ON contact_no BY DESIGN: #mbase carried a NON-unique clustered
    index, and duplicate Rics_contactno values were caught downstream by the
    #ev_stage primary key and the #prof_stage unique index, which fail the load
    loudly with a clear message. silv_member_base keeps a non-unique clustered
    index for exactly that reason, so a duplicate contact still fails in the
    same place with the same diagnostics. Making it unique would surface the
    problem one module earlier - a reasonable change, but a behaviour change, so
    it is deliberately not made here.

    ---------------------------------------------------------------------------------
    CHANGE 2: the retro-change log is written by each producer, not by step 6
    ---------------------------------------------------------------------------------
    In the monolith, steps 3 / 5 / 5b each computed a local variable
    (@pay_recalc_from, @rng_recalc_from, @prof_recalc_from) holding the earliest
    already-loaded date their changes reached back into, and step 6a wrote all
    three to Layercake.etl_daily_count_pending_rebuild in one go. Local variables
    cannot cross a procedure boundary either, so that write is now performed by
    each producing module through a shared helper:

        Layercake.usp_etl_log_pending_rebuild @run_id, @source, @affected_from

    The helper contains step 6a's logic unchanged for a single source: clamp
    affected_from to the spine start (2020-10-01), write nothing unless the date
    actually reaches into a marked-loaded date, then keep at most one OPEN row
    per source holding the EARLIEST date seen.

    Two consequences, both benign:
      * The pending row is now written inside the producing module's own
        transaction, so the detected change and its log entry commit or roll
        back together. In the monolith the change committed first and the log
        entry followed in a separate transaction.
      * Its progress message attaches to the producing step's log_id rather than
        to the daily-count step's. The rows written are identical.

    usp_load_silv_daily_count therefore implements 6b-6e only (rebuild request,
    work list, chunked walk, pending-rebuild close-off).

    ---------------------------------------------------------------------------------
    ONE MODULE COVERS TWO TABLES: usp_load_silv_daily_count
    ---------------------------------------------------------------------------------
    silv_daily_count_detail and silv_daily_count are loaded by a single module,
    deliberately. Per chunk, the detail rows are deleted and re-inserted, the
    main rows are re-derived as a plain SUM over that same detail, and the
    chunk's dates are marked in etl_daily_count_loaded - all inside ONE
    transaction. That is what makes the marker trustworthy in both directions
    and lets a failed run resume: at any commit boundary the two tables
    reconcile for every loaded date. Splitting them into two modules would need
    either two independent marker tables or a second full pass over the spine,
    and would break the guarantee in between. The main table is a pure aggregate
    of the detail, so there is no separate derivation to isolate.

    ---------------------------------------------------------------------------------
    STATIC REFERENCE TABLES HAVE NO MODULE
    ---------------------------------------------------------------------------------
    silv_ref_membership_grade, silv_ref_gender and silv_ref_membership_status are
    seeded once by baseline_ddl.sql (and 00_schema_and_control) and are never
    loaded from source - the monolith did not touch them either, so there is
    nothing to modularise.

    ---------------------------------------------------------------------------------
    LOGGING
    ---------------------------------------------------------------------------------
    Every module opens its own etl_run_log step. Step names match the target
    table, so monitoring queries keep working - with one change: the monolith
    logged all four loaded reference tables under the single step name
    'silv_ref_tables'; each now logs under its own table name.

    Modules, in dependency order:
        0.  usp_etl_log_pending_rebuild        (helper, not a table load)
        1.  usp_load_silv_ref_assessment_route
        2.  usp_load_silv_ref_rpq_variant
        3.  usp_load_silv_ref_country
        4.  usp_load_silv_ref_lapse_reason
        5.  usp_load_ref_date_spine
        6.  usp_load_ref_campaign_year_config
        7.  usp_load_silv_payment_events
        8a. usp_load_ref_enrolment_exception   (added 20260928_02)
        8.  usp_load_silv_member_base
        9.  usp_load_silv_membership_events
        10. usp_load_silv_data_anomaly
        11. usp_load_silv_member_state_ranges
        12. usp_load_silv_member_profile
        13. usp_load_silv_daily_count          (+ silv_daily_count_detail)
        14. usp_load_silv_annual_rate_base

    DEPLOY NOTE: requires baseline_ddl.sql (for Layercake.silv_member_base) and
    06_etl_progress_tracking.sql. Remove 02_usp_load_silver_v9.sql (and any
    earlier version) from the deploy folder so run-scripts.ps1 does not also
    create the monolithic version. 14 recreates Layercake.usp_load_silver as the
    orchestrator.
*************************************************************************************/

/*====================================================================
    0. HELPER: retro-change log (step 6a of the monolith, per source)
    ------------------------------------------------------------------
    A change detected by a producing module matters to the daily count
    only if it reaches back into dates that are ALREADY MARKED LOADED -
    those are the dates the daily run will no longer rebuild. Record the
    fact and carry on; @RebuildFrom / @FullRebuild applies it.

    affected_from is CLAMPED to the spine start: the derived dates come
    from event dates (enrolment dates clamp to 1980) and campaign-year
    first days, both of which routinely predate the spine. Without the
    clamp a pending row could hold e.g. 1980-01-01 and would never be
    satisfied by any rebuild - not even @FullRebuild, which starts at
    2020-10-01 - so it could never be stamped applied.

    Call INSIDE the producing module's transaction, so the detected
    change and this log entry commit together.
====================================================================*/
create or alter procedure Layercake.usp_etl_log_pending_rebuild
    @run_id        uniqueidentifier,
    @source        varchar(20),         -- state_ranges | payments | member_profile | enrol_exception
    @affected_from date,
    @logged        int = null output    -- 1 if a row was written/updated, else 0
as
begin
    set nocount on;

    set @logged = 0;

    if @affected_from is null return;

    if @affected_from < '20201001' set @affected_from = '20201001';

    -- nothing to record unless the change reaches an already-loaded date
    if not exists (select 1 from Layercake.etl_daily_count_loaded l
                   where l.[date] >= @affected_from)
        return;

    declare @detail nvarchar(400);

    -- an already-open row keeps the EARLIEST affected date seen
    update p
    set affected_from    = iif(@affected_from < p.affected_from, @affected_from, p.affected_from),
        detection_count  = p.detection_count + 1,
        last_detected_at = sysdatetime(),
        last_run_id      = @run_id,
        detail           = concat(N'Change detected affecting loaded dates from ',
                                  convert(nvarchar(10),
                                          iif(@affected_from < p.affected_from, @affected_from, p.affected_from), 23),
                                  N' - NOT rebuilt by the daily run; use @RebuildFrom to apply')
    from Layercake.etl_daily_count_pending_rebuild p
    where p.[source] = @source
      and p.applied_at is null;
    set @logged = @@rowcount;

    if @logged = 0
    begin
        set @detail = concat(N'Change detected affecting loaded dates from ',
                             convert(nvarchar(10), @affected_from, 23),
                             N' - NOT rebuilt by the daily run; use @RebuildFrom to apply');

        insert into Layercake.etl_daily_count_pending_rebuild
        ([source], affected_from, last_run_id, detail)
        values (@source, @affected_from, @run_id, @detail);
        set @logged = @@rowcount;
    end
end

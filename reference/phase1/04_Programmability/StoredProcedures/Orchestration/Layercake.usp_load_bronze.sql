/*====================================================================
    Layercake.usp_load_bronze
    Orchestration - calls the per-table modules in order
====================================================================*/

/*************************************************************************************
    14 - ORCHESTRATORS
    ---------------------------------------------------------------------------------
    Recreates the four entry points that used to BE the pipeline, as thin
    orchestrators over the per-table modules in 11 / 12 / 13:

        Layercake.usp_load_bronze       -> the 9 bronze modules
        Layercake.usp_load_silver       -> the 14 silver modules
        Layercake.usp_load_gold         -> the 12 gold modules
        Layercake.usp_run_daily_load    -> bronze -> silver -> gold, one run_id

    ENTRY POINTS AND SIGNATURES ARE UNCHANGED. An existing SQL Agent job, ADF
    pipeline or ad hoc call keeps working exactly as before:

        exec Layercake.usp_run_daily_load;
        exec Layercake.usp_run_daily_load @FullRebuild = 1;

    ---------------------------------------------------------------------------------
    WHY THE ORCHESTRATORS HAVE NO TRY/CATCH
    ---------------------------------------------------------------------------------
    Each module already opens its own etl_run_log step, rolls back its own
    transaction on failure, logs the error against that step, and re-throws. An
    orchestrator adding another catch would log nothing new and would only
    obscure the error line. So the layer orchestrators are a plain ordered
    sequence: the first module to throw stops the layer, and the exception
    propagates to usp_run_daily_load, which logs the 'run' row as Failed and
    re-throws to the scheduler. This is the same log shape and the same failure
    behaviour as the monolithic procs.

    ---------------------------------------------------------------------------------
    ORDER IS THE CONTRACT
    ---------------------------------------------------------------------------------
    The modules are independent procedures but NOT independent of each other's
    output. The sequences below are the dependency order; the notable edges are:

      * every silver reference module must precede usp_load_silv_member_base
        (the base resolves country / gender / rpq / lapse-reason ids);
      * usp_load_ref_campaign_year_config must follow usp_load_ref_date_spine
        (it derives its campaign years from the spine);
      * usp_load_silv_member_base must precede membership_events, data_anomaly,
        member_profile and annual_rate_base (all four read it);
      * usp_load_silv_member_state_ranges must follow membership_events (the
        ranges derive entirely from the events) and precede member_profile
        (the affected-date calculation reads the ranges);
      * usp_load_silv_daily_count must follow state_ranges, member_profile and
        payment_events;
      * every gold dimension must precede the facts that key on it, and
        usp_load_dim_date must precede both date-keyed facts.

    ---------------------------------------------------------------------------------
    RUNNING A SINGLE MODULE
    ---------------------------------------------------------------------------------
    Every module takes an optional @run_id and generates one if omitted, so any
    single table can be rebuilt on its own and still be traceable in
    etl_run_log:

        -- reload one bronze table after a source fix
        exec Layercake.usp_load_brnz_subs_status;

        -- re-derive the events (and everything that hangs off them)
        exec Layercake.usp_load_silv_member_base;
        exec Layercake.usp_load_silv_membership_events;
        exec Layercake.usp_load_silv_member_state_ranges;

        -- tie several targeted modules into ONE traceable run
        declare @rid uniqueidentifier = newid();
        exec Layercake.usp_load_silv_member_base        @run_id = @rid;
        exec Layercake.usp_load_silv_membership_events  @run_id = @rid;

    APPLYING A RETROSPECTIVE CORRECTION (unchanged workflow):

        -- what history has drifted from source?
        select * from Layercake.etl_daily_count_pending_rebuild where applied_at is null;
        -- apply it (outside the daily window - this can be a long walk):
        exec Layercake.usp_load_silver @RebuildFrom = '2025-10-01';
        -- ...or just the daily count, if nothing upstream needs re-deriving:
        exec Layercake.usp_load_silv_daily_count @RebuildFrom = '2025-10-01';

    ---------------------------------------------------------------------------------
    MONITORING (unchanged)
    ---------------------------------------------------------------------------------
        -- latest run, step by step
        select top 50 * from Layercake.etl_run_log
        where run_id = (select top 1 run_id from Layercake.etl_run_log
                        where layer = 'run' order by started_at desc)
        order by log_id;

        -- failures in the last 7 days
        select * from Layercake.etl_run_log
        where status = 'Failed' and started_at >= dateadd(day, -7, sysdatetime())
        order by started_at desc;

        -- live sub-step progress during a long run
        exec Layercake.usp_etl_watch;

    DEPLOY NOTE: deploy 11, 12 and 13 before this file. Remove
    01_usp_load_bronze.sql, 02_usp_load_silver_v9.sql, 03_usp_load_gold_v3_2.sql
    and 04_usp_run_daily_load.sql (and any earlier versions) from the deploy
    folder - this file owns all four names now.
*************************************************************************************/

/*====================================================================
    BRONZE
    ------------------------------------------------------------------
    The nine bronze tables are mutually independent (each syncs one
    source object into one landing table), so this order is the
    monolith's order and nothing more. Any of them can be run alone.
====================================================================*/
create or alter procedure Layercake.usp_load_bronze
    @run_id uniqueidentifier = null    -- supplied by the orchestrator; generated if run standalone
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    exec Layercake.usp_load_brnz_contact             @run_id = @run_id;
    exec Layercake.usp_load_brnz_enrolment           @run_id = @run_id;
    exec Layercake.usp_load_brnz_rics_record         @run_id = @run_id;
    exec Layercake.usp_load_brnz_local_group         @run_id = @run_id;
    exec Layercake.usp_load_brnz_cust_trans          @run_id = @run_id;
    exec Layercake.usp_load_brnz_subs_status         @run_id = @run_id;
    exec Layercake.usp_load_brnz_option_set          @run_id = @run_id;
    exec Layercake.usp_load_brnz_route               @run_id = @run_id;
    exec Layercake.usp_load_brnz_contact_test_record @run_id = @run_id;
end
go

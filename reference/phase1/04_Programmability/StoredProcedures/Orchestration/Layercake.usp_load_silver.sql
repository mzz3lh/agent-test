/*====================================================================
    Layercake.usp_load_silver
    Orchestration - calls the per-table modules in order
====================================================================*/

/*====================================================================
    SILVER
    ------------------------------------------------------------------
    Build order: refs -> date spine -> campaign year config -> payment
    events -> enrolment exceptions -> member base -> membership events
    -> anomalies -> state ranges -> member profile -> daily counts ->
    annual rate base.

    Parameters (all passed straight through to the daily-count module,
    the only one that takes them):
      @run_id              - orchestrator run id (generated if standalone)
      @FullRebuild         - 1 clears the loaded markers for the WHOLE
                             spine (from 2020-10-01) so both daily count
                             tables are rebuilt from scratch by this
                             run's chunked walk. Refs / events / ranges /
                             rate base always self-correct regardless.
      @RebuildFrom         - clear the loaded markers from this date
                             forward and re-do those dates. The
                             deliberate way to apply a retrospective
                             correction flagged in
                             etl_daily_count_pending_rebuild. Ignored
                             when @FullRebuild = 1.
      @DailyCountBatchDays - chunk size for the daily-count walk, and
                             therefore the granularity at which a failed
                             run resumes (default 31; minimum 1).
====================================================================*/
create or alter procedure Layercake.usp_load_silver
    @run_id              uniqueidentifier = null,
    @FullRebuild         bit  = 0,
    @RebuildFrom         date = null,
    @DailyCountBatchDays int  = 31
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    -- reference tables: insert-new + update-in-place only, so surrogate ids
    -- stay stable and the incremental gold facts keep resolving
    exec Layercake.usp_load_silv_ref_assessment_route @run_id = @run_id;
    exec Layercake.usp_load_silv_ref_rpq_variant      @run_id = @run_id;
    exec Layercake.usp_load_silv_ref_country          @run_id = @run_id;
    exec Layercake.usp_load_silv_ref_lapse_reason     @run_id = @run_id;

    -- calendar: the config derives its campaign years from the spine
    exec Layercake.usp_load_ref_date_spine            @run_id = @run_id;
    exec Layercake.usp_load_ref_campaign_year_config  @run_id = @run_id;

    -- payments feed the Renewal / Readmission events and the daily paid count
    exec Layercake.usp_load_silv_payment_events       @run_id = @run_id;

    -- curated gap-fill dates for paying contacts with no qualifying enrolment
    -- or election row. BETWEEN THE TWO DELIBERATELY: the capture driver is the
    -- payment events above, and the member base below coalesces the result in.
    -- Insert-only for captures, flag-only for retirement - see the module
    -- header for why, and for how a new capture reaches the daily count.
    exec Layercake.usp_load_ref_enrolment_exception   @run_id = @run_id;

    -- the per-contact base every derivation below reads
    exec Layercake.usp_load_silv_member_base          @run_id = @run_id;

    -- events, then the rule checks over the same base
    exec Layercake.usp_load_silv_membership_events    @run_id = @run_id;
    exec Layercake.usp_load_silv_data_anomaly         @run_id = @run_id;

    -- ranges derive from the events; the profile's affected-date
    -- calculation reads the ranges, so it follows them
    exec Layercake.usp_load_silv_member_state_ranges  @run_id = @run_id;
    exec Layercake.usp_load_silv_member_profile       @run_id = @run_id;

    -- daily counts (detail + main, chunked and marked per chunk)
    exec Layercake.usp_load_silv_daily_count
         @run_id              = @run_id,
         @FullRebuild         = @FullRebuild,
         @RebuildFrom         = @RebuildFrom,
         @DailyCountBatchDays = @DailyCountBatchDays;

    -- segment-level annual counts for the DAX rate measures
    exec Layercake.usp_load_silv_annual_rate_base     @run_id = @run_id;
end
go

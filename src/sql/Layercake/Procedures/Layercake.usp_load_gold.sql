/*====================================================================
    Layercake.usp_load_gold
    Orchestration - calls the per-table modules in order
====================================================================*/

/*====================================================================
    GOLD
    ------------------------------------------------------------------
    Dimensions first (every fact key must resolve, and id 0 is the 'N/A'
    member in each), then the three facts.

    Parameters:
      @run_id          - orchestrator run id (generated if standalone)
      @DetailBatchDays - date-window size for the batched star detail
                         fact load (default 31; minimum 1)
====================================================================*/
create or alter procedure Layercake.usp_load_gold
    @run_id          uniqueidentifier = null,
    @DetailBatchDays int = 31
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    -- dimensions: straight upserts from the silver refs, ids copied across
    exec Layercake.usp_load_dim_membership_grade  @run_id = @run_id;
    exec Layercake.usp_load_dim_assessment_route  @run_id = @run_id;
    exec Layercake.usp_load_dim_rpq_variant       @run_id = @run_id;
    exec Layercake.usp_load_dim_country           @run_id = @run_id;
    exec Layercake.usp_load_dim_gender            @run_id = @run_id;
    exec Layercake.usp_load_dim_membership_status @run_id = @run_id;
    exec Layercake.usp_load_dim_lapse_reason      @run_id = @run_id;
    exec Layercake.usp_load_dim_campaign_year     @run_id = @run_id;
    exec Layercake.usp_load_dim_date              @run_id = @run_id;

    -- facts
    exec Layercake.usp_load_fact_membership_events @run_id = @run_id;

    exec Layercake.usp_load_fact_daily_member_count_detail
         @run_id          = @run_id,
         @DetailBatchDays = @DetailBatchDays;

    exec Layercake.usp_load_fact_annual_rate_base  @run_id = @run_id;
end

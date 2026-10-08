/*====================================================================
    Layercake.usp_run_daily_load
    Orchestration - calls the per-table modules in order
====================================================================*/

/*====================================================================
    DAILY RUN
    ------------------------------------------------------------------
    Runs bronze -> silver -> gold under one run_id so the whole run can
    be traced in Layercake.etl_run_log.

    * Any layer failure stops the run (a layer must not build on a
      partial predecessor). The failed module, its error and every
      module before it are in the log.
    * Every module is a re-derive + diff, and the daily count is a
      load-what-isn't-marked walk, so recovery is simply re-running this
      proc - it picks up whatever the failed run didn't finish. No
      manual cleanup is ever needed.
    * @FullRebuild = 1 forces silv_daily_count / silv_daily_count_detail
      (and therefore the gold detail fact) to recompute from the start
      of the spine - use after changing business rules, otherwise leave
      at 0.

    Schedule daily, e.g.:
        exec Layercake.usp_run_daily_load;

    For a targeted retrospective rebuild, call the silver orchestrator
    (or the daily-count module) directly with @RebuildFrom - see the
    file header.
====================================================================*/
create or alter procedure Layercake.usp_run_daily_load
    @FullRebuild bit = 0
as
begin
    set nocount on;
    set xact_abort on;

    declare @run_id uniqueidentifier = newid(),
            @log_id bigint,
            @err    nvarchar(4000);

    exec Layercake.usp_etl_log_start @run_id, 'run', 'usp_run_daily_load', @log_id output;

    begin try
        -- each module manages its own transaction and step logging
        exec Layercake.usp_load_bronze @run_id = @run_id;
        exec Layercake.usp_load_silver @run_id = @run_id, @FullRebuild = @FullRebuild;
        exec Layercake.usp_load_gold   @run_id = @run_id;

        exec Layercake.usp_etl_log_end @log_id, 'Success';
    end try
    begin catch
        if xact_state() <> 0 rollback;
        set @err = concat(error_message(), ' (error ', error_number(), ', line ', error_line(), ')');
        exec Layercake.usp_etl_log_end @log_id, 'Failed', null, null, null, @err;
        throw;    -- surface to the scheduler so the job reports failure
    end catch
end

/*====================================================================
    Layercake.usp_etl_log_progress
    Control - ETL logging / progress
====================================================================*/

/*====================================================================
    Logging proc: one call = one durable row + one live message.
    @ts is IN/OUT: pass the sub-step start time in, get "now" back so the
    next sub-step's timer starts automatically.
====================================================================*/
create or alter procedure Layercake.usp_etl_log_progress
    @log_id   bigint,
    @substep  nvarchar(128),
    @rows     int = null,
    @ts       datetime2(3) output
as
begin
    set nocount on;

    declare @now datetime2(3) = sysdatetime();
    if @ts is null set @ts = @now;
    declare @ms bigint = datediff_big(millisecond, @ts, @now);

    insert into Layercake.etl_progress_log
        (log_id, substep, rows_affected, started_at, finished_at, duration_ms)
    values
        (@log_id, @substep, @rows, @ts, @now, @ms);

    -- live output: streams to the Messages tab immediately (severity 0 =
    -- informational, does not trip xact_abort or the caller's catch block)
    declare @step nvarchar(128) =
        isnull((select step_name from Layercake.etl_run_log with (nolock)
                where log_id = @log_id), N'?');

    declare @msg nvarchar(400) = concat(
        convert(varchar(8), @now, 108), N'  ',
        @step, N' | ', @substep,
        N' - ', format(@ms / 1000.0, '0.0'), N's',
        iif(@rows is not null, concat(N'  (', format(@rows, 'N0'), N' rows)'), N''));

    raiserror('%s', 0, 1, @msg) with nowait;

    set @ts = @now;     -- next sub-step's timer starts here
end

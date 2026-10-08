/*====================================================================
    Layercake.usp_etl_log_start
    Control - ETL logging / progress
====================================================================*/

create or alter procedure Layercake.usp_etl_log_start
    @run_id     uniqueidentifier,
    @layer      varchar(12),
    @step_name  varchar(128),
    @log_id     bigint output
as
begin
    set nocount on;
    insert into Layercake.etl_run_log (run_id, layer, step_name)
    values (@run_id, @layer, @step_name);
    set @log_id = scope_identity();
end

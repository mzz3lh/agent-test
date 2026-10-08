/*====================================================================
    Layercake.usp_etl_log_end
    Control - ETL logging / progress
====================================================================*/

create or alter procedure Layercake.usp_etl_log_end
    @log_id         bigint,
    @status         varchar(10),
    @rows_inserted  int = null,
    @rows_updated   int = null,
    @rows_deleted   int = null,
    @error_message  nvarchar(4000) = null
as
begin
    set nocount on;
    update Layercake.etl_run_log
    set finished_at   = sysdatetime(),
        status        = @status,
        rows_inserted = @rows_inserted,
        rows_updated  = @rows_updated,
        rows_deleted  = @rows_deleted,
        error_message = @error_message
    where log_id = @log_id;
end
go

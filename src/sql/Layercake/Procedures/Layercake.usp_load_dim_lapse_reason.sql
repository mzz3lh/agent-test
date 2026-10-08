/*====================================================================
    Layercake.usp_load_dim_lapse_reason
    Gold layer - loads one table
====================================================================*/

/*====================================================================
    7. Layercake.dim_lapse_reason
====================================================================*/
create or alter procedure Layercake.usp_load_dim_lapse_reason
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id bigint, @ins int, @upd int, @err nvarchar(4000);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'gold', 'dim_lapse_reason', @log_id output;
        begin tran;

        update d set lapse_code = s.lapse_code, reason_name = s.reason_name
        from Layercake.dim_lapse_reason d
        join Layercake.silv_ref_lapse_reason s on s.id = d.id
        where exists (select s.lapse_code, s.reason_name except select d.lapse_code, d.reason_name);
        set @upd = @@rowcount;

        insert into Layercake.dim_lapse_reason (id, lapse_code, reason_name)
        select s.id, s.lapse_code, s.reason_name
        from Layercake.silv_ref_lapse_reason s
        where not exists (select 1 from Layercake.dim_lapse_reason d where d.id = s.id);
        set @ins = @@rowcount;

        commit;
        exec Layercake.usp_etl_log_end @log_id, 'Success', @ins, @upd, 0;
    end try
    begin catch
        if xact_state() <> 0 rollback;
        set @err = concat(error_message(), ' (error ', error_number(), ', line ', error_line(), ')');
        if @log_id is not null
            exec Layercake.usp_etl_log_end @log_id, 'Failed', @ins, @upd, 0, @err;
        throw;
    end catch
end

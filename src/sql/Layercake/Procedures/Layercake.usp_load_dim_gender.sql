/*====================================================================
    Layercake.usp_load_dim_gender
    Gold layer - loads one table
====================================================================*/

/*====================================================================
    5. Layercake.dim_gender
====================================================================*/
create or alter procedure Layercake.usp_load_dim_gender
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id bigint, @ins int, @upd int, @err nvarchar(4000);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'gold', 'dim_gender', @log_id output;
        begin tran;

        update d set gender_code = s.gender_code, gender_name = s.gender_name
        from Layercake.dim_gender d
        join Layercake.silv_ref_gender s on s.id = d.id
        where exists (select s.gender_code, s.gender_name except select d.gender_code, d.gender_name);
        set @upd = @@rowcount;

        insert into Layercake.dim_gender (id, gender_code, gender_name)
        select s.id, s.gender_code, s.gender_name
        from Layercake.silv_ref_gender s
        where not exists (select 1 from Layercake.dim_gender d where d.id = s.id);
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

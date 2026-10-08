/*====================================================================
    Layercake.usp_load_dim_rpq_variant
    Gold layer - loads one table
====================================================================*/

/*====================================================================
    3. Layercake.dim_rpq_variant
====================================================================*/
create or alter procedure Layercake.usp_load_dim_rpq_variant
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id bigint, @ins int, @upd int, @err nvarchar(4000);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'gold', 'dim_rpq_variant', @log_id output;
        begin tran;

        update d set variant_id = s.variant_id, variant_name = s.variant_name
        from Layercake.dim_rpq_variant d
        join Layercake.silv_ref_rpq_variant s on s.id = d.id
        where exists (select s.variant_id, s.variant_name except select d.variant_id, d.variant_name);
        set @upd = @@rowcount;

        insert into Layercake.dim_rpq_variant (id, variant_id, variant_name)
        select s.id, s.variant_id, s.variant_name
        from Layercake.silv_ref_rpq_variant s
        where not exists (select 1 from Layercake.dim_rpq_variant d where d.id = s.id);
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

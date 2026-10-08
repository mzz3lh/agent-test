/*====================================================================
    Layercake.usp_load_silv_ref_rpq_variant
    Silver layer - loads one table
====================================================================*/

/*====================================================================
    2. Layercake.silv_ref_rpq_variant
====================================================================*/
create or alter procedure Layercake.usp_load_silv_ref_rpq_variant
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id bigint, @ins int, @upd int, @err nvarchar(4000);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'silver', 'silv_ref_rpq_variant', @log_id output;
        begin tran;

        -- RPQ variants, from bronze routes
        insert into Layercake.silv_ref_rpq_variant (variant_id, variant_name)
        select rt.apuk_routeid, rt.apuk_name
        from Layercake.brnz_route rt
        where rt.apuk_name is not null
          and rt._is_deleted = 0
          and not exists (select 1 from Layercake.silv_ref_rpq_variant v
                          where v.variant_id = rt.apuk_routeid);
        set @ins = @@rowcount;

        update v
        set variant_name = rt.apuk_name
        from Layercake.silv_ref_rpq_variant v
        join Layercake.brnz_route rt on rt.apuk_routeid = v.variant_id
        where v.id <> 0
          and rt._is_deleted = 0
          and rt.apuk_name is not null
          and v.variant_name <> rt.apuk_name;
        set @upd = @@rowcount;

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

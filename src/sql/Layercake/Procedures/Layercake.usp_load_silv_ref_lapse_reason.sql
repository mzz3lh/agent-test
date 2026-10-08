/*====================================================================
    Layercake.usp_load_silv_ref_lapse_reason
    Silver layer - loads one table
====================================================================*/

/*====================================================================
    4. Layercake.silv_ref_lapse_reason
    ------------------------------------------------------------------
    From the bronze option-set landing (apuk_lapsecode). Feeds the Lapse
    event subtype. Any new code lands automatically.
====================================================================*/
create or alter procedure Layercake.usp_load_silv_ref_lapse_reason
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id bigint, @ins int, @upd int, @err nvarchar(4000);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'silver', 'silv_ref_lapse_reason', @log_id output;
        begin tran;

        insert into Layercake.silv_ref_lapse_reason (lapse_code, reason_name)
        select os.[Option], os.LocalizedLabel
        from Layercake.brnz_option_set os
        where os.OptionSetName = N'apuk_lapsecode'
          and os._is_deleted = 0
          and os.LocalizedLabel is not null
          and not exists (select 1 from Layercake.silv_ref_lapse_reason r
                          where r.lapse_code = os.[Option]);
        set @ins = @@rowcount;

        update r
        set reason_name = os.LocalizedLabel
        from Layercake.silv_ref_lapse_reason r
        join Layercake.brnz_option_set os
          on  os.OptionSetName = N'apuk_lapsecode'
          and os.[Option] = r.lapse_code
        where r.id <> 0
          and os._is_deleted = 0
          and os.LocalizedLabel is not null
          and r.reason_name <> os.LocalizedLabel;
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

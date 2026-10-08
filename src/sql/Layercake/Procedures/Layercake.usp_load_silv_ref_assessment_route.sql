/*====================================================================
    Layercake.usp_load_silv_ref_assessment_route
    Silver layer - loads one table
====================================================================*/

/*====================================================================
    1. Layercake.silv_ref_assessment_route
    ------------------------------------------------------------------
    Insert-new + update-in-place ONLY - members are never deleted and
    ids never move, so history keeps resolving and gold surrogate keys
    stay stable. The id-0 'N/A' member is seeded by the baseline DDL and
    is never touched here.
====================================================================*/
create or alter procedure Layercake.usp_load_silv_ref_assessment_route
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id bigint, @ins int, @upd int, @err nvarchar(4000);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'silver', 'silv_ref_assessment_route', @log_id output;
        begin tran;

        -- assessment routes, from the bronze option-set landing
        insert into Layercake.silv_ref_assessment_route (route_code, route_name)
        select os.[Option], os.LocalizedLabel
        from Layercake.brnz_option_set os
        where os.OptionSetName = N'apuk_assessmenttype'
          and os._is_deleted = 0
          and os.LocalizedLabel is not null
          and not exists (select 1 from Layercake.silv_ref_assessment_route r
                          where r.route_code = os.[Option]);
        set @ins = @@rowcount;

        update r
        set route_name = os.LocalizedLabel
        from Layercake.silv_ref_assessment_route r
        join Layercake.brnz_option_set os
          on  os.OptionSetName = N'apuk_assessmenttype'
          and os.[Option] = r.route_code
        where r.id <> 0                    -- never touch the N/A member
          and os._is_deleted = 0
          and os.LocalizedLabel is not null
          and r.route_name <> os.LocalizedLabel;
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

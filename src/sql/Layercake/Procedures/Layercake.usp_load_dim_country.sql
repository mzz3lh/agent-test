/*====================================================================
    Layercake.usp_load_dim_country
    Gold layer - loads one table
====================================================================*/

/*====================================================================
    4. Layercake.dim_country
    ------------------------------------------------------------------
    Carries both region flavours; region reporting rolls up from here.
====================================================================*/
create or alter procedure Layercake.usp_load_dim_country
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id bigint, @ins int, @upd int, @err nvarchar(4000);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'gold', 'dim_country', @log_id output;
        begin tran;

        update d
        set country_id              = s.country_id,
            country_name            = s.country_name,
            region_name             = s.region_name,
            market_reporting_region = s.market_reporting_region
        from Layercake.dim_country d
        join Layercake.silv_ref_country s on s.id = d.id
        where exists (select s.country_id, s.country_name, s.region_name, s.market_reporting_region
                      except
                      select d.country_id, d.country_name, d.region_name, d.market_reporting_region);
        set @upd = @@rowcount;

        insert into Layercake.dim_country (id, country_id, country_name, region_name, market_reporting_region)
        select s.id, s.country_id, s.country_name, s.region_name, s.market_reporting_region
        from Layercake.silv_ref_country s
        where not exists (select 1 from Layercake.dim_country d where d.id = s.id);
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

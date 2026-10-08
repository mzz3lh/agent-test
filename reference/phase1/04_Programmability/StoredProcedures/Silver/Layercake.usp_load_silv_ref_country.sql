/*====================================================================
    Layercake.usp_load_silv_ref_country
    Silver layer - loads one table
====================================================================*/

/*====================================================================
    3. Layercake.silv_ref_country
    ------------------------------------------------------------------
    Both region flavours carried until region values are signed off
    against board-level reporting.
====================================================================*/
create or alter procedure Layercake.usp_load_silv_ref_country
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id bigint, @ins int, @upd int, @err nvarchar(4000);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'silver', 'silv_ref_country', @log_id output;
        begin tran;

        insert into Layercake.silv_ref_country (country_id, country_name, region_name, market_reporting_region)
        select lg.apuk_countryid,
               lg.apuk_countryid_name,
               isnull(lg.apuk_worldregionid_name, 'N/K'),
               isnull(lg.market_reporting_region, 'N/K')
        from Layercake.brnz_local_group lg
        where lg._is_deleted = 0
          and lg.apuk_countryid_name is not null
          and not exists (select 1 from Layercake.silv_ref_country c
                          where c.country_id = lg.apuk_countryid);
        set @ins = @@rowcount;

        update c
        set country_name            = lg.apuk_countryid_name,
            region_name             = isnull(lg.apuk_worldregionid_name, 'N/K'),
            market_reporting_region = isnull(lg.market_reporting_region, 'N/K')
        from Layercake.silv_ref_country c
        join Layercake.brnz_local_group lg on lg.apuk_countryid = c.country_id
        where c.id <> 0
          and lg._is_deleted = 0
          and lg.apuk_countryid_name is not null
          and exists (select lg.apuk_countryid_name,
                             isnull(lg.apuk_worldregionid_name, 'N/K'),
                             isnull(lg.market_reporting_region, 'N/K')
                      except
                      select c.country_name, c.region_name, c.market_reporting_region);
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
go

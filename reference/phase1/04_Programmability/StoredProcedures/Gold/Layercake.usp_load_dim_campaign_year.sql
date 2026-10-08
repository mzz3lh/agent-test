/*====================================================================
    Layercake.usp_load_dim_campaign_year
    Gold layer - loads one table
====================================================================*/

/*====================================================================
    8. Layercake.dim_campaign_year
    ------------------------------------------------------------------
    From ref_campaign_year_config; carries the configurable bulk lapse
    date into the model.
====================================================================*/
create or alter procedure Layercake.usp_load_dim_campaign_year
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id bigint, @ins int, @upd int, @err nvarchar(4000);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'gold', 'dim_campaign_year', @log_id output;
        begin tran;

        update d
        set campaign_year_start = s.campaign_year_start,
            campaign_year_end   = s.campaign_year_end,
            bulk_lapse_date     = s.bulk_lapse_date
        from Layercake.dim_campaign_year d
        join Layercake.ref_campaign_year_config s on s.campaign_year = d.campaign_year
        where exists (select s.campaign_year_start, s.campaign_year_end, s.bulk_lapse_date
                      except
                      select d.campaign_year_start, d.campaign_year_end, d.bulk_lapse_date);
        set @upd = @@rowcount;

        insert into Layercake.dim_campaign_year (campaign_year, campaign_year_start, campaign_year_end, bulk_lapse_date)
        select s.campaign_year, s.campaign_year_start, s.campaign_year_end, s.bulk_lapse_date
        from Layercake.ref_campaign_year_config s
        where not exists (select 1 from Layercake.dim_campaign_year d where d.campaign_year = s.campaign_year);
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
go

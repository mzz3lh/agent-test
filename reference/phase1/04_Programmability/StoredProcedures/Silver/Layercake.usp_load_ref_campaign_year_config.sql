/*====================================================================
    Layercake.usp_load_ref_campaign_year_config
    Silver layer - loads one table
====================================================================*/

/*====================================================================
    6. Layercake.ref_campaign_year_config
    ------------------------------------------------------------------
    Extended (insert-only) for any campaign years the spine now covers -
    existing rows are left untouched so a manual bulk-lapse override is
    never overwritten. Must run AFTER usp_load_ref_date_spine.
    [Confirm the CY2026 bulk-lapse changeover explicitly with Alex.]
====================================================================*/
create or alter procedure Layercake.usp_load_ref_campaign_year_config
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id bigint, @ins int, @err nvarchar(4000);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'silver', 'ref_campaign_year_config', @log_id output;
        begin tran;

        insert into Layercake.ref_campaign_year_config
        (campaign_year, campaign_year_start, campaign_year_end, bulk_lapse_date)
        select cy.campaign_year,
               datefromparts(cy.campaign_year - 1, 10, 1),
               datefromparts(cy.campaign_year, 9, 30),
               -- 1 June historically, 1 May from Campaign Year 2026 [confirm with Alex]
               case when cy.campaign_year >= 2026
                    then datefromparts(cy.campaign_year, 5, 1)
                    else datefromparts(cy.campaign_year, 6, 1) end
        from (select distinct campaign_year from Layercake.ref_date_spine) cy
        where not exists (select 1 from Layercake.ref_campaign_year_config c
                          where c.campaign_year = cy.campaign_year);
        set @ins = @@rowcount;

        commit;
        exec Layercake.usp_etl_log_end @log_id, 'Success', @ins, 0, 0;
    end try
    begin catch
        if xact_state() <> 0 rollback;
        set @err = concat(error_message(), ' (error ', error_number(), ', line ', error_line(), ')');
        if @log_id is not null
            exec Layercake.usp_etl_log_end @log_id, 'Failed', @ins, 0, 0, @err;
        throw;
    end catch
end
go

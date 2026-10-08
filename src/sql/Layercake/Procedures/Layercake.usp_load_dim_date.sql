/*====================================================================
    Layercake.usp_load_dim_date
    Gold layer - loads one table
====================================================================*/

/*====================================================================
    9. Layercake.dim_date
    ------------------------------------------------------------------
    APPEND-ONLY (the spine itself is append-only). The surrogate id is
    the identity - new spine dates simply take the next id; the id-0
    'NA' member is seeded by the baseline DDL and never touched here.
    Ids are assigned once and are stable thereafter, which is what lets
    the facts store date_id.
====================================================================*/
create or alter procedure Layercake.usp_load_dim_date
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id bigint, @ins int, @err nvarchar(4000);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'gold', 'dim_date', @log_id output;
        begin tran;

        insert into Layercake.dim_date ([date], [campaign_year], [campaign_quarter])
        select s.[date], s.[campaign_year], s.[campaign_quarter]
        from Layercake.ref_date_spine s
        where not exists (select 1 from Layercake.dim_date d where d.[date] = s.[date]);
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

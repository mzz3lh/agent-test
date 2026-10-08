/*====================================================================
    Layercake.usp_load_ref_date_spine
    Silver layer - loads one table
====================================================================*/

/*====================================================================
    5. Layercake.ref_date_spine
    ------------------------------------------------------------------
    Extend only, never rebuilt. One row per day from 2020-10-01 to two
    years ahead of today; campaign year runs Oct-Sep, so Oct/Nov/Dec
    belong to the FOLLOWING campaign year (Q1).
====================================================================*/
create or alter procedure Layercake.usp_load_ref_date_spine
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id bigint, @ins int, @err nvarchar(4000),
            @today  date = cast(getdate() as date);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'silver', 'ref_date_spine', @log_id output;
        begin tran;

        declare @spine_from date = isnull((select dateadd(day, 1, max([date])) from Layercake.ref_date_spine), '20201001'),
                @spine_to   date = dateadd(year, 2, @today);

        set @ins = 0;
        if @spine_from <= @spine_to
        begin
            -- 10^4 tally = up to ~27 years of gap coverage per run
            with t0 as (select n from (values (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) x(n)),
            tally as (
                select row_number() over (order by (select null)) - 1 as n
                from t0 a cross join t0 b cross join t0 c cross join t0 d
            )
            insert into Layercake.ref_date_spine ([date], [campaign_year], [campaign_quarter])
            select d.[date],
                   case when month(d.[date]) >= 10 then year(d.[date]) + 1 else year(d.[date]) end,
                   case when month(d.[date]) in (10,11,12) then 'Q1'
                        when month(d.[date]) in (1,2,3)    then 'Q2'
                        when month(d.[date]) in (4,5,6)    then 'Q3'
                        when month(d.[date]) in (7,8,9)    then 'Q4'
                        else 'NK' end
            from tally
            cross apply (select dateadd(day, tally.n, @spine_from) as [date]) d
            where tally.n <= datediff(day, @spine_from, @spine_to);
            set @ins = @@rowcount;
        end

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

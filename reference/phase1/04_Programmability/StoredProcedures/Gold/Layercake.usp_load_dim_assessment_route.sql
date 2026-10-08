/*====================================================================
    Layercake.usp_load_dim_assessment_route
    Gold layer - loads one table
====================================================================*/

/*====================================================================
    2. Layercake.dim_assessment_route
====================================================================*/
create or alter procedure Layercake.usp_load_dim_assessment_route
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id bigint, @ins int, @upd int, @err nvarchar(4000);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'gold', 'dim_assessment_route', @log_id output;
        begin tran;

        update d set route_code = s.route_code, route_name = s.route_name
        from Layercake.dim_assessment_route d
        join Layercake.silv_ref_assessment_route s on s.id = d.id
        where exists (select s.route_code, s.route_name except select d.route_code, d.route_name);
        set @upd = @@rowcount;

        insert into Layercake.dim_assessment_route (id, route_code, route_name)
        select s.id, s.route_code, s.route_name
        from Layercake.silv_ref_assessment_route s
        where not exists (select 1 from Layercake.dim_assessment_route d where d.id = s.id);
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

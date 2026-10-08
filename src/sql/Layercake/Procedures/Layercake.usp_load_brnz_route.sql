/*====================================================================
    Layercake.usp_load_brnz_route
    Bronze layer - loads one table
====================================================================*/

/*====================================================================
    8. synapse_ce.apuk_route -> Layercake.brnz_route
====================================================================*/
create or alter procedure Layercake.usp_load_brnz_route
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id    bigint,
            @ins       int,
            @upd       int,
            @del       int,
            @src_count bigint,
            @tgt_count bigint,
            @err       nvarchar(4000);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'bronze', 'brnz_route', @log_id output;
        begin tran;

        -- feeds silv_ref_rpq_variant
        select apuk_routeid, apuk_name
        into #src_route
        from synapse_ce.apuk_route;
        create unique clustered index cx_src_route on #src_route (apuk_routeid);

        update tgt
        set apuk_name   = s.apuk_name,
            _is_deleted = 0,
            _deleted_at = null,
            _updated_at = sysdatetime()
        from Layercake.brnz_route tgt
        join #src_route s on s.apuk_routeid = tgt.apuk_routeid
        where tgt._is_deleted = 1
           or exists (select s.apuk_name except select tgt.apuk_name);
        set @upd = @@rowcount;

        insert into Layercake.brnz_route (apuk_routeid, apuk_name)
        select s.apuk_routeid, s.apuk_name
        from #src_route s
        where not exists (select 1 from Layercake.brnz_route t where t.apuk_routeid = s.apuk_routeid);
        set @ins = @@rowcount;

        update tgt
        set _is_deleted = 1, _deleted_at = sysdatetime(), _updated_at = sysdatetime()
        from Layercake.brnz_route tgt
        where tgt._is_deleted = 0
          and not exists (select 1 from #src_route s where s.apuk_routeid = tgt.apuk_routeid);
        set @del = @@rowcount;

        select @src_count = count(*) from #src_route;
        select @tgt_count = count(*) from Layercake.brnz_route where _is_deleted = 0;
        if @src_count <> @tgt_count
            raiserror('Row count mismatch after sync of Layercake.brnz_route: source %I64d vs active target %I64d.', 16, 1, @src_count, @tgt_count);

        commit;
        exec Layercake.usp_etl_log_end @log_id, 'Success', @ins, @upd, @del;
    end try
    begin catch
        if xact_state() <> 0 rollback;
        set @err = concat(error_message(), ' (error ', error_number(), ', line ', error_line(), ')');
        if @log_id is not null
            exec Layercake.usp_etl_log_end @log_id, 'Failed', @ins, @upd, @del, @err;
        throw;
    end catch
end

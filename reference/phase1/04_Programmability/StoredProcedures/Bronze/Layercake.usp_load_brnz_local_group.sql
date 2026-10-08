/*====================================================================
    Layercake.usp_load_brnz_local_group
    Bronze layer - loads one table
====================================================================*/

/*====================================================================
    4. CE.vwLocalGroup -> Layercake.brnz_local_group
====================================================================*/
create or alter procedure Layercake.usp_load_brnz_local_group
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
        exec Layercake.usp_etl_log_start @run_id, 'bronze', 'brnz_local_group', @log_id output;
        begin tran;

        -- the source view is one row per local group; we only need one row per
        -- country. Null country ids are skipped (they can never join to a
        -- contact), and if a country somehow carries two different region
        -- combinations, an arbitrary-but-deterministic single row wins.
        select apuk_countryid, apuk_countryid_name, market_reporting_region, apuk_worldregionid_name
        into #src_local_group
        from (
            select apuk_countryid, apuk_countryid_name, market_reporting_region, apuk_worldregionid_name,
                   row_number() over (partition by apuk_countryid
                                      order by apuk_countryid_name, market_reporting_region, apuk_worldregionid_name) rn
            from (
                select distinct apuk_countryid, apuk_countryid_name, market_reporting_region, apuk_worldregionid_name
                from CE.vwLocalGroup
                where apuk_countryid is not null
            ) d
        ) v
        where v.rn = 1;
        create unique clustered index cx_src_local_group on #src_local_group (apuk_countryid);

        update tgt
        set apuk_countryid_name     = s.apuk_countryid_name,
            market_reporting_region = s.market_reporting_region,
            apuk_worldregionid_name = s.apuk_worldregionid_name,
            _is_deleted             = 0,
            _deleted_at             = null,
            _updated_at             = sysdatetime()
        from Layercake.brnz_local_group tgt
        join #src_local_group s on s.apuk_countryid = tgt.apuk_countryid
        where tgt._is_deleted = 1
           or exists (select s.apuk_countryid_name, s.market_reporting_region, s.apuk_worldregionid_name
                      except
                      select tgt.apuk_countryid_name, tgt.market_reporting_region, tgt.apuk_worldregionid_name);
        set @upd = @@rowcount;

        insert into Layercake.brnz_local_group
        (apuk_countryid, apuk_countryid_name, market_reporting_region, apuk_worldregionid_name)
        select s.apuk_countryid, s.apuk_countryid_name, s.market_reporting_region, s.apuk_worldregionid_name
        from #src_local_group s
        where not exists (select 1 from Layercake.brnz_local_group t where t.apuk_countryid = s.apuk_countryid);
        set @ins = @@rowcount;

        update tgt
        set _is_deleted = 1, _deleted_at = sysdatetime(), _updated_at = sysdatetime()
        from Layercake.brnz_local_group tgt
        where tgt._is_deleted = 0
          and not exists (select 1 from #src_local_group s where s.apuk_countryid = tgt.apuk_countryid);
        set @del = @@rowcount;

        select @src_count = count(*) from #src_local_group;
        select @tgt_count = count(*) from Layercake.brnz_local_group where _is_deleted = 0;
        if @src_count <> @tgt_count
            raiserror('Row count mismatch after sync of Layercake.brnz_local_group: source %I64d vs active target %I64d.', 16, 1, @src_count, @tgt_count);

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
go

/*====================================================================
    Layercake.usp_load_brnz_subs_status
    Bronze layer - loads one table
====================================================================*/

/*====================================================================
    6. Subs.vwSubsMemberStatuses -> Layercake.brnz_subs_status
====================================================================*/
create or alter procedure Layercake.usp_load_brnz_subs_status
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
        exec Layercake.usp_etl_log_start @run_id, 'bronze', 'brnz_subs_status', @log_id output;
        begin tran;

        -- natural key is (contact, campaign year). Rows with a null contact are
        -- skipped (unusable downstream - payment events join on contact no).
        -- The source is expected to be unique on the key; the row_number guard
        -- keeps the load alive if it ever isn't.
        select [Contact No.], [Campaign Year], [Member Invoice Position], [Renewal Date], [Renewal Date Adj]
        into #src_subs_status
        from (
            select [Contact No.], [Campaign Year], [Member Invoice Position], [Renewal Date], [Renewal Date Adj],
                   row_number() over (partition by [Contact No.], [Campaign Year]
                                      order by [Renewal Date Adj] desc, [Renewal Date] desc) rn
            from Subs.vwSubsMemberStatuses
            where [Contact No.] is not null
              and [Campaign Year] is not null
        ) v
        where v.rn = 1;
        create unique clustered index cx_src_subs_status on #src_subs_status ([Contact No.], [Campaign Year]);

        update tgt
        set [Member Invoice Position] = s.[Member Invoice Position],
            [Renewal Date]            = s.[Renewal Date],
            [Renewal Date Adj]        = s.[Renewal Date Adj],
            _is_deleted               = 0,
            _deleted_at               = null,
            _updated_at               = sysdatetime()
        from Layercake.brnz_subs_status tgt
        join #src_subs_status s
          on  s.[Contact No.]  = tgt.[Contact No.]
          and s.[Campaign Year] = tgt.[Campaign Year]
        where tgt._is_deleted = 1
           or exists (select s.[Member Invoice Position], s.[Renewal Date], s.[Renewal Date Adj]
                      except
                      select tgt.[Member Invoice Position], tgt.[Renewal Date], tgt.[Renewal Date Adj]);
        set @upd = @@rowcount;

        insert into Layercake.brnz_subs_status
        ([Contact No.], [Campaign Year], [Member Invoice Position], [Renewal Date], [Renewal Date Adj])
        select s.[Contact No.], s.[Campaign Year], s.[Member Invoice Position], s.[Renewal Date], s.[Renewal Date Adj]
        from #src_subs_status s
        where not exists (select 1 from Layercake.brnz_subs_status t
                          where t.[Contact No.] = s.[Contact No.] and t.[Campaign Year] = s.[Campaign Year]);
        set @ins = @@rowcount;

        update tgt
        set _is_deleted = 1, _deleted_at = sysdatetime(), _updated_at = sysdatetime()
        from Layercake.brnz_subs_status tgt
        where tgt._is_deleted = 0
          and not exists (select 1 from #src_subs_status s
                          where s.[Contact No.] = tgt.[Contact No.] and s.[Campaign Year] = tgt.[Campaign Year]);
        set @del = @@rowcount;

        select @src_count = count(*) from #src_subs_status;
        select @tgt_count = count(*) from Layercake.brnz_subs_status where _is_deleted = 0;
        if @src_count <> @tgt_count
            raiserror('Row count mismatch after sync of Layercake.brnz_subs_status: source %I64d vs active target %I64d.', 16, 1, @src_count, @tgt_count);

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

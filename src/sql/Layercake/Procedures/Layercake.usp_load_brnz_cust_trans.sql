/*====================================================================
    Layercake.usp_load_brnz_cust_trans
    Bronze layer - loads one table
====================================================================*/

/*====================================================================
    5. synapse_fo.custtrans -> Layercake.brnz_cust_trans
====================================================================*/
create or alter procedure Layercake.usp_load_brnz_cust_trans
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
        exec Layercake.usp_etl_log_start @run_id, 'bronze', 'brnz_cust_trans', @log_id output;
        begin tran;

        -- approved lands as a column (no approved = 1 filter here) so silver
        -- can apply it
        select recid, accountnum, duedate, transdate, paymreference, amountcur, approved
        into #src_cust_trans
        from synapse_fo.custtrans;
        create unique clustered index cx_src_cust_trans on #src_cust_trans (recid);

        update tgt
        set accountnum    = s.accountnum,
            duedate       = s.duedate,
            transdate     = s.transdate,
            paymreference = s.paymreference,
            amountcur     = s.amountcur,
            approved      = s.approved,
            _is_deleted   = 0,
            _deleted_at   = null,
            _updated_at   = sysdatetime()
        from Layercake.brnz_cust_trans tgt
        join #src_cust_trans s on s.recid = tgt.recid
        where tgt._is_deleted = 1
           or exists (select s.accountnum, s.duedate, s.transdate, s.paymreference, s.amountcur, s.approved
                      except
                      select tgt.accountnum, tgt.duedate, tgt.transdate, tgt.paymreference, tgt.amountcur, tgt.approved);
        set @upd = @@rowcount;

        insert into Layercake.brnz_cust_trans
        (recid, accountnum, duedate, transdate, paymreference, amountcur, approved)
        select s.recid, s.accountnum, s.duedate, s.transdate, s.paymreference, s.amountcur, s.approved
        from #src_cust_trans s
        where not exists (select 1 from Layercake.brnz_cust_trans t where t.recid = s.recid);
        set @ins = @@rowcount;

        update tgt
        set _is_deleted = 1, _deleted_at = sysdatetime(), _updated_at = sysdatetime()
        from Layercake.brnz_cust_trans tgt
        where tgt._is_deleted = 0
          and not exists (select 1 from #src_cust_trans s where s.recid = tgt.recid);
        set @del = @@rowcount;

        select @src_count = count(*) from #src_cust_trans;
        select @tgt_count = count(*) from Layercake.brnz_cust_trans where _is_deleted = 0;
        if @src_count <> @tgt_count
            raiserror('Row count mismatch after sync of Layercake.brnz_cust_trans: source %I64d vs active target %I64d.', 16, 1, @src_count, @tgt_count);

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

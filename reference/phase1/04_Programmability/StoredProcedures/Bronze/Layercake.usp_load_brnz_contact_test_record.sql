/*====================================================================
    Layercake.usp_load_brnz_contact_test_record
    Bronze layer - loads one table
====================================================================*/

/*====================================================================
    9. ce.tblcontact_test_records -> Layercake.brnz_contact_test_record
====================================================================*/
create or alter procedure Layercake.usp_load_brnz_contact_test_record
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
        exec Layercake.usp_etl_log_start @run_id, 'bronze', 'brnz_contact_test_record', @log_id output;
        begin tran;

        -- landed so the test-record exclusion can be applied in silver.
        -- Note: a contact REMOVED from the test list gets soft-deleted here,
        -- which means silver stops excluding them on the next run - intended.
        select contactid
        into #src_test_record
        from ce.tblcontact_test_records;
        create unique clustered index cx_src_test_record on #src_test_record (contactid);

        -- key-only table: the only possible "update" is a resurrection
        update tgt
        set _is_deleted = 0, _deleted_at = null, _updated_at = sysdatetime()
        from Layercake.brnz_contact_test_record tgt
        join #src_test_record s on s.contactid = tgt.contactid
        where tgt._is_deleted = 1;
        set @upd = @@rowcount;

        insert into Layercake.brnz_contact_test_record (contactid)
        select s.contactid
        from #src_test_record s
        where not exists (select 1 from Layercake.brnz_contact_test_record t where t.contactid = s.contactid);
        set @ins = @@rowcount;

        update tgt
        set _is_deleted = 1, _deleted_at = sysdatetime(), _updated_at = sysdatetime()
        from Layercake.brnz_contact_test_record tgt
        where tgt._is_deleted = 0
          and not exists (select 1 from #src_test_record s where s.contactid = tgt.contactid);
        set @del = @@rowcount;

        select @src_count = count(*) from #src_test_record;
        select @tgt_count = count(*) from Layercake.brnz_contact_test_record where _is_deleted = 0;
        if @src_count <> @tgt_count
            raiserror('Row count mismatch after sync of Layercake.brnz_contact_test_record: source %I64d vs active target %I64d.', 16, 1, @src_count, @tgt_count);

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

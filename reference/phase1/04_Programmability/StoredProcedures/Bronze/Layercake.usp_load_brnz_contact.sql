/*====================================================================
    Layercake.usp_load_brnz_contact
    Bronze layer - loads one table
====================================================================*/

/*************************************************************************************
    11 - BRONZE MODULES: one stored procedure per bronze table
    ---------------------------------------------------------------------------------
    Splits the monolithic Layercake.usp_load_bronze (01_usp_load_bronze.sql) into
    nine independent modules, one per target table. The orchestrator that calls
    them in order lives in 14_orchestrators.sql and keeps the name
    Layercake.usp_load_bronze, so nothing upstream changes.

    Each module is self-contained:
      * takes @run_id (generated if run standalone, so any module can be run on
        its own for a targeted reload);
      * opens its own etl_run_log step under the SAME step name the monolith
        used, so existing monitoring queries are unaffected;
      * runs its own transaction - a failure rolls back only that table;
      * logs the failure against its own step and re-throws, so the caller
        (orchestrator or SQL Agent / ADF) sees the error.

    The per-table sync pattern is UNCHANGED from 01 (see that file's header for
    the reasoning) - only the procedure boundaries are new:

      1. Snapshot the source into a keyed #temp.
      2. UPDATE changed payloads + resurrect soft-deleted rows that reappeared.
      3. INSERT rows not yet in bronze (backfills, not just yesterday).
      4. Soft-DELETE rows no longer in the source (_is_deleted = 1).
      5. Reconciliation check: active bronze rows must equal the snapshot.

    NO business filters here: test-record exclusion, statecode, approved = 1 and
    the Student apuk_membergrade exclusion all live in silver.

    The #temp tables are dropped automatically when each procedure returns, so
    the explicit cleanup the monolith needed between steps is gone.

    Modules, in dependency order (they are mutually independent - the order is
    only for readability and matches the monolith):
        1. usp_load_brnz_contact
        2. usp_load_brnz_enrolment
        3. usp_load_brnz_rics_record
        4. usp_load_brnz_local_group
        5. usp_load_brnz_cust_trans
        6. usp_load_brnz_subs_status
        7. usp_load_brnz_option_set
        8. usp_load_brnz_route
        9. usp_load_brnz_contact_test_record

    DEPLOY NOTE: remove 01_usp_load_bronze.sql from the deploy folder so
    run-scripts.ps1 does not also create the monolithic version. 14 recreates
    Layercake.usp_load_bronze as the orchestrator.
*************************************************************************************/

/*====================================================================
    1. CE.vwContact -> Layercake.brnz_contact
====================================================================*/
create or alter procedure Layercake.usp_load_brnz_contact
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
        exec Layercake.usp_etl_log_start @run_id, 'bronze', 'brnz_contact', @log_id output;
        begin tran;

        -- CreatedOn / StateCode added 20260928_01 for the enrolment-exception
        -- capture in silver (usp_load_ref_enrolment_exception) - see that
        -- module and the column comments in 02_Tables/Bronze.
        select ContactId, Rics_contactno, Rics_ElectionDate, Rics_LapsedDate,
               MemberGrade_Description, GenderCode, rics_countryid,
               CreatedOn, StateCode
        into #src_contact
        from CE.vwContact;
        create unique clustered index cx_src_contact on #src_contact (ContactId);

        -- changed payloads + reappeared rows
        update tgt
        set Rics_contactno          = s.Rics_contactno,
            Rics_ElectionDate       = s.Rics_ElectionDate,
            Rics_LapsedDate         = s.Rics_LapsedDate,
            MemberGrade_Description = s.MemberGrade_Description,
            GenderCode              = s.GenderCode,
            rics_countryid          = s.rics_countryid,
            CreatedOn               = s.CreatedOn,
            StateCode               = s.StateCode,
            _is_deleted             = 0,
            _deleted_at             = null,
            _updated_at             = sysdatetime()
        from Layercake.brnz_contact tgt
        join #src_contact s on s.ContactId = tgt.ContactId
        where tgt._is_deleted = 1
           or exists (select s.Rics_contactno, s.Rics_ElectionDate, s.Rics_LapsedDate,
                             s.MemberGrade_Description, s.GenderCode, s.rics_countryid,
                             s.CreatedOn, s.StateCode
                      except
                      select tgt.Rics_contactno, tgt.Rics_ElectionDate, tgt.Rics_LapsedDate,
                             tgt.MemberGrade_Description, tgt.GenderCode, tgt.rics_countryid,
                             tgt.CreatedOn, tgt.StateCode);
        set @upd = @@rowcount;

        -- new rows (also backfills anything missing, not just the last day)
        insert into Layercake.brnz_contact
        (ContactId, Rics_contactno, Rics_ElectionDate, Rics_LapsedDate,
         MemberGrade_Description, GenderCode, rics_countryid, CreatedOn, StateCode)
        select s.ContactId, s.Rics_contactno, s.Rics_ElectionDate, s.Rics_LapsedDate,
               s.MemberGrade_Description, s.GenderCode, s.rics_countryid,
               s.CreatedOn, s.StateCode
        from #src_contact s
        where not exists (select 1 from Layercake.brnz_contact t where t.ContactId = s.ContactId);
        set @ins = @@rowcount;

        -- rows gone from source -> soft delete
        update tgt
        set _is_deleted = 1, _deleted_at = sysdatetime(), _updated_at = sysdatetime()
        from Layercake.brnz_contact tgt
        where tgt._is_deleted = 0
          and not exists (select 1 from #src_contact s where s.ContactId = tgt.ContactId);
        set @del = @@rowcount;

        -- active rows must mirror the source snapshot exactly
        select @src_count = count(*) from #src_contact;
        select @tgt_count = count(*) from Layercake.brnz_contact where _is_deleted = 0;
        if @src_count <> @tgt_count
            raiserror('Row count mismatch after sync of Layercake.brnz_contact: source %I64d vs active target %I64d.', 16, 1, @src_count, @tgt_count);

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

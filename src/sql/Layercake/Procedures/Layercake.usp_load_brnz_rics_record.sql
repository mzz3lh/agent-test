/*====================================================================
    Layercake.usp_load_brnz_rics_record
    Bronze layer - loads one table
====================================================================*/

/*====================================================================
    3. synapse_ce.apuk_ricsrecord -> Layercake.brnz_rics_record
====================================================================*/
create or alter procedure Layercake.usp_load_brnz_rics_record
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
        exec Layercake.usp_etl_log_start @run_id, 'bronze', 'brnz_rics_record', @log_id output;
        begin tran;

        -- deactivated records (statecode != 0) and null membership numbers land
        -- in full - the filters live in silver, so a member no longer silently
        -- loses their lapse date when a CE record is deactivated (open issue with Raj).
        -- apuk_membergrade also lands unfiltered - the Student (200000003)
        -- exclusion is a silver rule.
        select Id, apuk_contactid, apuk_ricsmembershipnumber, apuk_lapseddate,
               apuk_retirementdate, apuk_lapsecode, apuk_membergrade, statecode, ModifiedOn
        into #src_rics_record
        from synapse_ce.apuk_ricsrecord;
        create unique clustered index cx_src_rics on #src_rics_record (Id);

        update tgt
        set apuk_contactid            = s.apuk_contactid,
            apuk_ricsmembershipnumber = s.apuk_ricsmembershipnumber,
            apuk_lapseddate           = s.apuk_lapseddate,
            apuk_retirementdate       = s.apuk_retirementdate,
            apuk_lapsecode            = s.apuk_lapsecode,
            apuk_membergrade          = s.apuk_membergrade,
            statecode                 = s.statecode,
            ModifiedOn                = s.ModifiedOn,
            _is_deleted               = 0,
            _deleted_at               = null,
            _updated_at               = sysdatetime()
        from Layercake.brnz_rics_record tgt
        join #src_rics_record s on s.Id = tgt.Id
        where tgt._is_deleted = 1
           or exists (select s.apuk_contactid, s.apuk_ricsmembershipnumber, s.apuk_lapseddate,
                             s.apuk_retirementdate, s.apuk_lapsecode, s.apuk_membergrade,
                             s.statecode, s.ModifiedOn
                      except
                      select tgt.apuk_contactid, tgt.apuk_ricsmembershipnumber, tgt.apuk_lapseddate,
                             tgt.apuk_retirementdate, tgt.apuk_lapsecode, tgt.apuk_membergrade,
                             tgt.statecode, tgt.ModifiedOn);
        set @upd = @@rowcount;

        insert into Layercake.brnz_rics_record
        (Id, apuk_contactid, apuk_ricsmembershipnumber, apuk_lapseddate,
         apuk_retirementdate, apuk_lapsecode, apuk_membergrade, statecode, ModifiedOn)
        select s.Id, s.apuk_contactid, s.apuk_ricsmembershipnumber, s.apuk_lapseddate,
               s.apuk_retirementdate, s.apuk_lapsecode, s.apuk_membergrade, s.statecode, s.ModifiedOn
        from #src_rics_record s
        where not exists (select 1 from Layercake.brnz_rics_record t where t.Id = s.Id);
        set @ins = @@rowcount;

        update tgt
        set _is_deleted = 1, _deleted_at = sysdatetime(), _updated_at = sysdatetime()
        from Layercake.brnz_rics_record tgt
        where tgt._is_deleted = 0
          and not exists (select 1 from #src_rics_record s where s.Id = tgt.Id);
        set @del = @@rowcount;

        select @src_count = count(*) from #src_rics_record;
        select @tgt_count = count(*) from Layercake.brnz_rics_record where _is_deleted = 0;
        if @src_count <> @tgt_count
            raiserror('Row count mismatch after sync of Layercake.brnz_rics_record: source %I64d vs active target %I64d.', 16, 1, @src_count, @tgt_count);

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

/*====================================================================
    Layercake.usp_load_brnz_enrolment
    Bronze layer - loads one table
====================================================================*/

/*====================================================================
    2. synapse_ce.vwEnrolments -> Layercake.brnz_enrolment
====================================================================*/
create or alter procedure Layercake.usp_load_brnz_enrolment
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
        exec Layercake.usp_etl_log_start @run_id, 'bronze', 'brnz_enrolment', @log_id output;
        begin tran;

        -- full enrolment history lands: NO student / status code filters here
        select [ENR ID], [Contact No], [Enrolment Date], [End Date], [Election Date],
               [Application Type], [Route ID], [Status Code], [State Code],
               [Created Date], [Created DateTime]
        into #src_enrolment
        from synapse_ce.vwEnrolments;
        create unique clustered index cx_src_enrolment on #src_enrolment ([ENR ID]);

        update tgt
        set [Contact No]       = s.[Contact No],
            [Enrolment Date]   = s.[Enrolment Date],
            [End Date]         = s.[End Date],
            [Election Date]    = s.[Election Date],
            [Application Type] = s.[Application Type],
            [Route ID]         = s.[Route ID],
            [Status Code]      = s.[Status Code],
            [State Code]       = s.[State Code],
            [Created Date]     = s.[Created Date],
            [Created DateTime] = s.[Created DateTime],
            _is_deleted        = 0,
            _deleted_at        = null,
            _updated_at        = sysdatetime()
        from Layercake.brnz_enrolment tgt
        join #src_enrolment s on s.[ENR ID] = tgt.[ENR ID]
        where tgt._is_deleted = 1
           or exists (select s.[Contact No], s.[Enrolment Date], s.[End Date], s.[Election Date],
                             s.[Application Type], s.[Route ID], s.[Status Code], s.[State Code],
                             s.[Created Date], s.[Created DateTime]
                      except
                      select tgt.[Contact No], tgt.[Enrolment Date], tgt.[End Date], tgt.[Election Date],
                             tgt.[Application Type], tgt.[Route ID], tgt.[Status Code], tgt.[State Code],
                             tgt.[Created Date], tgt.[Created DateTime]);
        set @upd = @@rowcount;

        insert into Layercake.brnz_enrolment
        ([ENR ID], [Contact No], [Enrolment Date], [End Date], [Election Date],
         [Application Type], [Route ID], [Status Code], [State Code], [Created Date], [Created DateTime])
        select s.[ENR ID], s.[Contact No], s.[Enrolment Date], s.[End Date], s.[Election Date],
               s.[Application Type], s.[Route ID], s.[Status Code], s.[State Code],
               s.[Created Date], s.[Created DateTime]
        from #src_enrolment s
        where not exists (select 1 from Layercake.brnz_enrolment t where t.[ENR ID] = s.[ENR ID]);
        set @ins = @@rowcount;

        update tgt
        set _is_deleted = 1, _deleted_at = sysdatetime(), _updated_at = sysdatetime()
        from Layercake.brnz_enrolment tgt
        where tgt._is_deleted = 0
          and not exists (select 1 from #src_enrolment s where s.[ENR ID] = tgt.[ENR ID]);
        set @del = @@rowcount;

        select @src_count = count(*) from #src_enrolment;
        select @tgt_count = count(*) from Layercake.brnz_enrolment where _is_deleted = 0;
        if @src_count <> @tgt_count
            raiserror('Row count mismatch after sync of Layercake.brnz_enrolment: source %I64d vs active target %I64d.', 16, 1, @src_count, @tgt_count);

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

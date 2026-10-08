/*====================================================================
    Layercake.usp_load_brnz_option_set
    Bronze layer - loads one table
====================================================================*/

/*====================================================================
    7. synapse_ce.GlobalOptionSetMetadata -> Layercake.brnz_option_set
====================================================================*/
create or alter procedure Layercake.usp_load_brnz_option_set
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
        exec Layercake.usp_etl_log_start @run_id, 'bronze', 'brnz_option_set', @log_id output;
        begin tran;

        -- landed in full (all option sets); silver picks out apuk_assessmenttype
        -- and apuk_lapsecode. Key is (OptionSetName, Option) - if the source
        -- ever carries multiple languages per option, add LanguageCode to the
        -- key in the schema instead of relying on this dedupe.
        select OptionSetName, EntityName, [Option], LocalizedLabel
        into #src_option_set
        from (
            select OptionSetName, EntityName, [Option], LocalizedLabel,
                   row_number() over (partition by OptionSetName, [Option]
                                      order by EntityName, LocalizedLabel) rn
            from synapse_ce.GlobalOptionSetMetadata
            where OptionSetName is not null
              and [Option] is not null
        ) v
        where v.rn = 1;
        create unique clustered index cx_src_option_set on #src_option_set (OptionSetName, [Option]);

        update tgt
        set EntityName     = s.EntityName,
            LocalizedLabel = s.LocalizedLabel,
            _is_deleted    = 0,
            _deleted_at    = null,
            _updated_at    = sysdatetime()
        from Layercake.brnz_option_set tgt
        join #src_option_set s
          on  s.OptionSetName = tgt.OptionSetName
          and s.[Option]      = tgt.[Option]
        where tgt._is_deleted = 1
           or exists (select s.EntityName, s.LocalizedLabel
                      except
                      select tgt.EntityName, tgt.LocalizedLabel);
        set @upd = @@rowcount;

        insert into Layercake.brnz_option_set
        (OptionSetName, EntityName, [Option], LocalizedLabel)
        select s.OptionSetName, s.EntityName, s.[Option], s.LocalizedLabel
        from #src_option_set s
        where not exists (select 1 from Layercake.brnz_option_set t
                          where t.OptionSetName = s.OptionSetName and t.[Option] = s.[Option]);
        set @ins = @@rowcount;

        update tgt
        set _is_deleted = 1, _deleted_at = sysdatetime(), _updated_at = sysdatetime()
        from Layercake.brnz_option_set tgt
        where tgt._is_deleted = 0
          and not exists (select 1 from #src_option_set s
                          where s.OptionSetName = tgt.OptionSetName and s.[Option] = tgt.[Option]);
        set @del = @@rowcount;

        select @src_count = count(*) from #src_option_set;
        select @tgt_count = count(*) from Layercake.brnz_option_set where _is_deleted = 0;
        if @src_count <> @tgt_count
            raiserror('Row count mismatch after sync of Layercake.brnz_option_set: source %I64d vs active target %I64d.', 16, 1, @src_count, @tgt_count);

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

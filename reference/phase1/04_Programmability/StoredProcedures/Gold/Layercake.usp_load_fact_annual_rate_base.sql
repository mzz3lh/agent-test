/*====================================================================
    Layercake.usp_load_fact_annual_rate_base
    Gold layer - loads one table
====================================================================*/

/*====================================================================
    12. Layercake.fact_annual_rate_base
    ------------------------------------------------------------------
    Straight copy of silver, diff-synced on the 5-column segment key.
    The fact's clustered PK is the identity id (the baseline DDL owns
    it); the segment key is enforced by the unique nonclustered index
    ux_fact_annual_rate_base_segment, which is exactly what the three
    statements below seek on. The identity id is never referenced here:
    the insert lists its columns so id self-assigns, and updates are in
    place - so ids stay stable between runs. Power BI connects here for
    the rate DAX measures, never to the silver table.
====================================================================*/
create or alter procedure Layercake.usp_load_fact_annual_rate_base
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
        exec Layercake.usp_etl_log_start @run_id, 'gold', 'fact_annual_rate_base', @log_id output;
        begin tran;

        update tgt
        set members_start      = s.members_start,
            members_end        = s.members_end,
            members_joined     = s.members_joined,
            members_readmitted = s.members_readmitted,
            members_lapsed     = s.members_lapsed,
            members_renewed    = s.members_renewed
        from Layercake.fact_annual_rate_base tgt
        join Layercake.silv_annual_rate_base s
          on  s.campaign_year = tgt.campaign_year
          and s.grade_id = tgt.grade_id
          and s.membership_status_id = tgt.membership_status_id
          and s.country_id = tgt.country_id
          and s.gender_id = tgt.gender_id
        where exists (select s.members_start, s.members_end, s.members_joined,
                             s.members_readmitted, s.members_lapsed, s.members_renewed
                      except
                      select tgt.members_start, tgt.members_end, tgt.members_joined,
                             tgt.members_readmitted, tgt.members_lapsed, tgt.members_renewed);
        set @upd = @@rowcount;

        insert into Layercake.fact_annual_rate_base
        (campaign_year, grade_id, membership_status_id, country_id, gender_id,
         members_start, members_end, members_joined, members_readmitted, members_lapsed, members_renewed)
        select s.campaign_year, s.grade_id, s.membership_status_id, s.country_id, s.gender_id,
               s.members_start, s.members_end, s.members_joined, s.members_readmitted, s.members_lapsed, s.members_renewed
        from Layercake.silv_annual_rate_base s
        where not exists (select 1 from Layercake.fact_annual_rate_base t
                          where t.campaign_year = s.campaign_year
                            and t.grade_id = s.grade_id
                            and t.membership_status_id = s.membership_status_id
                            and t.country_id = s.country_id
                            and t.gender_id = s.gender_id);
        set @ins = @@rowcount;

        delete tgt
        from Layercake.fact_annual_rate_base tgt
        where not exists (select 1 from Layercake.silv_annual_rate_base s
                          where s.campaign_year = tgt.campaign_year
                            and s.grade_id = tgt.grade_id
                            and s.membership_status_id = tgt.membership_status_id
                            and s.country_id = tgt.country_id
                            and s.gender_id = tgt.gender_id);
        set @del = @@rowcount;

        -- gold must reconcile exactly back to silver
        select @src_count = count(*) from Layercake.silv_annual_rate_base;
        select @tgt_count = count(*) from Layercake.fact_annual_rate_base;
        if @src_count <> @tgt_count
            raiserror('Row count mismatch after sync of Layercake.fact_annual_rate_base vs silv_annual_rate_base: %I64d vs %I64d.', 16, 1, @src_count, @tgt_count);

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

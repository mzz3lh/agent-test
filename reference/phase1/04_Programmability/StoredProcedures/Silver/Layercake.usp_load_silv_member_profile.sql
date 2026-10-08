/*====================================================================
    Layercake.usp_load_silv_member_profile
    Silver layer - loads one table
====================================================================*/

/*====================================================================
    12. Layercake.silv_member_profile
    ------------------------------------------------------------------
    Per-contact reporting attributes for the DETAIL daily count:
    country_id, gender_id, retirement_date. Staged straight from
    silv_member_base and diff-synced on contact_no.

    WHY IT EXISTS: the state ranges don't carry these columns, so the
    range diff can never see an attribute change - without this table a
    member changing country/gender, or a retirement date arriving, would
    be completely invisible to the daily count.

    AFFECTED-DATE DERIVATION (feeds the pending-rebuild log):
      * country/gender changed  -> the contact's earliest range
        valid_from (attributes apply day-by-day as CURRENT values, so
        the whole active history would re-bucket);
      * retirement date changed -> the EARLIER of the old and new
        retirement dates (day-level Practising/Retired status is the
        only thing that reads it).
    New contacts and deleted contacts are NOT windowed here: their
    ranges are new/removed too, so the range diff already covers them.

    Must run AFTER usp_load_silv_member_state_ranges - the affected-date
    calculation reads the ranges.
====================================================================*/
create or alter procedure Layercake.usp_load_silv_member_profile
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id           bigint,
            @ins              int,
            @upd              int,
            @del              int,
            @rc               int,
            @substep_ts       datetime2(3),
            @err              nvarchar(4000),
            @prof_recalc_from date;

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'silver', 'silv_member_profile', @log_id output;
        set @substep_ts = sysdatetime();
        begin tran;

        select b.contact_no, b.country_id, b.gender_id, b.retirement_date
        into #prof_stage
        from Layercake.silv_member_base b;
        set @rc = @@rowcount;

        -- duplicate Rics_contactno fails loudly here (same philosophy as the
        -- #ev_stage PK): fix the duplicate contact, don't silently pick one
        create unique clustered index cx_prof_stage on #prof_stage (contact_no);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #prof_stage (from silv_member_base)', @rc, @substep_ts output;

        -- changed contacts, with the narrowest date each change can affect
        select
            s.contact_no,
            iif(exists (select s.country_id, s.gender_id
                        except
                        select t.country_id, t.gender_id), 1, 0) as demo_changed,
            case when isnull(s.retirement_date, '99991231') <> isnull(t.retirement_date, '99991231')
                 then (select min(d) from (values (s.retirement_date), (t.retirement_date)) x(d) where d is not null)
            end as retirement_changed_from
        into #prof_changed
        from #prof_stage s
        join Layercake.silv_member_profile t
          on  t.contact_no = s.contact_no
        where exists (select s.country_id, s.gender_id, s.retirement_date
                      except
                      select t.country_id, t.gender_id, t.retirement_date);
        set @rc = @@rowcount;

        set @prof_recalc_from = (
            select min(v.win_from)
            from (
                -- country/gender: from the contact's earliest state range
                select min(r.valid_from) as win_from
                from #prof_changed ch
                join Layercake.silv_member_state_ranges r
                  on  r.contact_no = ch.contact_no
                where ch.demo_changed = 1
                union all
                -- retirement date: from the earlier of old/new dates
                select min(ch.retirement_changed_from)
                from #prof_changed ch
                where ch.retirement_changed_from is not null
            ) v
            where v.win_from is not null);
        exec Layercake.usp_etl_log_progress @log_id, N'diff: changed contacts + affected-from', @rc, @substep_ts output;

        -- diff-sync: update changed
        update tgt
        set country_id      = s.country_id,
            gender_id       = s.gender_id,
            retirement_date = s.retirement_date
        from Layercake.silv_member_profile tgt
        join #prof_changed ch on ch.contact_no = tgt.contact_no
        join #prof_stage   s  on s.contact_no  = tgt.contact_no;
        set @upd = @@rowcount;
        exec Layercake.usp_etl_log_progress @log_id, N'sync: update', @upd, @substep_ts output;

        -- insert new contacts (their dates are covered by the range diff)
        insert into Layercake.silv_member_profile (contact_no, country_id, gender_id, retirement_date)
        select s.contact_no, s.country_id, s.gender_id, s.retirement_date
        from #prof_stage s
        where not exists (select 1 from Layercake.silv_member_profile t
                          where t.contact_no = s.contact_no);
        set @ins = @@rowcount;
        exec Layercake.usp_etl_log_progress @log_id, N'sync: insert', @ins, @substep_ts output;

        -- hard-delete contacts no longer derived (test-flagged, went Student,
        -- contact soft-deleted). Their ranges are removed by the state-range
        -- module in the same run.
        delete tgt
        from Layercake.silv_member_profile tgt
        where not exists (select 1 from #prof_stage s
                          where s.contact_no = tgt.contact_no);
        set @del = @@rowcount;
        exec Layercake.usp_etl_log_progress @log_id, N'sync: delete', @del, @substep_ts output;

        -- retro-change log: only if these changes reach already-loaded dates
        exec Layercake.usp_etl_log_pending_rebuild @run_id, 'member_profile', @prof_recalc_from, @rc output;
        if @rc > 0
            exec Layercake.usp_etl_log_progress @log_id, N'retro change logged (not rebuilt) - see etl_daily_count_pending_rebuild', @rc, @substep_ts output;

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

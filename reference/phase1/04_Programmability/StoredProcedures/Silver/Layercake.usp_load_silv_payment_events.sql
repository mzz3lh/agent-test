/*====================================================================
    Layercake.usp_load_silv_payment_events
    Silver layer - loads one table
====================================================================*/

/*====================================================================
    7. Layercake.silv_payment_events
    ------------------------------------------------------------------
    Full re-derive into #pay_stage, then diff-sync on the
    (contact_no, campaign_year) key. Campaign years whose
    renewal_date_adj picture changed are captured, because that column
    alone drives the day-by-day paid counts further down; the earliest
    date they affect is logged to the retro-change log (it does NOT
    widen the daily count window).
====================================================================*/
create or alter procedure Layercake.usp_load_silv_payment_events
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id          bigint,
            @ins             int,
            @upd             int,
            @del             int,
            @rc              int,
            @substep_ts      datetime2(3),
            @err             nvarchar(4000),
            @pay_recalc_from date;

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'silver', 'silv_payment_events', @log_id output;
        set @substep_ts = sysdatetime();
        begin tran;

        -- summarise cash transactions per contact + campaign year
        -- (approved = 1 filter lives here, moved out of bronze in v2)
        with trans as (
            select CY, accountnum, min(transdate) as transdate
            from (
                select
                    -- campaign year of the invoice: due Oct-Dec -> following year
                    case when month(max(duedate)) >= 10 then year(max(duedate)) + 1 else year(max(duedate)) end as CY,
                    accountnum,
                    paymreference,
                    min(transdate) as transdate,
                    sum(amountcur) as net,
                    sum(iif(amountcur > 0, amountcur, 0)) as invoiceamt
                from Layercake.brnz_cust_trans
                where approved = 1
                  and _is_deleted = 0
                group by accountnum, paymreference
                -- keep only settled (net < invoiced) or zero-invoice references
                having (sum(amountcur) < sum(iif(amountcur > 0, amountcur, 0))
                        or sum(iif(amountcur > 0, amountcur, 0)) = 0)
            ) v
            group by CY, accountnum
        )
        -- a payment event = a subs status in a "paid" invoice position.
        -- Partially Paid counts as paid by design: Direct Debit members show as
        -- Partially Paid for ~10 months, which is expected behaviour.
        -- Corporate members arrive via the same signal - employer-paid attribution deferred.
        -- NOTE (enrolment exceptions): contacts backfilled by 07 that have no
        -- brnz_subs_status rows at all simply never surface here - Active but
        -- never Paid, and no Renewal/Readmission events. Expected; see 07.
        select
            bss.[Contact No.]              as contact_no,
            bss.[Campaign Year]            as campaign_year,
            bct.transdate                  as payment_date,
            bss.[Renewal Date Adj]         as renewal_date_adj,
            bss.[Member Invoice Position]  as invoice_position
        into #pay_stage
        from Layercake.brnz_subs_status bss
        left join trans bct
          on  bss.[Campaign Year] = bct.CY
          and bss.[Contact No.]   = bct.accountnum
        where bss._is_deleted = 0
          and bss.[Member Invoice Position] in ('Full Concession', 'Fully Paid', 'Partially Paid', 'Pre-Subs Payment');
        set @rc = @@rowcount;

        create unique clustered index cx_pay_stage on #pay_stage (contact_no, campaign_year);
        exec Layercake.usp_etl_log_progress @log_id, N'stage #pay_stage (derive + index)', @rc, @substep_ts output;

        -- campaign years whose paid-count inputs changed (either direction of
        -- the comparison: new/changed rows, and rows that vanished)
        select campaign_year
        into #pay_changed_cy
        from (
            select campaign_year from (
                select contact_no, campaign_year, renewal_date_adj from #pay_stage
                except
                select contact_no, campaign_year, renewal_date_adj from Layercake.silv_payment_events
            ) a
            union
            select campaign_year from (
                select contact_no, campaign_year, renewal_date_adj from Layercake.silv_payment_events
                except
                select contact_no, campaign_year, renewal_date_adj from #pay_stage
            ) b
        ) v;
        set @rc = @@rowcount;

        -- campaign year Y spans 01 Oct (Y-1) .. 30 Sep (Y): the earliest date
        -- those changes could affect is that first day
        set @pay_recalc_from = (select min(datefromparts(campaign_year - 1, 10, 1)) from #pay_changed_cy);
        exec Layercake.usp_etl_log_progress @log_id, N'diff: changed campaign years', @rc, @substep_ts output;

        -- diff-sync: update changed payloads
        update tgt
        set payment_date     = s.payment_date,
            renewal_date_adj = s.renewal_date_adj,
            invoice_position = s.invoice_position
        from Layercake.silv_payment_events tgt
        join #pay_stage s
          on  s.contact_no = tgt.contact_no
          and s.campaign_year = tgt.campaign_year
        where exists (select s.payment_date, s.renewal_date_adj, s.invoice_position
                      except
                      select tgt.payment_date, tgt.renewal_date_adj, tgt.invoice_position);
        set @upd = @@rowcount;
        exec Layercake.usp_etl_log_progress @log_id, N'sync: update', @upd, @substep_ts output;

        -- insert missing
        insert into Layercake.silv_payment_events
        (contact_no, campaign_year, payment_date, renewal_date_adj, invoice_position)
        select s.contact_no, s.campaign_year, s.payment_date, s.renewal_date_adj, s.invoice_position
        from #pay_stage s
        where not exists (select 1 from Layercake.silv_payment_events t
                          where t.contact_no = s.contact_no and t.campaign_year = s.campaign_year);
        set @ins = @@rowcount;
        exec Layercake.usp_etl_log_progress @log_id, N'sync: insert', @ins, @substep_ts output;

        -- hard-delete rows no longer derived (e.g. invoice position moved out
        -- of the "paid" list, or the bronze row was soft-deleted)
        delete tgt
        from Layercake.silv_payment_events tgt
        where not exists (select 1 from #pay_stage s
                          where s.contact_no = tgt.contact_no and s.campaign_year = tgt.campaign_year);
        set @del = @@rowcount;
        exec Layercake.usp_etl_log_progress @log_id, N'sync: delete', @del, @substep_ts output;

        -- retro-change log: only if these changes reach already-loaded dates
        exec Layercake.usp_etl_log_pending_rebuild @run_id, 'payments', @pay_recalc_from, @rc output;
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

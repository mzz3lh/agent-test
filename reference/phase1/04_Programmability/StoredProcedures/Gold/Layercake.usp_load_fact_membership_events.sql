/*====================================================================
    Layercake.usp_load_fact_membership_events
    Gold layer - loads one table
====================================================================*/

/*====================================================================
    10. Layercake.fact_membership_events
    ------------------------------------------------------------------
    Diff-sync on event_id. id 0 in every dimension is the 'N/A' member,
    so the foreign keys always resolve. Carries all five event types.
    date_id is resolved from dim_date on event_date; events that
    pre-date the spine resolve to the id-0 'NA' member - which is why
    event_date stays on the fact as an attribute.
====================================================================*/
create or alter procedure Layercake.usp_load_fact_membership_events
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
        exec Layercake.usp_etl_log_start @run_id, 'gold', 'fact_membership_events', @log_id output;
        begin tran;

        update tgt
        set event_type           = s.event_type,
            event_subtype        = s.event_subtype,
            event_date           = s.event_date,
            date_id              = isnull(dd.id, 0),
            contact_no           = s.contact_no,
            grade_id             = s.grade_id,
            assessment_route_id  = s.assessment_route_id,
            rpq_variant_id       = s.rpq_variant_id,
            hpb_id               = s.hpb_id,
            country_id           = s.country_id,
            gender_id            = s.gender_id,
            membership_status_id = s.membership_status_id,
            campaign_year        = s.campaign_year,
            campaign_quarter     = s.campaign_quarter
        from Layercake.fact_membership_events tgt
        join Layercake.silv_membership_events s on s.event_id = tgt.event_id
        left join Layercake.dim_date dd on dd.[date] = s.event_date
        where exists (select s.event_type, s.event_subtype, s.event_date, isnull(dd.id, 0), s.contact_no,
                             s.grade_id, s.assessment_route_id, s.rpq_variant_id, s.hpb_id,
                             s.country_id, s.gender_id, s.membership_status_id,
                             s.campaign_year, s.campaign_quarter
                      except
                      select tgt.event_type, tgt.event_subtype, tgt.event_date, tgt.date_id, tgt.contact_no,
                             tgt.grade_id, tgt.assessment_route_id, tgt.rpq_variant_id, tgt.hpb_id,
                             tgt.country_id, tgt.gender_id, tgt.membership_status_id,
                             tgt.campaign_year, tgt.campaign_quarter);
        set @upd = @@rowcount;

        insert into Layercake.fact_membership_events
        (event_id, event_type, event_subtype, event_date, date_id, contact_no, grade_id, assessment_route_id,
         rpq_variant_id, hpb_id, country_id, gender_id, membership_status_id, campaign_year, campaign_quarter)
        select s.event_id, s.event_type, s.event_subtype, s.event_date, isnull(dd.id, 0), s.contact_no, s.grade_id,
               s.assessment_route_id, s.rpq_variant_id, s.hpb_id, s.country_id, s.gender_id,
               s.membership_status_id, s.campaign_year, s.campaign_quarter
        from Layercake.silv_membership_events s
        left join Layercake.dim_date dd on dd.[date] = s.event_date
        where not exists (select 1 from Layercake.fact_membership_events t where t.event_id = s.event_id);
        set @ins = @@rowcount;

        delete tgt
        from Layercake.fact_membership_events tgt
        where not exists (select 1 from Layercake.silv_membership_events s where s.event_id = tgt.event_id);
        set @del = @@rowcount;

        -- gold must reconcile exactly back to silver
        select @src_count = count(*) from Layercake.silv_membership_events;
        select @tgt_count = count(*) from Layercake.fact_membership_events;
        if @src_count <> @tgt_count
            raiserror('Row count mismatch after sync of Layercake.fact_membership_events vs silv_membership_events: %I64d vs %I64d.', 16, 1, @src_count, @tgt_count);

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

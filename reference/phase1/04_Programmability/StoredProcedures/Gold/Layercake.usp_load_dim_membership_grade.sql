/*====================================================================
    Layercake.usp_load_dim_membership_grade
    Gold layer - loads one table
====================================================================*/

/*************************************************************************************
    13 - GOLD MODULES: one stored procedure per gold table
    ---------------------------------------------------------------------------------
    Splits the monolithic Layercake.usp_load_gold (03_usp_load_gold_v3_2.sql) into
    twelve independent modules, one per target table. The orchestrator that calls
    them in order lives in 14_orchestrators.sql and keeps the name
    Layercake.usp_load_gold with an unchanged signature.

    All logic is carried over verbatim from v3_2. Nothing crossed a step boundary
    in the monolith - every temp table lived and died inside its own step - so
    unlike silver this split needed no structural change at all. The nine
    dimension upserts that shared a single 'dim_tables' step are simply nine
    procedures now.

    Each module is self-contained: takes @run_id, opens its own etl_run_log step,
    runs its own transaction(s), logs failure against its own step and re-throws.

    LOGGING CHANGE: the monolith logged all nine dimension upserts under the
    single step name 'dim_tables'. Each now logs under its own table name. The
    three fact step names are unchanged.

    DIMENSION IDS: every dim id is a straight copy of the corresponding silver
    reference surrogate, so the ids are stable and id 0 is always the 'N/A'
    member - which is what makes the star's foreign keys always resolve.

    Modules, in dependency order:
        1.  usp_load_dim_membership_grade
        2.  usp_load_dim_assessment_route
        3.  usp_load_dim_rpq_variant
        4.  usp_load_dim_country
        5.  usp_load_dim_gender
        6.  usp_load_dim_membership_status
        7.  usp_load_dim_lapse_reason
        8.  usp_load_dim_campaign_year
        9.  usp_load_dim_date
        10. usp_load_fact_membership_events               (needs 1-7, 9)
        11. usp_load_fact_daily_member_count_detail       (needs 1, 4, 5, 6, 9)
        12. usp_load_fact_annual_rate_base                (needs 1, 4, 5, 6, 8)

    NOTE: Layercake.fact_daily_member_count is retired and has no module - the
    star detail fact covers everything it reported (the daily headline is
    SUM(detail), region rolls up from dim_country, grade from
    dim_membership_grade).

    DEPLOY NOTE: requires baseline_ddl.sql (or 00 + 03's guarded DDL) and
    06_etl_progress_tracking.sql. Remove 03_usp_load_gold_v3_2.sql (and any
    earlier version) from the deploy folder so run-scripts.ps1 does not also
    create the monolithic version. 14 recreates Layercake.usp_load_gold as the
    orchestrator.
*************************************************************************************/

/*====================================================================
    1. Layercake.dim_membership_grade
    ------------------------------------------------------------------
    Grades are Candidate / Qualified (+ the id-0 N/A member). Lapsed is
    NOT a grade - lapsing is purely a lifecycle EVENT and appears in no
    dimension.
====================================================================*/
create or alter procedure Layercake.usp_load_dim_membership_grade
    @run_id uniqueidentifier = null
as
begin
    set nocount on;
    set xact_abort on;

    if @run_id is null set @run_id = newid();

    declare @log_id bigint, @ins int, @upd int, @err nvarchar(4000);

    begin try
        exec Layercake.usp_etl_log_start @run_id, 'gold', 'dim_membership_grade', @log_id output;
        begin tran;

        update d set grade_name = s.grade_name
        from Layercake.dim_membership_grade d
        join Layercake.silv_ref_membership_grade s on s.id = d.id
        where d.grade_name <> s.grade_name;
        set @upd = @@rowcount;

        insert into Layercake.dim_membership_grade (id, grade_name)
        select s.id, s.grade_name
        from Layercake.silv_ref_membership_grade s
        where not exists (select 1 from Layercake.dim_membership_grade d where d.id = s.id);
        set @ins = @@rowcount;

        commit;
        exec Layercake.usp_etl_log_end @log_id, 'Success', @ins, @upd, 0;
    end try
    begin catch
        if xact_state() <> 0 rollback;
        set @err = concat(error_message(), ' (error ', error_number(), ', line ', error_line(), ')');
        if @log_id is not null
            exec Layercake.usp_etl_log_end @log_id, 'Failed', @ins, @upd, 0, @err;
        throw;
    end catch
end
go

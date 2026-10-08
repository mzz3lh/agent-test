/*====================================================================
    Layercake - QUICK TRUNCATE (bronze / silver / gold)

    Static, one statement per table. No dynamic SQL, no loops.

    *** THIS DELETES ALL PIPELINE DATA. TEST DATABASES ONLY. ***

    Notes:
      * Tables that are the target of a foreign key cannot be TRUNCATEd
        (even with the FK disabled), so the silver ref_/dim_ tables get
        DELETE + a reseed of their identity instead. Everything else is
        a straight TRUNCATE.
      * Facts/child tables are cleared before the refs/dims they point at.
      * Control (etl_*) and recon_* tables are NOT touched here - use
        Scripts/Reset/reset-data.sql if you want a full pipeline rewind.
      * Seed rows go with the refs/dims: re-run
            Deploy-Database.ps1 -Phase 03
        afterwards, or the id-0 'N/A' members are missing.
      * ref_enrolment_exception is truncated below but is NOT brought
        back by phase 03 - since 20260928_02 that capture lives in the
        silver load (Layercake.usp_load_ref_enrolment_exception). The
        next load re-captures the whole cohort from bronze under the
        current rules.

    Usage:
        sqlcmd -S <server> -d <db> -U <user> -P <pwd> -i truncate-all.sql -b -N -I
====================================================================*/

set nocount on;
set xact_abort on;
go

-------------------------------- GOLD --------------------------------
-- facts first
truncate table Layercake.fact_annual_rate_base;
truncate table Layercake.fact_daily_member_count_detail;
truncate table Layercake.fact_membership_events;

-- dims (FK targets -> delete, not truncate)
delete from Layercake.dim_assessment_route;
delete from Layercake.dim_campaign_year;
delete from Layercake.dim_country;
delete from Layercake.dim_date;
delete from Layercake.dim_gender;
delete from Layercake.dim_lapse_reason;
delete from Layercake.dim_membership_grade;
delete from Layercake.dim_membership_status;
delete from Layercake.dim_rpq_variant;

dbcc checkident ('Layercake.dim_date', reseed, 0) with no_infomsgs;
go

------------------------------- SILVER -------------------------------
-- data tables first
truncate table Layercake.silv_annual_rate_base;
truncate table Layercake.silv_daily_count;
truncate table Layercake.silv_daily_count_detail;
truncate table Layercake.silv_data_anomaly;
truncate table Layercake.silv_member_base;
truncate table Layercake.silv_member_profile;
truncate table Layercake.silv_member_state_ranges;
truncate table Layercake.silv_membership_events;
truncate table Layercake.silv_payment_events;
truncate table Layercake.ref_enrolment_exception;

-- refs (FK targets -> delete, not truncate)
delete from Layercake.ref_campaign_year_config;
delete from Layercake.ref_date_spine;
delete from Layercake.silv_ref_assessment_route;
delete from Layercake.silv_ref_country;
delete from Layercake.silv_ref_gender;
delete from Layercake.silv_ref_lapse_reason;
delete from Layercake.silv_ref_membership_grade;
delete from Layercake.silv_ref_membership_status;
delete from Layercake.silv_ref_rpq_variant;

dbcc checkident ('Layercake.silv_ref_assessment_route',  reseed, 0) with no_infomsgs;
dbcc checkident ('Layercake.silv_ref_country',           reseed, 0) with no_infomsgs;
dbcc checkident ('Layercake.silv_ref_gender',            reseed, 0) with no_infomsgs;
dbcc checkident ('Layercake.silv_ref_lapse_reason',      reseed, 0) with no_infomsgs;
dbcc checkident ('Layercake.silv_ref_membership_grade',  reseed, 0) with no_infomsgs;
dbcc checkident ('Layercake.silv_ref_membership_status', reseed, 0) with no_infomsgs;
dbcc checkident ('Layercake.silv_ref_rpq_variant',       reseed, 0) with no_infomsgs;
go

------------------------------- BRONZE -------------------------------
truncate table Layercake.brnz_contact;
truncate table Layercake.brnz_contact_test_record;
truncate table Layercake.brnz_cust_trans;
truncate table Layercake.brnz_enrolment;
truncate table Layercake.brnz_local_group;
truncate table Layercake.brnz_option_set;
truncate table Layercake.brnz_rics_record;
truncate table Layercake.brnz_route;
truncate table Layercake.brnz_subs_status;
go

print 'Bronze / silver / gold cleared.';
print 'NEXT: Deploy-Database.ps1 -Phase 03   (reload seed rows)';
go

/*====================================================================
    20260910_01 - expand Layercake.ref_enrolment_exception
    ------------------------------------------------------------------
    WHAT CHANGES
      Nine audit columns are added to Layercake.ref_enrolment_exception,
      recording the contact's condensed per-campaign-year status from
      Subs.vwSubsMemberStatuses at capture:
        first_active_campaign_year int null
        last_active_campaign_year  int null
        first_paid_campaign_year   int null
        last_paid_campaign_year    int null
        active_campaign_years      int not null default 0
        paid_campaign_years        int not null default 0
        is_active_current          bit not null default 0
        is_paid_current            bit not null default 0
        source_enrolment_rows      int not null default 0
      (paid = a paid invoice position in that campaign year; active =
       paid that year or the year before; "current" = the campaign year
       current when the row was captured.)

    WHY
      The capture driver (03_SeedData/seed-enrolment-exception.sql and
      Scripts/Maintenance/enrolment-exception-topup.sql) moved from the
      CE contact grade / lapse flags to the subs view evaluated for
      EVERY campaign year, so the gap-fill also serves historical
      counts. The new columns record why each contact was captured and
      the span of membership the subs history shows, and whether any
      enrolment rows existed at all, so the curated population can be
      audited.

    OPERATOR NOTES
      * Shape only - no row is touched. Existing rows get the defaults
        (nulls and zeros), which reads as "captured before this
        migration".
      * Runtime: instant (metadata-only ALTERs, the table is small).
      * No pipeline reload follows. To RE-CAPTURE the table under the
        new driver, truncate it and run `Deploy-Database.ps1 -Phase 03`
        (curated rows are lost and re-derived from source as at that
        moment), or run the insert-only top-up script to ADD the newly
        admitted contacts while keeping every existing row. A silver
        reload after either picks the additions up.
      * Guarded per column, so the file is safe to run by hand.
====================================================================*/

if not exists (select 1 from sys.columns
               where object_id = object_id('Layercake.ref_enrolment_exception')
                 and name = 'first_active_campaign_year')
    alter table Layercake.ref_enrolment_exception
        add first_active_campaign_year int null;
go

if not exists (select 1 from sys.columns
               where object_id = object_id('Layercake.ref_enrolment_exception')
                 and name = 'last_active_campaign_year')
    alter table Layercake.ref_enrolment_exception
        add last_active_campaign_year int null;
go

if not exists (select 1 from sys.columns
               where object_id = object_id('Layercake.ref_enrolment_exception')
                 and name = 'first_paid_campaign_year')
    alter table Layercake.ref_enrolment_exception
        add first_paid_campaign_year int null;
go

if not exists (select 1 from sys.columns
               where object_id = object_id('Layercake.ref_enrolment_exception')
                 and name = 'last_paid_campaign_year')
    alter table Layercake.ref_enrolment_exception
        add last_paid_campaign_year int null;
go

if not exists (select 1 from sys.columns
               where object_id = object_id('Layercake.ref_enrolment_exception')
                 and name = 'active_campaign_years')
    alter table Layercake.ref_enrolment_exception
        add active_campaign_years int not null constraint df_ref_enr_exc_active_cys default 0;
go

if not exists (select 1 from sys.columns
               where object_id = object_id('Layercake.ref_enrolment_exception')
                 and name = 'paid_campaign_years')
    alter table Layercake.ref_enrolment_exception
        add paid_campaign_years int not null constraint df_ref_enr_exc_paid_cys default 0;
go

if not exists (select 1 from sys.columns
               where object_id = object_id('Layercake.ref_enrolment_exception')
                 and name = 'is_active_current')
    alter table Layercake.ref_enrolment_exception
        add is_active_current bit not null constraint df_ref_enr_exc_active_cur default 0;
go

if not exists (select 1 from sys.columns
               where object_id = object_id('Layercake.ref_enrolment_exception')
                 and name = 'is_paid_current')
    alter table Layercake.ref_enrolment_exception
        add is_paid_current bit not null constraint df_ref_enr_exc_paid_cur default 0;
go

if not exists (select 1 from sys.columns
               where object_id = object_id('Layercake.ref_enrolment_exception')
                 and name = 'source_enrolment_rows')
    alter table Layercake.ref_enrolment_exception
        add source_enrolment_rows int not null constraint df_ref_enr_exc_src_rows default 0;
go

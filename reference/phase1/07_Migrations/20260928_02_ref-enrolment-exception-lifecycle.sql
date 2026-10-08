/*====================================================================
    20260928_02 - ref_enrolment_exception: pipeline lifecycle columns
    ------------------------------------------------------------------
    WHAT CHANGES
      Four columns and two check constraints are added to
      Layercake.ref_enrolment_exception:
        superseded_at      datetime2(3) null
        superseded_reason  varchar(60) null
        _capture_source    varchar(20) not null
        _last_seen_at      datetime2(3) not null default sysdatetime()
        ck_ref_enr_exc_cap_src      - _capture_source domain
        ck_ref_enr_exc_superseded   - reason present iff superseded

      Existing rows are stamped _capture_source = 'seed', because every
      row present before this migration came from the phase 03 capture
      or the hand-run top-up, and neither can be told apart after the
      fact. That backfill is done BY the ALTER, through a temporary
      default that is then dropped - an UPDATE in the same batch as the
      ALTER that adds the column cannot compile, and one in a later
      batch could not tell a first run from a second and would overwrite
      the module's own stamps. The finished shape carries no default on
      that column, matching the phase 02 definition: there is exactly
      one writer and it always supplies the value.

      The capture itself moves INTO THE PIPELINE in the same commit:
      Layercake.usp_load_ref_enrolment_exception (silver module 8a) runs
      on every silver load, and the phase 03 capture in
      03_SeedData/seed-enrolment-exception.sql is retired.

    WHY
      The table was a frozen point-in-time snapshot: phase 03 filled it
      only when EMPTY, and nothing in usp_run_daily_load ever touched it
      again. A from-scratch reload truncates it and re-derives against
      today's source, so it picked up every contact who had started
      paying since the original capture; a daily load did not. Those
      contacts have no qualifying enrolment or election, so without an
      exception row silv_member_base gives them a null enrolment AND
      election date, no Join event fires, no state range opens, and they
      drop out of the active count and BOTH paid counts. With one, they
      are counted. That was the whole of the small, drifting variance
      between a daily load and a rebuild on the most recent day.

      Moving the capture into the load closes it, and the two halves of
      the lifecycle keep the guarantees that made the snapshot desirable
      in the first place:

        * CAPTURE STAYS INSERT-ONLY, so a contact already captured keeps
          the dates their history was built on. History is not rewritten
          by a run.
        * A NEW CAPTURE IS STILL A RETROSPECTIVE CHANGE - the derived
          date is usually years old - so the module logs the earliest
          affected date to etl_daily_count_pending_rebuild under source
          'enrol_exception' and the daily-count walk leaves already-
          loaded dates alone. Today's count corrects itself immediately;
          history moves only when you ask for it with @RebuildFrom.
        * SUPERSESSION IS A FLAG. When a captured contact gains a
          qualifying vw_enrolment_base row - the data anomaly that
          caused the capture having been corrected upstream - the row is
          stamped superseded_at / superseded_reason rather than deleted.
          It stays inert wherever real data now covers it, because
          silv_member_base coalesces per date with the real row winning,
          and still fills whichever date the real rows do not supply.
          The stamp is CLEARED if the contact stops qualifying again, as
          silv_data_anomaly re-opens a resolved row.

    OPERATOR NOTES
      * Shape only, plus the _capture_source backfill the ALTER performs.
        No derived date is touched, so no count changes from this file
        alone.
      * Runtime: instant. The table holds thousands of rows, not
        millions.
      * REQUIRES 20260928_01 (brnz_contact.CreatedOn / StateCode) - a
        deploy applies them in order.
      * A silver reload follows and IS required for the alignment to
        take effect. The first run after it captures everyone who has
        started qualifying since the original snapshot, and will log a
        pending rebuild. Expect the most recent day's active and paid
        counts to RISE by roughly the size of that capture - check it
        against the review queries in the module header before applying
        the pending rebuild to history:

            select * from Layercake.etl_daily_count_pending_rebuild
            where applied_at is null;

      * Guarded per object, so the file is safe to run by hand.
====================================================================*/

if not exists (select 1 from sys.columns
               where object_id = object_id('Layercake.ref_enrolment_exception')
                 and name = 'superseded_at')
    alter table Layercake.ref_enrolment_exception
        add superseded_at datetime2(3) null;
go

if not exists (select 1 from sys.columns
               where object_id = object_id('Layercake.ref_enrolment_exception')
                 and name = 'superseded_reason')
    alter table Layercake.ref_enrolment_exception
        add superseded_reason varchar(60) null;
go

-- _capture_source: added with a TEMPORARY default of 'seed', which is what
-- backfills the rows that predate this file - every one of them came from the
-- phase 03 capture or the hand-run top-up, and the two cannot be told apart
-- after the fact. The default is dropped in the next batch so the shape matches
-- phase 02, where the column has none.
if not exists (select 1 from sys.columns
               where object_id = object_id('Layercake.ref_enrolment_exception')
                 and name = '_capture_source')
    alter table Layercake.ref_enrolment_exception
        add _capture_source varchar(20) not null
            constraint df_ref_enr_exc_cap_src_backfill default 'seed';
go

if exists (select 1 from sys.default_constraints
           where name = 'df_ref_enr_exc_cap_src_backfill')
    alter table Layercake.ref_enrolment_exception
        drop constraint df_ref_enr_exc_cap_src_backfill;
go

-- _last_seen_at: existing rows carry the time this migration ran. The first
-- silver load after it re-stamps every row that is still filling a gap, so the
-- value only matters for the few rows that same run supersedes.
if not exists (select 1 from sys.columns
               where object_id = object_id('Layercake.ref_enrolment_exception')
                 and name = '_last_seen_at')
    alter table Layercake.ref_enrolment_exception
        add _last_seen_at datetime2(3) not null
            constraint df_ref_enr_exc_seen default sysdatetime();
go

if not exists (select 1 from sys.check_constraints
               where name = 'ck_ref_enr_exc_cap_src')
    alter table Layercake.ref_enrolment_exception
        add constraint ck_ref_enr_exc_cap_src
            check (_capture_source in ('seed', 'topup', 'daily-load'));
go

if not exists (select 1 from sys.check_constraints
               where name = 'ck_ref_enr_exc_superseded')
    alter table Layercake.ref_enrolment_exception
        add constraint ck_ref_enr_exc_superseded
            check ((superseded_at is null     and superseded_reason is null)
                or (superseded_at is not null and superseded_reason is not null));
go

/*====================================================================
    20260915_01 - silv_member_base: subs-history backdating columns
    ------------------------------------------------------------------
    WHAT CHANGES
      Two columns are added to Layercake.silv_member_base:
        recorded_enrolment_date     date null
        enrolment_from_subs_history int not null default 0

    WHY
      Some contacts hold a valid, qualifying enrolment row whose date
      sits in a LATER campaign year than their first paid position in
      Subs.vwSubsMemberStatuses - the subs history says they were
      paying members for years before the source says they joined.
      Derived as recorded, module 9 emitted the Join in the later year
      (which counted the contact as paid from the Join event in a year
      they had NOT paid) with the earlier payments falling through as
      Renewals before any Join.

      usp_load_silv_member_base now backdates such an enrolment date to
      the first paid campaign year (the payment event's date in that
      year), so the Join lands where the paying started and every later
      paid year derives as a Renewal. The two columns keep the
      correction visible, in the spirit of ref_enrolment_exception:
      recorded_enrolment_date holds the date the source recorded, and
      the flag marks the row. usp_load_silv_data_anomaly reports the
      cohort as ENROLMENT_AFTER_FIRST_PAID.

    OPERATOR NOTES
      * Shape only. silv_member_base is truncated and rebuilt by every
        silver run, so no backfill: existing rows get the default (0 /
        null) until the next run re-derives them.
      * Runtime: instant (metadata-only ALTERs).
      * A silver reload follows and IS required for the change to take
        effect: exec Layercake.usp_load_silver (or the daily load). The
        moved Joins change state ranges, so the state-ranges module
        logs the earliest affected date to
        etl_daily_count_pending_rebuild; apply it with
        usp_load_silv_daily_count @RebuildFrom = <that date> (or
        @FullRebuild = 1) so the day-by-day counts pick the change up.
      * Guarded per column, so the file is safe to run by hand.
====================================================================*/

if not exists (select 1 from sys.columns
               where object_id = object_id('Layercake.silv_member_base')
                 and name = 'recorded_enrolment_date')
    alter table Layercake.silv_member_base
        add recorded_enrolment_date date null;
go

if not exists (select 1 from sys.columns
               where object_id = object_id('Layercake.silv_member_base')
                 and name = 'enrolment_from_subs_history')
    alter table Layercake.silv_member_base
        add enrolment_from_subs_history int not null constraint df_silv_member_base_enr_subs default 0;
go

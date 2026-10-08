/*====================================================================
    20260915_02 - silv_member_base: election backdating columns
    ------------------------------------------------------------------
    WHAT CHANGES
      Two columns are added to Layercake.silv_member_base:
        recorded_election_date     date null
        election_from_subs_history int not null default 0

    WHY
      20260915_01 backdated a recorded ENROLMENT date that sits in a
      later campaign year than the contact's first paid position. The
      same data issue exists for contacts with NO enrolment date and a
      valid ELECTION: the election is then the Join anchor (Join/RPQ,
      or the Change that opens the state range), and derived as
      recorded it landed years after the subs history shows the member
      paying - a "joiner" after several Renewals.

      usp_load_silv_member_base now backdates the election date in
      exactly that case - no enrolment date, and the recorded election
      is in a later campaign year than the first paid one - to the
      first paid year's payment-event date. Where an enrolment date
      exists the election is never moved: the enrolment is the anchor
      and the grade change stays where the source put it. The two
      columns keep the correction visible, as 20260915_01 does for the
      enrolment date; usp_load_silv_data_anomaly reports the cohort as
      ELECTION_AFTER_FIRST_PAID.

    OPERATOR NOTES
      * Shape only. silv_member_base is truncated and rebuilt by every
        silver run, so no backfill: existing rows get the default (0 /
        null) until the next run re-derives them.
      * Runtime: instant (metadata-only ALTERs).
      * A silver reload follows and IS required for the change to take
        effect. The moved Joins change state ranges, so the
        state-ranges module logs the earliest affected date to
        etl_daily_count_pending_rebuild; apply it with
        usp_load_silv_daily_count @RebuildFrom = <that date> (or
        @FullRebuild = 1).
      * Guarded per column, so the file is safe to run by hand.
====================================================================*/

if not exists (select 1 from sys.columns
               where object_id = object_id('Layercake.silv_member_base')
                 and name = 'recorded_election_date')
    alter table Layercake.silv_member_base
        add recorded_election_date date null;
go

if not exists (select 1 from sys.columns
               where object_id = object_id('Layercake.silv_member_base')
                 and name = 'election_from_subs_history')
    alter table Layercake.silv_member_base
        add election_from_subs_history int not null constraint df_silv_member_base_elec_subs default 0;
go

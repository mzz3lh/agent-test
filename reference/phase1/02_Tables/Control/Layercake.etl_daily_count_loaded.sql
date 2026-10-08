/*====================================================================
    Layercake.etl_daily_count_loaded
    Control layer - table, keys and intrinsic indexes
====================================================================*/

-- PER-DATE LOAD TRACKING (02 v9). One row per calendar date whose daily count
-- rows (detail AND main) committed successfully; written inside the chunk's own
-- transaction, so the marker cannot exist without the data or vice versa.
--   * work list         = spine dates <= today with NO row here
--   * resume after fail = the dead run's chunk was never marked
--   * history protection= a marked date is never touched again unless
--                         @RebuildFrom / @FullRebuild clears its marker
-- The current day is deliberately NEVER marked, so it is rebuilt every run.
--
-- NOTE: 02_usp_load_silver_v9.sql seeds this table on FIRST CREATION from the
-- v8 high-water mark. On a blank database there is nothing to seed (silver is
-- empty), so no seed is reproduced here - the first silver run correctly walks
-- the whole spine as its historical backfill.
create table Layercake.etl_daily_count_loaded
(
    [date]     date not null constraint pk_etl_daily_count_loaded primary key clustered,
    loaded_at  datetime2(3) not null constraint df_etl_dcl_at default sysdatetime(),
    run_id     uniqueidentifier null,     -- the run that loaded it
    batch_from date null,                 -- the chunk it was loaded in
    batch_to   date null
);
go

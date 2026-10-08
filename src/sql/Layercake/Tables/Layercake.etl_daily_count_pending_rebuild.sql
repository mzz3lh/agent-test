/*====================================================================
    Layercake.etl_daily_count_pending_rebuild
    Control layer - table, keys and intrinsic indexes
====================================================================*/

-- RETROSPECTIVE CHANGE LOG (02 v9). The daily run does not rebuild history, so
-- a state-range / payment / profile change reaching back into already-loaded
-- dates is recorded here instead. At most ONE OPEN row per source (filtered
-- unique index), holding the EARLIEST affected date since it was last applied.
--   select * from Layercake.etl_daily_count_pending_rebuild where applied_at is null;
--   exec Layercake.usp_load_silver @RebuildFrom = '2025-10-01';
create table Layercake.etl_daily_count_pending_rebuild
(
    pending_id        int identity not null
        constraint pk_etl_dc_pending primary key,
    [source]          varchar(20)  not null,      -- state_ranges | payments | member_profile | enrol_exception
    affected_from     date         not null,      -- earliest ALREADY-LOADED date affected
    detection_count   int          not null constraint df_etl_dc_pending_cnt   default 1,
    first_detected_at datetime2(3) not null constraint df_etl_dc_pending_first default sysdatetime(),
    last_detected_at  datetime2(3) not null constraint df_etl_dc_pending_last  default sysdatetime(),
    last_run_id       uniqueidentifier null,
    detail            nvarchar(400) null,
    applied_at        datetime2(3) null           -- set when a rebuild covered it
);

-- at most one open (unapplied) row per source
create unique nonclustered index ux_etl_dc_pending_open
    on Layercake.etl_daily_count_pending_rebuild ([source])
    where applied_at is null;

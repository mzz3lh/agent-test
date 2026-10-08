/*====================================================================
    Layercake.etl_progress_log
    Control layer - table, keys and intrinsic indexes
====================================================================*/

-- sub-step timings within a run-log step (06)
create table Layercake.etl_progress_log
(
    progress_id   bigint identity not null constraint pk_etl_progress_log primary key clustered,
    log_id        bigint        not null,     -- -> etl_run_log.log_id (the parent step)
    substep       nvarchar(128) not null,
    rows_affected int           null,         -- null = informational mark (no rowcount)
    started_at    datetime2(3)  not null,
    finished_at   datetime2(3)  not null,
    duration_ms   bigint        not null
);

create nonclustered index ix_etl_progress_log_log_id
    on Layercake.etl_progress_log (log_id);
go

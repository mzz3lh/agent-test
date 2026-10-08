/*====================================================================
    Layercake.etl_run_log
    Control layer - table, keys and intrinsic indexes
====================================================================*/

/*====================================================================
    1. CONTROL
    ------------------------------------------------------------------
    Run log (00), sub-step progress log (06) and the three ETL state /
    daily-count tracking tables (02 v8/v9).
====================================================================*/

-- one row per orchestrated step; run_id ties bronze/silver/gold together
create table Layercake.etl_run_log
(
    log_id          bigint identity not null constraint pk_etl_run_log primary key clustered,
    run_id          uniqueidentifier not null,      -- one id per orchestrated run
    layer           varchar(12)  not null,          -- run / bronze / silver / gold
    step_name       varchar(128) not null,          -- usually the target table
    started_at      datetime2(3) not null constraint df_etl_run_log_started default sysdatetime(),
    finished_at     datetime2(3) null,
    status          varchar(10)  not null constraint df_etl_run_log_status default 'Running',  -- Running / Success / Failed
    rows_inserted   int null,
    rows_updated    int null,
    rows_deleted    int null,
    error_message   nvarchar(4000) null
);

create nonclustered index ix_etl_run_log_run_id on Layercake.etl_run_log (run_id);

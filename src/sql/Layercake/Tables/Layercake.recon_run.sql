/*====================================================================
    Layercake.recon_run
    Reconciliation layer - table, keys and intrinsic indexes
====================================================================*/

/*====================================================================
    9. RECONCILIATION - diagnostic tables (owned by 10)
    ------------------------------------------------------------------
    Written by 10_contact_reconciliation.sql. Diagnostics only: nothing
    else reads them, and no foreign keys point at them. 10 drops and
    rebuilds these when its own shape changes (it version-marks on the
    newest column of each), so treat the definitions here as the current
    shape rather than a stable contract.
====================================================================*/

create table Layercake.recon_run
(
    run_id                    uniqueidentifier not null constraint pk_recon_run primary key,
    run_at                    datetime2(3) not null constraint df_recon_run_at default sysdatetime(),
    asof_date                 date not null,
    campaign_year             int  null,
    silver_loaded_through     date null,
    asof_marked_loaded        bit  null,   -- v9 etl_daily_count_loaded
    src_active_rows           int  null,   -- truth query as written (rows)
    src_active_contacts       int  null,   -- ...distinct, non-null contact numbers
    pipe_active_contacts      int  null,   -- pipeline's active membership on asof
    active_in_both            int  null,
    active_source_only        int  null,
    active_pipeline_only      int  null,
    src_paid_rows             int  null,
    src_paid_contacts         int  null,
    pipe_paid_contacts        int  null,
    paid_in_both              int  null,
    paid_source_only          int  null,
    paid_pipeline_only        int  null,
    notes                     nvarchar(400) null
);

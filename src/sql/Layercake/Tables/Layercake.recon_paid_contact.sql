/*====================================================================
    Layercake.recon_paid_contact
    Reconciliation layer - table, keys and intrinsic indexes
====================================================================*/

create table Layercake.recon_paid_contact
(
    run_id                     uniqueidentifier not null,
    contact_no                 nvarchar(200) not null,
    campaign_year              int not null,

    /* ---- source (Subs.vwSubsMemberStatuses, live) ------------------ */
    src_present                bit  not null,
    src_in_truth               bit  not null,
    src_rows_all               int  null,      -- ALL rows for this contact + CY
    src_paid_rows              int  null,      -- ...in a paid invoice position
    src_invoice_position       nvarchar(100) null,  -- the paid position observed
    src_dedupe_winner_position nvarchar(100) null,  -- the position bronze actually keeps
    src_renewal_date           date null,
    src_renewal_date_adj       date null,

    /* ---- bronze ---------------------------------------------------- */
    brz_present                bit  not null,
    brz_is_deleted             bit  null,
    brz_invoice_position       nvarchar(100) null,
    brz_renewal_date_adj       date null,

    /* ---- silver payment events ------------------------------------- */
    pay_present                bit  not null,
    pay_invoice_position       nvarchar(100) null,
    pay_payment_date           date null,
    pay_renewal_date_adj       date null,

    /* ---- the day-by-day paid rule ---------------------------------- */
    renewal_adj_is_null        bit  not null constraint df_rpc_rn default 0,
    renewal_adj_after_asof     bit  not null constraint df_rpc_ra default 0,

    /* ---- the state-range requirement -------------------------------
       A paid contact is counted only where a state range covers the
       as-of date, so every driver exclusion on the ACTIVE side removes
       them from the paid number too. has_cust_trans names the one that
       is invisible on the subs side: an invoice position can say paid
       while the contact has never transacted in cash at all.        */
    has_cust_trans             bit  not null constraint df_rpc_hct default 0,
    has_range_on_asof          bit  not null constraint df_rpc_hr default 0,
    rng_state_on_asof          varchar(12) null,
    rng_count                  int  not null constraint df_rpc_rc default 0,

    counted_paid               bit  not null constraint df_rpc_cp default 0,

    recon_status               varchar(16) not null,
    fail_gate                  varchar(8)  null,      -- P10 .. P99
    gate_seq                   int         null,
    fail_reason                varchar(48) null,
    fail_detail                nvarchar(600) null,

    constraint pk_recon_paid_contact primary key clustered (run_id, contact_no, campaign_year)
);

create nonclustered index ix_recon_paid_status
    on Layercake.recon_paid_contact (run_id, recon_status, gate_seq)
    include (contact_no, fail_reason);

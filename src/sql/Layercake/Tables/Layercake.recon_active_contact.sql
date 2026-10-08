/*====================================================================
    Layercake.recon_active_contact
    Reconciliation layer - table, keys and intrinsic indexes
====================================================================*/

create table Layercake.recon_active_contact
(
    run_id                    uniqueidentifier not null,
    contact_no                nvarchar(200) not null,

    /* ---- source (CE.vwContact, live) ------------------------------ */
    src_present               bit  not null,   -- exists in CE.vwContact at all
    src_in_truth              bit  not null,   -- passes the agreed ACTIVE query
    src_contact_rows          int  null,       -- contact rows sharing this contact no
    src_member_grade          nvarchar(350) null,
    src_lapse_code            nvarchar(100) null,
    src_state_code            int  null,
    src_election_date         date null,
    src_lapsed_date           date null,

    /* ---- bronze --------------------------------------------------- */
    brz_present               bit  not null,
    brz_is_deleted            bit  null,       -- 1 = no ACTIVE bronze row survives
    brz_contact_rows          int  null,       -- active bronze rows on this contact no
    brz_member_grade          nvarchar(350) null,
    brz_lapsed_date           date null,

    /* ---- #mbase driver exclusions --------------------------------- */
    is_test_record            bit  null,       -- EVERY active bronze row is test-flagged
    any_test_record           bit  null,       -- at least one is
    latest_rics_grade         int  null,
    is_student_grade          bit  null,
    has_cust_trans            bit  not null constraint df_rac_hct default 0,  -- any brnz_cust_trans row at all
    cust_trans_rows           int  not null constraint df_rac_ctr default 0,
    mbase_eligible            bit  not null,

    /* ---- latest rics record (brnz_rics_record) --------------------
       The pipeline reads only apuk_membergrade (Student exclusion),
       apuk_lapsecode (lapse REASON name) and apuk_retirementdate from
       this record. apuk_lapseddate is NEVER read - the Lapse event date
       comes from brnz_contact.Rics_LapsedDate - so the two can disagree
       silently. These columns make that visible.                     */
    rr_present                bit  not null constraint df_rac_rrp    default 0,
    rr_lapse_code             int  null,
    rr_lapse_reason           nvarchar(200) null,   -- resolved via silv_ref_lapse_reason
    rr_lapsed_date            date null,
    rr_retirement_date        date null,
    rr_lapse_code_no_date     bit  not null constraint df_rac_rrlcnd default 0,  -- code set, no date anywhere
    rr_lapse_date_no_code     bit  not null constraint df_rac_rrldnc default 0,  -- date set, no code
    rr_lapse_date_not_on_contact bit not null constraint df_rac_rrldnoc default 0, -- rics date, contact date null
    rr_grade_not_member       bit  not null constraint df_rac_rrgnm  default 0,  -- not 200000000/1/2
    no_date_scenario          nvarchar(100) null,   -- Deceased / Duplicate / <lapse reason> - no date to apply

    /* ---- enrolment rows: the part-1 valid-enrolment funnel --------- */
    enr_rows                  int  not null constraint df_rac_enr default 0,
    p1_after_date             int  not null constraint df_rac_p1a default 0,  -- enrolment date not null
    p1_after_route            int  not null constraint df_rac_p1b default 0,  -- route allowlist
    p1_after_apptype          int  not null constraint df_rac_p1c default 0,  -- application-type exclusions
    p1_after_ended            int  not null constraint df_rac_p1d default 0,  -- not ended-without-election
    p1_after_cooloff          int  not null constraint df_rac_p1e default 0,  -- not a 14-day cool-off cancel
    p1_view_parity_rows       int  not null constraint df_rac_p1v default 0,  -- ...also excluding Direct Entry
    p1_min_enrolment_date     date null,
    p1_max_enrolment_date     date null,       -- LATEST qualifying enrolment (silver reads the earliest)

    /* ---- enrolment rows: the part-2 election funnel ---------------- */
    p2_after_election         int  not null constraint df_rac_p2a default 0,  -- election date present
    p2_after_apptype          int  not null constraint df_rac_p2b default 0,  -- 21-type exclusion (nulls out)
    p2_after_route            int  not null constraint df_rac_p2c default 0,  -- not Registered Valuer Top Up
    p2_rows_with_enrolment    int  not null constraint df_rac_p2d default 0,  -- election rows carrying an enrolment date
    p2_min_election_date      date null,
    p2_max_election_date      date null,       -- LATEST qualifying election (silver reads the earliest)
    p2_is_rpq                 bit  null,

    /* ---- 07 exception fallback ------------------------------------ */
    exc_present               bit  not null constraint df_rac_exc  default 0,
    exc_enrolment_used        bit  not null constraint df_rac_excn default 0,
    exc_election_used         bit  not null constraint df_rac_exce default 0,

    /* ---- effective dates as #mbase would compute them -------------- */
    eff_enrolment_date        date null,
    eff_election_date         date null,
    eff_lapsed_date           date null,       -- after the stale-lapse invalidation
    lapse_invalidated         bit  not null constraint df_rac_li default 0,
    predicted_join_branch     varchar(16) null,-- Join/Candidate | Join/RPQ | Change | none

    /* ---- lapse-vs-activity contradictions -------------------------
       silv_member_base tests the contact lapse date against the
       EARLIEST enrolment/election only, so a member who lapsed and then
       re-enrolled keeps the Lapse event when their first enrolment
       predates the lapse. These flags size that, and the equivalent
       contradiction against a payment in the current campaign year. */
    valid_enrolment_after_lapse bit not null constraint df_rac_veal default 0,
    paid_src_current_cy       bit  not null constraint df_rac_pscy default 0,  -- in the source paid truth list
    paid_pipe_current_cy      bit  not null constraint df_rac_ppcy default 0,  -- counted paid by the pipeline
    paid_but_lapsed           bit  not null constraint df_rac_pbl  default 0,  -- paid, yet the covering state is lapse

    /* ---- events ---------------------------------------------------- */
    ev_join_candidate         int  not null constraint df_rac_evjc default 0,
    ev_join_rpq               int  not null constraint df_rac_evjr default 0,
    ev_change                 int  not null constraint df_rac_evch default 0,
    ev_lapse                  int  not null constraint df_rac_evla default 0,
    ev_readmission            int  not null constraint df_rac_evra default 0,
    ev_total                  int  not null constraint df_rac_evto default 0,
    ev_country_unresolved     int  not null constraint df_rac_evcu default 0,

    /* ---- state ranges + the as-of count ---------------------------- */
    rng_count                 int  not null constraint df_rac_rng default 0,
    rng_first_valid_from      date null,
    rng_last_valid_from       date null,
    rng_state_on_asof         varchar(12) null,
    rng_region_on_asof        varchar(12) null,
    rng_seq_on_asof           int  null,
    rng_covering_ranges       int  null,       -- should always be 1
    counted_active            bit  not null constraint df_rac_ca default 0,

    /* ---- anomalies + verdict --------------------------------------- */
    anomaly_types             nvarchar(400) null,
    recon_status              varchar(16) not null,   -- BOTH / SOURCE_ONLY / PIPELINE_ONLY
    fail_gate                 varchar(8)  null,       -- A10 .. A99, X10 .. X99 (pipeline-only)
    gate_seq                  int         null,
    fail_reason               varchar(64) null,
    fail_detail               nvarchar(600) null,

    constraint pk_recon_active_contact primary key clustered (run_id, contact_no)
);

create nonclustered index ix_recon_active_status
    on Layercake.recon_active_contact (run_id, recon_status, gate_seq)
    include (contact_no, fail_reason);

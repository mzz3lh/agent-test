/*====================================================================
    Layercake.silv_member_base
    Silver layer - table, keys and intrinsic indexes
====================================================================*/

/*====================================================================
    6. SILVER - derived tables
====================================================================*/

----------------------------------------------------
--  Layercake.silv_member_base
--  The per-contact base that every other silver derivation reads:
--  effective enrolment/election dates (real rows first, curated
--  ref_enrolment_exception dates as fallback, then the enrolment date
--  backdated to the first paid campaign year where the subs history
--  starts earlier), the lapse state after the stale-date invalidation,
--  and the resolved country / gender / rpq-variant / lapse-reason
--  surrogate keys.
--
--  Shape history:
--    * 20260915_01 - recorded_enrolment_date and
--      enrolment_from_subs_history added for the subs-history
--      backdating: where the recorded enrolment date (real row or 07
--      fallback) sits in a later campaign year than the contact's first
--      paid position in silv_payment_events, enrolment_date is moved to
--      that first paid year and the date the source recorded is kept
--      alongside. Reported as ENROLMENT_AFTER_FIRST_PAID by module 10.
--    * 20260915_02 - recorded_election_date and
--      election_from_subs_history added: the same backdating for a
--      contact with NO enrolment date, whose election is therefore the
--      Join anchor (Join/RPQ, or the Change that opens the range).
--      Reported as ELECTION_AFTER_FIRST_PAID by module 10.
--    * No shape change, meaning widened: the same four columns now also
--      carry a move FORWARD - a recorded date in a campaign year with no
--      paid position, earlier than the first paid one and inside the
--      payment history, is moved to the first paid year (and an election
--      the enrolment moved past is carried with it). recorded > effective
--      = backdated, recorded < effective = moved forward; reported as
--      ENROLMENT_ / ELECTION_BEFORE_FIRST_PAID. The rule and its bound
--      are in usp_load_silv_member_base.
--
--  Owned by 12_modules_silver.sql (usp_load_silv_member_base). It is a
--  full re-derive each run - truncate + insert inside one transaction -
--  and is read by the membership-events, data-anomaly, member-profile
--  and annual-rate-base modules.
--
--  This table is the persisted form of what was the #mbase temp table
--  inside the monolithic usp_load_silver. It exists because a #temp
--  table cannot cross a stored-procedure boundary, and the per-table
--  module split needs those four consumers to read the same derivation
--  without rebuilding it three more times.
--
--  DELIBERATELY NOT UNIQUE ON contact_no: #mbase carried a NON-unique
--  clustered index, and duplicate Rics_contactno values were caught
--  downstream by the #ev_stage primary key and the #prof_stage unique
--  index, which fail the load loudly with a clear message ("fix the
--  duplicate contact, don't silently pick one"). Keeping this index
--  non-unique keeps that failure in the same place with the same
--  diagnostics. Making it unique would surface the problem one module
--  earlier - a reasonable change, but a behaviour change.
----------------------------------------------------
create table Layercake.silv_member_base
(
    contact_id               uniqueidentifier not null,
    contact_no               nvarchar(200) not null,
    enrolment_date           date null,             -- EFFECTIVE enrolment date: earliest clamped real row, else 07 fallback, then moved to the first paid campaign year where that differs (backdated; or forward, inside the payment history only)
    election_date            date null,             -- EFFECTIVE election date: earliest real row, else 07 fallback; moved to the first paid campaign year where there is NO enrolment date (same rule), or carried forward with an enrolment date that moved past it
    is_rpq                   int  not null,         -- from the row supplying the earliest election date
    election_enr_id          uniqueidentifier null, -- ENR ID behind that election (anomaly detail)
    enrolment_from_exception int  not null,         -- 1 = the recorded enrolment date came from ref_enrolment_exception
    election_from_exception  int  not null,         -- 1 = election date came from ref_enrolment_exception
    recorded_enrolment_date  date null,             -- the enrolment date the source recorded (real row or 07 fallback) WHEN it was moved, either direction; null otherwise
    enrolment_from_subs_history int not null constraint df_silv_member_base_enr_subs default 0,   -- 1 = enrolment_date was moved to the first paid campaign year, backdated or forward (recorded_enrolment_date holds the original)
    recorded_election_date   date null,             -- the election date the source recorded (real row or 07 fallback) WHEN it was moved, either direction; null otherwise
    election_from_subs_history int not null constraint df_silv_member_base_elec_subs default 0,  -- 1 = election_date was moved to the first paid campaign year: as the Join anchor (no enrolment date), or carried forward with the enrolment (recorded_election_date holds the original)
    contact_lapsed_date      date null,             -- RAW contact lapse date (stale-lapse anomaly check)
    lapsed_date              date null,             -- ...invalidated if the member re-enrolled/was elected since
    lapse_reason_id          int  not null,         -- -> silv_ref_lapse_reason (0 = Not recorded)
    lapse_reason_name        nvarchar(700) null,    -- carried so the Lapse event subtype needs no re-join
    retirement_date          date null,             -- drives Practising / Retired
    source_enr_id            uniqueidentifier null, -- lineage: row that supplied the earliest qualifying date
    rpq_variant_id           int  not null,         -- -> silv_ref_rpq_variant (0 = N/A)
    country_id               int  not null,         -- -> silv_ref_country (0 = N/A)
    gender_id                int  not null          -- -> silv_ref_gender (0 = N/A)
);

-- non-unique by design - see the note above
create clustered index cx_silv_member_base on Layercake.silv_member_base (contact_no);

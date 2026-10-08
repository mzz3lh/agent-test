/*====================================================================
    Layercake.ref_enrolment_exception
    Silver layer - table, keys and intrinsic indexes
====================================================================*/

-- Gap-fill dates for contacts whose enrolment/election dates are missing from
-- the enrolment source. MAINTAINED BY THE PIPELINE since 20260928_02:
-- Layercake.usp_load_ref_enrolment_exception (silver module 8a) runs on every
-- silver load, immediately before silv_member_base, and is the ONLY thing that
-- writes here.
--
-- The lifecycle it implements, and why each half is the way it is:
--   * CAPTURE IS INSERT-ONLY. A contact captured once keeps the derived
--     history it was captured with, for ever. Nothing re-derives an existing
--     row, so a run can never move a date a count has already been built on.
--   * SUPERSESSION IS A FLAG, NOT A DELETE. When real qualifying rows appear
--     for a captured contact the row is stamped superseded_at rather than
--     removed - deleting would throw away the audit trail of what the counts
--     were built on, and it would change nothing in the derivation, because
--     silv_member_base coalesces these dates in PER DATE with the real row
--     winning. A superseded row is already inert wherever real data covers it,
--     and still fills the gap wherever it does not (a contact who gains a
--     qualifying election but still has no enrolment row keeps the derived
--     enrolment date). superseded_at is CLEARED if the contact stops
--     qualifying again, exactly as silv_data_anomaly re-opens a resolved row.
--   * A row is never hard-deleted by any process. To remove one, do it by
--     hand - it is still a curated table.
--
-- Shape history:
--   * 20260910_01 - the campaign-year audit columns were added when the
--     capture driver moved from the CE contact grade/lapse flags to
--     Subs.vwSubsMemberStatuses evaluated for EVERY campaign year (paid =
--     paid position that year; active = paid that year or the year before),
--     condensed to one row per contact. They record WHY a contact was
--     captured and the span of membership the subs history shows.
create table Layercake.ref_enrolment_exception
(
    contact_no                 nvarchar(200) not null,
    contact_id                 uniqueidentifier not null,
    member_grade               nvarchar(350) null,     -- grade at capture time (context only)
    derived_enrolment_date     date null,              -- Enrolled gap-fill (also carried on Elected rows where a source row supplies it)
    derived_election_date      date null,              -- Elected gap-fill
    enrolment_date_source      varchar(60) null,       -- 'Enrolment row (non-qualifying)' | 'Contact CreatedOn'
    election_date_source       varchar(60) null,       -- 'Enrolment row (non-qualifying)' | 'Rics_ElectionDate' | 'Contact CreatedOn (no election date)'
    has_subs_history           bit not null,           -- any row in Subs.vwSubsMemberStatuses at capture time (always 1 since 20260910_01 - the driver IS that view; kept for the recon scripts)
    -- the condensed per-campaign-year status from the subs view at capture
    -- (all null / 0 = captured before 20260910_01)
    first_active_campaign_year int null,               -- earliest campaign year the contact was active
    last_active_campaign_year  int null,               -- latest campaign year the contact was active (capped at the current year)
    first_paid_campaign_year   int null,               -- earliest campaign year with a paid position
    last_paid_campaign_year    int null,               -- latest campaign year with a paid position
    active_campaign_years      int not null constraint df_ref_enr_exc_active_cys default 0,   -- how many campaign years active
    paid_campaign_years        int not null constraint df_ref_enr_exc_paid_cys   default 0,   -- how many campaign years paid
    is_active_current          bit not null constraint df_ref_enr_exc_active_cur default 0,   -- active in the campaign year current at capture
    is_paid_current            bit not null constraint df_ref_enr_exc_paid_cur   default 0,   -- paid in the campaign year current at capture
    source_enrolment_rows      int not null constraint df_ref_enr_exc_src_rows   default 0,   -- source enrolment rows seen for the contact (0 = no enrolment row at all)
    -- lifecycle (20260928_02)
    superseded_at              datetime2(3) null,      -- stamped when the contact gained a qualifying vw_enrolment_base row; cleared if it loses it again
    superseded_reason          varchar(60) null,       -- 'Qualifying enrolment row' | 'Qualifying election row' | 'Qualifying enrolment + election row'
    _captured_at               datetime2(3) not null constraint df_ref_enr_exc_captured default sysdatetime(),
    _capture_source            varchar(20) not null,   -- 'seed' | 'topup' | 'daily-load'. No default: the one writer always supplies it, so a hand-insert that forgets fails loudly
    _last_seen_at              datetime2(3) not null constraint df_ref_enr_exc_seen default sysdatetime(),   -- last run in which the contact still had NO qualifying row
    constraint pk_ref_enrolment_exception primary key clustered (contact_no),
    constraint ck_ref_enr_exc_cap_src check (_capture_source in ('seed', 'topup', 'daily-load')),
    -- a reason is meaningful only on a superseded row, and vice versa
    constraint ck_ref_enr_exc_superseded check ((superseded_at is null     and superseded_reason is null)
                                            or (superseded_at is not null and superseded_reason is not null)),
    -- a row must fill at least one of the two dates or it does nothing
    constraint ck_ref_enr_exc_has_date check (derived_enrolment_date is not null
                                           or derived_election_date  is not null)
);

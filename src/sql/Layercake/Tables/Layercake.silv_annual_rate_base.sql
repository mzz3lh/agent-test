/*====================================================================
    Layercake.silv_annual_rate_base
    Silver layer - table, keys and intrinsic indexes
====================================================================*/

----------------------------------------------------
--  Layercake.silv_annual_rate_base
--  Segment-level annual counts feeding the DAX rate measures. One row per
--  campaign year per non-zero segment combination. Grain: campaign_year x
--  grade x membership_status x country x gender (region rolls up from
--  country in the Power BI model, so it is NOT a separate key here).
--
--  members_start / members_end  - member-grade snapshots at the 30 Sep
--                                 boundaries (prior / current campaign year)
--  members_joined / _readmitted /
--  _lapsed / _renewed           - event counts within the campaign year
--                                 (members_renewed includes the In-Year
--                                 Readmission renewal subtype)
--
--  [Open with Alex - Renewal Rate 'quoted population' denominator:
--   members_start is the interim proxy.]
--  [Open with Alex - Readmission Rate denominator: which lapsed cohort.]
----------------------------------------------------
create table Layercake.silv_annual_rate_base
(
    campaign_year        int not null,      -- -> ref_campaign_year_config
    grade_id             int not null,      -- -> silv_ref_membership_grade
    membership_status_id int not null,      -- -> silv_ref_membership_status
    country_id           int not null,      -- -> silv_ref_country (region rolls up from here)
    gender_id            int not null,      -- -> silv_ref_gender
    members_start        int not null,
    members_end          int not null,
    members_joined       int not null,
    members_readmitted   int not null,
    members_lapsed       int not null,
    members_renewed      int not null,
    constraint pk_silv_annual_rate_base primary key clustered
        (campaign_year, grade_id, membership_status_id, country_id, gender_id)
);

/*====================================================================
    Layercake.fact_annual_rate_base
    Gold layer - table, keys and intrinsic indexes
====================================================================*/

----------------------------------------------------
--  Layercake.fact_annual_rate_base
--  Straight copy of silv_annual_rate_base - the single reporting-facing
--  source for the Growth / Retention / Renewal / Readmission DAX
--  measures. Power BI connects HERE, never to the silver table, so silver
--  can evolve without moving the model.
--
--  id int identity is the clustered PRIMARY KEY, matching the other star
--  facts. The 5-column segment key is still the business grain and is
--  enforced + made seekable by ux_fact_annual_rate_base_segment - the
--  gold load's diff-sync matches on exactly those columns. The identity
--  id is inert to the load (never referenced, assigned on insert) but
--  gives every row a stable single-column handle.
----------------------------------------------------
create table Layercake.fact_annual_rate_base
(
    id                   int identity not null constraint pk_fact_annual_rate_base primary key clustered,
    campaign_year        int not null,          -- -> dim_campaign_year
    grade_id             int not null,          -- -> dim_membership_grade
    membership_status_id int not null,          -- -> dim_membership_status
    country_id           int not null,          -- -> dim_country (region rolls up from here)
    gender_id            int not null,          -- -> dim_gender
    members_start        int not null,
    members_end          int not null,
    members_joined       int not null,
    members_readmitted   int not null,
    members_lapsed       int not null,
    members_renewed      int not null
);

create unique nonclustered index ux_fact_annual_rate_base_segment
    on Layercake.fact_annual_rate_base
    (campaign_year, grade_id, membership_status_id, country_id, gender_id);

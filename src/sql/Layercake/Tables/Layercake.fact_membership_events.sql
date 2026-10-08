/*====================================================================
    Layercake.fact_membership_events
    Gold layer - table, keys and intrinsic indexes
====================================================================*/

/*====================================================================
    8. GOLD - facts
    ------------------------------------------------------------------
    NOTE: fact_daily_member_count (the old natural-key headline fact) is
    retired and is deliberately NOT in this baseline. The star detail
    fact fact_daily_member_count_detail covers everything it reported -
    the daily headline is SUM(detail), region rolls up from dim_country,
    grade from dim_membership_grade.
====================================================================*/

create table Layercake.fact_membership_events
(
    event_id             int not null constraint pk_fact_membership_events primary key,
    event_type           varchar(20) not null,
    event_subtype        varchar(20) not null,
    event_date           date not null,          -- kept as an attribute: pre-spine events can't resolve via dim_date
    date_id              int not null            -- -> dim_date (0 = pre-spine 'NA' member)
        constraint df_fact_membership_events_date_id default 0,
    contact_no           nvarchar(200) not null,
    grade_id             int not null,          -- -> dim_membership_grade
    assessment_route_id  int not null,          -- -> dim_assessment_route
    rpq_variant_id       int not null,          -- -> dim_rpq_variant
    hpb_id               int not null,
    country_id           int not null,          -- -> dim_country
    gender_id            int not null,          -- -> dim_gender
    membership_status_id int not null,          -- -> dim_membership_status
    campaign_year        int not null,          -- -> dim_campaign_year (kept: pre-spine events)
    campaign_quarter     char(2) not null
);

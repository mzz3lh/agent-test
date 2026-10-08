/*====================================================================
    Gold - foreign keys
    Created WITH CHECK so they are TRUSTED: the optimizer can use them
    for join elimination, and they guarantee every fact key resolves
    (the id-0 'N/A' members make this safe by construction).

    Re-runnable: each constraint is dropped if present and re-added, so
    the deployed constraint is always the one in this file. On a loaded
    database that means one validating pass per constraint per deploy -
    the price of never silently keeping a stale definition.
====================================================================*/

-------------------------------- GOLD --------------------------------

alter table Layercake.fact_membership_events
    drop constraint if exists fk_fact_membership_events_grade;
alter table Layercake.fact_membership_events with check
    add constraint fk_fact_membership_events_grade
    foreign key (grade_id) references Layercake.dim_membership_grade (id);
go

alter table Layercake.fact_membership_events
    drop constraint if exists fk_fact_membership_events_route;
alter table Layercake.fact_membership_events with check
    add constraint fk_fact_membership_events_route
    foreign key (assessment_route_id) references Layercake.dim_assessment_route (id);
go

alter table Layercake.fact_membership_events
    drop constraint if exists fk_fact_membership_events_variant;
alter table Layercake.fact_membership_events with check
    add constraint fk_fact_membership_events_variant
    foreign key (rpq_variant_id) references Layercake.dim_rpq_variant (id);
go

alter table Layercake.fact_membership_events
    drop constraint if exists fk_fact_membership_events_country;
alter table Layercake.fact_membership_events with check
    add constraint fk_fact_membership_events_country
    foreign key (country_id) references Layercake.dim_country (id);
go

alter table Layercake.fact_membership_events
    drop constraint if exists fk_fact_membership_events_gender;
alter table Layercake.fact_membership_events with check
    add constraint fk_fact_membership_events_gender
    foreign key (gender_id) references Layercake.dim_gender (id);
go

alter table Layercake.fact_membership_events
    drop constraint if exists fk_fact_membership_events_status;
alter table Layercake.fact_membership_events with check
    add constraint fk_fact_membership_events_status
    foreign key (membership_status_id) references Layercake.dim_membership_status (id);
go

-- date_id always resolves - enrolment events that legitimately pre-date the
-- spine start (2020-10-01) carry date_id 0, the dim_date 'NA' member. (There
-- is deliberately still NO FK on event_date itself.)
alter table Layercake.fact_membership_events
    drop constraint if exists fk_fact_membership_events_date;
alter table Layercake.fact_membership_events with check
    add constraint fk_fact_membership_events_date
    foreign key (date_id) references Layercake.dim_date (id);
go

-- the star detail fact's full key set. Every key resolves by construction
-- (id-0 N/A members; date_id always comes from a spine date). The date FK's
-- validation and ongoing checks are served by
-- ix_fact_daily_member_count_detail_date_id.
alter table Layercake.fact_daily_member_count_detail
    drop constraint if exists fk_fact_daily_detail_date;
alter table Layercake.fact_daily_member_count_detail with check
    add constraint fk_fact_daily_detail_date
    foreign key (date_id) references Layercake.dim_date (id);
go

alter table Layercake.fact_daily_member_count_detail
    drop constraint if exists fk_fact_daily_detail_country;
alter table Layercake.fact_daily_member_count_detail with check
    add constraint fk_fact_daily_detail_country
    foreign key (country_id) references Layercake.dim_country (id);
go

alter table Layercake.fact_daily_member_count_detail
    drop constraint if exists fk_fact_daily_detail_gender;
alter table Layercake.fact_daily_member_count_detail with check
    add constraint fk_fact_daily_detail_gender
    foreign key (gender_id) references Layercake.dim_gender (id);
go

alter table Layercake.fact_daily_member_count_detail
    drop constraint if exists fk_fact_daily_detail_grade;
alter table Layercake.fact_daily_member_count_detail with check
    add constraint fk_fact_daily_detail_grade
    foreign key (membership_grade_id) references Layercake.dim_membership_grade (id);
go

alter table Layercake.fact_daily_member_count_detail
    drop constraint if exists fk_fact_daily_detail_status;
alter table Layercake.fact_daily_member_count_detail with check
    add constraint fk_fact_daily_detail_status
    foreign key (membership_status_id) references Layercake.dim_membership_status (id);
go

-- annual rate base fact segment keys. Every FK check on this fact is served
-- by ux_fact_annual_rate_base_segment (leads on campaign_year) or is a small
-- dim scan - the fact is tiny (segments x campaign years), so no per-FK-column
-- indexes are needed.
alter table Layercake.fact_annual_rate_base
    drop constraint if exists fk_fact_annual_rate_base_year;
alter table Layercake.fact_annual_rate_base with check
    add constraint fk_fact_annual_rate_base_year
    foreign key (campaign_year) references Layercake.dim_campaign_year (campaign_year);
go

alter table Layercake.fact_annual_rate_base
    drop constraint if exists fk_fact_annual_rate_base_grade;
alter table Layercake.fact_annual_rate_base with check
    add constraint fk_fact_annual_rate_base_grade
    foreign key (grade_id) references Layercake.dim_membership_grade (id);
go

alter table Layercake.fact_annual_rate_base
    drop constraint if exists fk_fact_annual_rate_base_status;
alter table Layercake.fact_annual_rate_base with check
    add constraint fk_fact_annual_rate_base_status
    foreign key (membership_status_id) references Layercake.dim_membership_status (id);
go

alter table Layercake.fact_annual_rate_base
    drop constraint if exists fk_fact_annual_rate_base_country;
alter table Layercake.fact_annual_rate_base with check
    add constraint fk_fact_annual_rate_base_country
    foreign key (country_id) references Layercake.dim_country (id);
go

alter table Layercake.fact_annual_rate_base
    drop constraint if exists fk_fact_annual_rate_base_gender;
alter table Layercake.fact_annual_rate_base with check
    add constraint fk_fact_annual_rate_base_gender
    foreign key (gender_id) references Layercake.dim_gender (id);
go

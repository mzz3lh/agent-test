/*====================================================================
    Silver - foreign keys
    Created WITH CHECK so they are TRUSTED: the optimizer can use them
    for join elimination, and they guarantee every fact key resolves
    (the id-0 'N/A' members make this safe by construction).

    Re-runnable: each constraint is dropped if present and re-added, so
    the deployed constraint is always the one in this file. On a loaded
    database that means one validating pass per constraint per deploy -
    the price of never silently keeping a stale definition.
====================================================================*/

/*====================================================================
    11. FOREIGN KEYS  (from 05)
    ------------------------------------------------------------------
    Created WITH CHECK so they are TRUSTED: the optimizer can use them
    for join elimination, and they guarantee every fact key resolves
    (the id-0 'N/A' members make this safe by construction). Dims and
    silver refs are never deleted by the load procs, so the constraints
    never block the daily run.

    On a blank database these validate instantly (no rows). If you are
    adding them to a loaded database, expect one validating pass per
    constraint.
====================================================================*/

------------------------------- SILVER -------------------------------

alter table Layercake.silv_membership_events
    drop constraint if exists fk_silv_membership_events_grade;
alter table Layercake.silv_membership_events with check
    add constraint fk_silv_membership_events_grade
    foreign key (grade_id) references Layercake.silv_ref_membership_grade (id);
go

alter table Layercake.silv_membership_events
    drop constraint if exists fk_silv_membership_events_route;
alter table Layercake.silv_membership_events with check
    add constraint fk_silv_membership_events_route
    foreign key (assessment_route_id) references Layercake.silv_ref_assessment_route (id);
go

alter table Layercake.silv_membership_events
    drop constraint if exists fk_silv_membership_events_variant;
alter table Layercake.silv_membership_events with check
    add constraint fk_silv_membership_events_variant
    foreign key (rpq_variant_id) references Layercake.silv_ref_rpq_variant (id);
go

alter table Layercake.silv_membership_events
    drop constraint if exists fk_silv_membership_events_country;
alter table Layercake.silv_membership_events with check
    add constraint fk_silv_membership_events_country
    foreign key (country_id) references Layercake.silv_ref_country (id);
go

alter table Layercake.silv_membership_events
    drop constraint if exists fk_silv_membership_events_gender;
alter table Layercake.silv_membership_events with check
    add constraint fk_silv_membership_events_gender
    foreign key (gender_id) references Layercake.silv_ref_gender (id);
go

alter table Layercake.silv_membership_events
    drop constraint if exists fk_silv_membership_events_status;
alter table Layercake.silv_membership_events with check
    add constraint fk_silv_membership_events_status
    foreign key (membership_status_id) references Layercake.silv_ref_membership_status (id);
go

-- daily counts can only exist for spine dates
alter table Layercake.silv_daily_count
    drop constraint if exists fk_silv_daily_count_date;
alter table Layercake.silv_daily_count with check
    add constraint fk_silv_daily_count_date
    foreign key ([date]) references Layercake.ref_date_spine ([date]);
go

-- annual rate base segment keys
alter table Layercake.silv_annual_rate_base
    drop constraint if exists fk_silv_annual_rate_base_year;
alter table Layercake.silv_annual_rate_base with check
    add constraint fk_silv_annual_rate_base_year
    foreign key (campaign_year) references Layercake.ref_campaign_year_config (campaign_year);
go

alter table Layercake.silv_annual_rate_base
    drop constraint if exists fk_silv_annual_rate_base_grade;
alter table Layercake.silv_annual_rate_base with check
    add constraint fk_silv_annual_rate_base_grade
    foreign key (grade_id) references Layercake.silv_ref_membership_grade (id);
go

alter table Layercake.silv_annual_rate_base
    drop constraint if exists fk_silv_annual_rate_base_status;
alter table Layercake.silv_annual_rate_base with check
    add constraint fk_silv_annual_rate_base_status
    foreign key (membership_status_id) references Layercake.silv_ref_membership_status (id);
go

alter table Layercake.silv_annual_rate_base
    drop constraint if exists fk_silv_annual_rate_base_country;
alter table Layercake.silv_annual_rate_base with check
    add constraint fk_silv_annual_rate_base_country
    foreign key (country_id) references Layercake.silv_ref_country (id);
go

alter table Layercake.silv_annual_rate_base
    drop constraint if exists fk_silv_annual_rate_base_gender;
alter table Layercake.silv_annual_rate_base with check
    add constraint fk_silv_annual_rate_base_gender
    foreign key (gender_id) references Layercake.silv_ref_gender (id);
go

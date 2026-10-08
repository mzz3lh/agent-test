/*====================================================================
    Static reference seed data
    Post-deployment DML - the id-0 'N/A' members that make every
    foreign key resolve, plus the fixed gender and status lists.

    NOTE: unlike the object scripts, the guards here are DELIBERATELY
    RETAINED. This is DML, not DDL - a second run must not duplicate
    the rows. Every statement below is safe to re-run.
====================================================================*/

/*====================================================================
    Inserted once, never reloaded. Every reference table gets id 0 =
    'N/A' so facts can always inner join and every foreign key
    resolves by construction.

    LAPSED IS NOT A GRADE - AND NOT A STATUS EITHER. Lapsing is purely a
    lifecycle EVENT (the Lapse rows of fact_membership_events) and appears
    in NO dimension. Grades are Candidate / Qualified (+ id 0 N/A);
    statuses are Practising / Retired (+ id 0 N/A). Gold maps silver
    'lapse' daily rows to grade N/A + status N/A.
====================================================================*/

if not exists (select 1 from Layercake.silv_ref_membership_grade where id = 0)
begin
    set identity_insert Layercake.silv_ref_membership_grade on;
    insert into Layercake.silv_ref_membership_grade (id, grade_name) values (0, 'N/A');
    set identity_insert Layercake.silv_ref_membership_grade off;
end

insert into Layercake.silv_ref_membership_grade (grade_name)
select v.grade_name
from (values ('Candidate'), ('Qualified')) v(grade_name)
where not exists (select 1 from Layercake.silv_ref_membership_grade g where g.grade_name = v.grade_name);
go

if not exists (select 1 from Layercake.silv_ref_assessment_route where id = 0)
begin
    set identity_insert Layercake.silv_ref_assessment_route on;
    insert into Layercake.silv_ref_assessment_route (id, route_code, route_name) values (0, 0, 'N/A');
    set identity_insert Layercake.silv_ref_assessment_route off;
end
go

if not exists (select 1 from Layercake.silv_ref_rpq_variant where id = 0)
begin
    set identity_insert Layercake.silv_ref_rpq_variant on;
    insert into Layercake.silv_ref_rpq_variant (id, variant_id, variant_name)
    values (0, '00000000-0000-0000-0000-000000000000', 'N/A');
    set identity_insert Layercake.silv_ref_rpq_variant off;
end
go

if not exists (select 1 from Layercake.silv_ref_country where id = 0)
begin
    set identity_insert Layercake.silv_ref_country on;
    insert into Layercake.silv_ref_country (id, country_id, country_name, region_name, market_reporting_region)
    values (0, '00000000-0000-0000-0000-000000000000', 'N/A', 'N/A', 'N/A');
    set identity_insert Layercake.silv_ref_country off;
end
go

-- static list - CE gender option set codes
if not exists (select 1 from Layercake.silv_ref_gender where id = 0)
begin
    set identity_insert Layercake.silv_ref_gender on;
    insert into Layercake.silv_ref_gender (id, gender_code, gender_name)
    values
    (0, 0,         'Not stated'),
    (1, 1,         'Male'),
    (2, 2,         'Female'),
    (3, 200000002, 'I use another term'),
    (4, 200000001, 'zz_Prefer to Self-Describe'),
    (5, 192350001, 'zz_Unknown'),
    (6, 200000000, 'I prefer not to say');
    set identity_insert Layercake.silv_ref_gender off;
end
go

if not exists (select 1 from Layercake.silv_ref_membership_status where id = 0)
begin
    set identity_insert Layercake.silv_ref_membership_status on;
    insert into Layercake.silv_ref_membership_status (id, status_name)
    values (0, 'N/A'), (1, 'Practising'), (2, 'Retired');
    set identity_insert Layercake.silv_ref_membership_status off;
end
go

-- lapse reason N/A member. Real codes are loaded by usp_load_silver.
if not exists (select 1 from Layercake.silv_ref_lapse_reason where id = 0)
begin
    set identity_insert Layercake.silv_ref_lapse_reason on;
    insert into Layercake.silv_ref_lapse_reason (id, lapse_code, reason_name) values (0, 0, 'Not recorded');
    set identity_insert Layercake.silv_ref_lapse_reason off;
end
go

-- the dim_date 'NA' member. Events that legitimately pre-date the spine
-- start carry date_id 0 and resolve here.
if not exists (select 1 from Layercake.dim_date where id = 0)
begin
    set identity_insert Layercake.dim_date on;
    insert into Layercake.dim_date (id, [date], [campaign_year], [campaign_quarter])
    values (0, '19000101', 0, 'NA');
    set identity_insert Layercake.dim_date off;
end
go

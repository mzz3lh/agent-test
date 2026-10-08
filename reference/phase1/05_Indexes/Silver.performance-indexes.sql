/*====================================================================
    Silver - performance indexes
    Supporting indexes that are NOT part of any table's key design
    (those live with their table). Safe to defer until after the
    first full load, which is when they build most cheaply.

    Re-runnable: every index is dropped if present and rebuilt, so what
    ends up in the database is always what is in this file - editing a
    definition here is enough to change it on the next deploy. The cost
    is that a redeploy against a loaded database rebuilds these indexes
    rather than skipping them.
====================================================================*/

-------------------------------- SILVER --------------------------------

-- the daily-count window joins spine dates into [valid_from, valid_to] ranges;
-- a seek on valid_from <= date prunes most ranges, and the includes make it
-- covering so the (potentially large) range join never touches the base table
drop index if exists ix_silv_member_state_ranges_dates
    on Layercake.silv_member_state_ranges;
create nonclustered index ix_silv_member_state_ranges_dates
    on Layercake.silv_member_state_ranges (valid_from, valid_to)
    include (contact_no, grade, region, campaign_year_from);
go

-- the annual rate base groups the events table by the full segment key; this
-- covering index lets that aggregation run without touching the base table
drop index if exists ix_silv_membership_events_segment
    on Layercake.silv_membership_events;
create nonclustered index ix_silv_membership_events_segment
    on Layercake.silv_membership_events (campaign_year, grade_id, membership_status_id, country_id, gender_id)
    include (event_type);
go

-- the event-driven paid count reads the events per contact per campaign year -
-- module 13 stages them once per run (a scan either way), but the C6d
-- reconciliation check and the single-contact drill-downs seek one contact at a
-- time, and event_date is included so neither has to touch the base table
drop index if exists ix_silv_membership_events_contact_cy
    on Layercake.silv_membership_events;
create nonclustered index ix_silv_membership_events_contact_cy
    on Layercake.silv_membership_events (contact_no, campaign_year, event_type)
    include (event_date);
go

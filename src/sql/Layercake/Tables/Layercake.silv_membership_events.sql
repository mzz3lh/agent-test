/*====================================================================
    Layercake.silv_membership_events
    Silver layer - table, keys and intrinsic indexes
====================================================================*/

----------------------------------------------------
--  Layercake.silv_membership_events
--  All five lifecycle event types (Join, Change, Lapse, Readmission,
--  Renewal). Because Lapse/Renewal/Readmission/Change events do not come
--  from a single enrolment record, the incremental diff key is event_nk,
--  a deterministic natural key built per event type (see 02). event_id is
--  stable across runs; source_enr_id stays as informational lineage for
--  Join events only.
----------------------------------------------------
create table Layercake.silv_membership_events
(
    event_id             int identity not null constraint pk_silv_membership_events primary key,
    event_nk             nvarchar(220) not null,        -- incremental diff key
    event_type           varchar(20) not null,          -- Join / Change / Lapse / Readmission / Renewal
    event_subtype        varchar(20) not null,
    event_date           date not null,
    source_enr_id        uniqueidentifier null,         -- Join events only
    contact_no           nvarchar(200) not null,
    grade_id             int not null,
    assessment_route_id  int not null,
    rpq_variant_id       int not null,
    hpb_id               int not null,
    country_id           int not null,
    gender_id            int not null,
    membership_status_id int not null,
    campaign_year        int not null,
    campaign_quarter     char(2) not null
);

-- primary incremental diff key
create unique nonclustered index ux_silv_membership_events_nk
    on Layercake.silv_membership_events (event_nk);

-- guards Join-event uniqueness (one Join event per enrolment record;
-- Join events are per contact and JC/JR are mutually exclusive per contact)
create unique nonclustered index ux_silv_membership_events_enr
    on Layercake.silv_membership_events (source_enr_id)
    where source_enr_id is not null;

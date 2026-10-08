/*====================================================================
    Layercake.fact_daily_member_count_detail
    Gold layer - table, keys and intrinsic indexes
====================================================================*/

----------------------------------------------------
--  Layercake.fact_daily_member_count_detail  (star detail fact)
--  Every key a dim surrogate; identity id kept as a NONCLUSTERED pk, and
--  the natural star grain is the unique CLUSTERED index so the window
--  diff/delete/insert works off a single date_id-leading b-tree.
--
--  PaidMembers vs PaidMembersEvent are two independent readings of the
--  same question, carried side by side so a report can show either or
--  compare them (see silv_daily_count_detail for the rules):
--    PaidMembers      - payment-driven: a paid subs position for the
--                       campaign year, dated on or before the day.
--    PaidMembersEvent - event-driven: Join + Renewal + Readmission,
--                       accumulated from each 1 October. Lapsing does
--                       not deduct.
--  JoinEvents / RenewalEvents / ReadmissionEvents are the daily flows
--  PaidMembersEvent is built from - additive over any date range, and a
--  running total of them reproduces PaidMembersEvent. LapseEvents is
--  reported alongside rather than netted off: members who had paid this
--  campaign year and then lapsed.
----------------------------------------------------
create table Layercake.fact_daily_member_count_detail
(
    id                   int identity not null
        constraint pk_fact_daily_member_count_detail primary key nonclustered,
    date_id              int not null,    -- -> dim_date
    country_id           int not null,    -- -> dim_country (region rolls up here)
    gender_id            int not null,    -- -> dim_gender
    membership_grade_id  int not null,    -- -> dim_membership_grade (0 = N/A - incl. daily lapse rows; lapse is event-only)
    membership_status_id int not null,    -- -> dim_membership_status (Practising/Retired; 0 = N/A - incl. daily lapse rows)
    ActiveMembers        int not null,
    PaidMembers          int not null,    -- payment-driven (original)
    PaidMembersEvent     int not null,    -- event-driven (stock)
    JoinEvents           int not null,    -- event-driven components (daily flow)
    RenewalEvents        int not null,
    ReadmissionEvents    int not null,
    LapseEvents          int not null    -- reported, not deducted from PaidMembersEvent
);

create unique clustered index cx_fact_daily_member_count_detail
    on Layercake.fact_daily_member_count_detail
    (date_id, country_id, gender_id, membership_grade_id, membership_status_id);

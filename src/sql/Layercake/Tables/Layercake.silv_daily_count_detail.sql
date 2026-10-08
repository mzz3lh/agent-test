/*====================================================================
    Layercake.silv_daily_count_detail
    Silver layer - table, keys and intrinsic indexes
====================================================================*/

----------------------------------------------------
--  Layercake.silv_daily_count_detail
--  The main daily count at the finer grain
--  [date] x region x country x gender x grade x membership status.
--  Feeds gold fact_daily_member_count_detail. silv_daily_count is derived
--  from this table (SUM over country/gender/status), so the two always
--  reconcile. Date-leading clustered PK keeps the per-chunk delete +
--  re-insert cheap and idempotent.
--
--  TWO PAID MEASURES, side by side and deliberately not reconciled:
--    paid_count       - PAYMENT-driven. A payment event for the campaign
--                       year with an adjusted renewal date on or before
--                       the day. The original measure, unchanged.
--    paid_count_event - EVENT-driven. Built from silv_membership_events:
--                       paid from the campaign year's earliest Join /
--                       Renewal / Readmission, and counted for the rest
--                       of that year. Resets each 1 October. Lapsing
--                       does NOT deduct.
--  event_join_count / _renewal_ / _readmission_ are the daily FLOWS
--  behind paid_count_event - a running total of them from the campaign
--  year start reproduces it exactly at the day level.
--  event_lapse_count is reported ALONGSIDE, not netted off: the
--  contacts who had paid in this campaign year and then lapsed that day.
----------------------------------------------------
create table Layercake.silv_daily_count_detail
(
    [date]                  date not null,
    campaign_year           int not null,
    campaign_quarter        char(2) not null,
    region                  varchar(12) not null,   -- RANGE region (same as silv_daily_count)
    country_id              int not null,           -- -> silv_ref_country (contact's CURRENT country)
    gender_id               int not null,           -- -> silv_ref_gender
    grade                   varchar(12) not null,   -- enrolment, election, lapse
    membership_status_id    int not null,           -- -> silv_ref_membership_status (0 = N/A outside 'election')
    active_count            int not null,
    paid_count              int not null,           -- payment-driven (original)
    paid_count_event        int not null,           -- event-driven (stock)
    event_join_count        int not null,           -- event-driven components (daily flow)
    event_renewal_count     int not null,
    event_readmission_count int not null,
    event_lapse_count       int not null,           -- reported, not deducted - see the module header
    constraint pk_silv_daily_count_detail primary key clustered
        ([date], region, country_id, gender_id, grade, membership_status_id)
);

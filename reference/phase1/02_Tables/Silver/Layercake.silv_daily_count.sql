/*====================================================================
    Layercake.silv_daily_count
    Silver layer - table, keys and intrinsic indexes
====================================================================*/

----------------------------------------------------
--  Layercake.silv_daily_count
--  ([date], region, grade) is the natural grain and the clustered PK, so
--  a date window can be deleted + re-inserted idempotently.
--  Both paid measures and the event components are plain SUMs over
--  silv_daily_count_detail - see that table's header for what they mean.
----------------------------------------------------
create table Layercake.silv_daily_count
(
    [date]                  date not null,
    campaign_year           int not null,
    campaign_quarter        char(2) not null,
    region                  varchar(12) not null,
    grade                   varchar(12) not null,   -- enrolment, election, lapse
    active_count            int not null,
    paid_count              int not null,           -- payment-driven (original)
    paid_count_event        int not null,           -- event-driven (stock)
    event_join_count        int not null,           -- event-driven components (daily flow)
    event_renewal_count     int not null,
    event_readmission_count int not null,
    event_lapse_count       int not null,           -- reported, not deducted
    constraint pk_silv_daily_count primary key clustered ([date], region, grade)
);
go

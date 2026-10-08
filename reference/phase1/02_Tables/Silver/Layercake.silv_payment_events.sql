/*====================================================================
    Layercake.silv_payment_events
    Silver layer - table, keys and intrinsic indexes
====================================================================*/

----------------------------------------------------
--  Layercake.silv_payment_events
----------------------------------------------------
create table Layercake.silv_payment_events
(
    contact_no       nvarchar(200) not null,
    campaign_year    int not null,
    payment_date     date null,          -- first cash transaction date from custtrans (informational)
    renewal_date_adj date null,          -- adjusted renewal date - always within the campaign year; drives the day-by-day paid logic
    invoice_position nvarchar(64) null,
    payment_source   nvarchar(64) not null constraint df_silv_payment_events_src default N'Individual',
    constraint pk_silv_payment_events primary key clustered (contact_no, campaign_year)
);
go

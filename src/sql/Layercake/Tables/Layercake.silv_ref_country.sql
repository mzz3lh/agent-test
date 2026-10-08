/*====================================================================
    Layercake.silv_ref_country
    Silver layer - table, keys and intrinsic indexes
====================================================================*/

create table Layercake.silv_ref_country
(
    id                      int identity not null constraint pk_silv_ref_country primary key,
    country_id              uniqueidentifier not null,
    country_name            nvarchar(200) not null,
    region_name             nvarchar(200) not null,
    market_reporting_region varchar(15) not null,
    constraint uq_silv_ref_country unique (country_id)
);

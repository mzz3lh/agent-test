/*====================================================================
    Layercake.dim_country
    Gold layer - table, keys and intrinsic indexes
====================================================================*/

create table Layercake.dim_country
(
    id                      int not null constraint pk_dim_country primary key,
    country_id              uniqueidentifier not null,
    country_name            nvarchar(200) not null,
    region_name             nvarchar(200) not null,
    market_reporting_region varchar(15) not null
);

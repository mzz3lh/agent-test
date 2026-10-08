/*====================================================================
    Layercake.dim_campaign_year
    Gold layer - table, keys and intrinsic indexes
====================================================================*/

-- exposes the configurable bulk lapse date to the model
create table Layercake.dim_campaign_year
(
    campaign_year       int not null constraint pk_dim_campaign_year primary key,
    campaign_year_start date not null,
    campaign_year_end   date not null,
    bulk_lapse_date     date not null
);

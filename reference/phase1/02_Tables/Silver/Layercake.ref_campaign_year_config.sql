/*====================================================================
    Layercake.ref_campaign_year_config
    Silver layer - table, keys and intrinsic indexes
====================================================================*/

-- Bulk lapse date as configurable DATA: 1 June for campaign years up to and
-- including CY2025, 1 May from CY2026 onwards. Plus the Oct-Sep campaign year
-- boundaries. Extended (insert-only) by usp_load_silver alongside the spine.
-- [Confirm the CY2026 changeover explicitly with Alex before go-live.]
create table Layercake.ref_campaign_year_config
(
    campaign_year       int not null constraint pk_ref_campaign_year_config primary key,
    campaign_year_start date not null,     -- 1 Oct of the prior calendar year
    campaign_year_end   date not null,     -- 30 Sep
    bulk_lapse_date     date not null
);
go

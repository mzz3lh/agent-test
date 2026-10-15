/*====================================================================
    Layercake.fact_contact_payment
    Contact payment dataset (DES-001, SPEC-001)
====================================================================*/

/*====================================================================
    One row per FO payment transaction, rebuilt in full on every run by
    Layercake.usp_load_fact_contact_payment from
    Layercake.vw_fact_contact_payment_source (ADR-001). Amounts keep
    FO's six decimal places (Q-023). No foreign keys: country, region
    and market are held as names, as the spec maps them.
====================================================================*/
CREATE TABLE Layercake.fact_contact_payment (
    legal_entity nvarchar(4) NOT NULL,
    fo_transaction_recid bigint NOT NULL,
    account_number nvarchar(20) NULL,
    contact_number nvarchar(100) NULL,
    is_corporate bit NOT NULL,
    payment_date date NULL,
    payment_year int NULL,
    payment_month tinyint NULL,
    amount_paid_currency decimal(32, 6) NULL,
    currency_code nvarchar(3) NULL,
    amount_paid_gbp decimal(32, 6) NULL,
    payment_method_code nvarchar(10) NOT NULL,
    payment_method nvarchar(60) NOT NULL,
    country_name nvarchar(200) NOT NULL,
    region_name nvarchar(200) NOT NULL,
    market_reporting_region varchar(15) NOT NULL,
    run_id uniqueidentifier NOT NULL,
    created_at datetime2(3) NOT NULL,
    updated_at datetime2(3) NOT NULL,
    CONSTRAINT PK_Layercake_fact_contact_payment PRIMARY KEY CLUSTERED (legal_entity, fo_transaction_recid)
);

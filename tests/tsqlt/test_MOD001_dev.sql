EXEC tSQLt.NewTestClass 'test_MOD001_dev';
GO

CREATE PROCEDURE test_MOD001_dev.[SetUp]
AS
BEGIN
    EXEC tSQLt.FakeTable 'synapse_fo.CUSTTRANS';
    EXEC tSQLt.FakeTable 'synapse_fo.CUSTPAYMMODETABLE';
    EXEC tSQLt.FakeTable 'CE.tblContact_Test_Records';
    EXEC tSQLt.FakeTable 'Layercake.brnz_contact';
    EXEC tSQLt.FakeTable 'Layercake.dim_country';
END;
GO

CREATE PROCEDURE test_MOD001_dev.[test duplicate payment mode rows give one row named from the lowest RECID]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTPAYMMODETABLE (DATAAREAID, PARTITION, RECID, PAYMMODE, NAME)
    VALUES (N'gb01', 2, 502, N'DD', N'Second name'),
           (N'gb01', 1, 501, N'DD', N'First name');

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTMST, PAYMMODE, TRANSDATE)
    VALUES (N'gb01', 90001, N'ACME01', 15, -10.00, N'DD', '2024-01-10');

    SELECT fo_transaction_recid, payment_method_code, payment_method
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, payment_method_code, payment_method
    INTO #Expected
    FROM (VALUES (CAST(90001 AS bigint), N'DD', N'First name')) AS v(fo_transaction_recid, payment_method_code, payment_method);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001_dev.[test duplicate country_id in dim_country gives one row from the lowest id]
AS
BEGIN
    INSERT INTO Layercake.dim_country (id, country_id, country_name, region_name, market_reporting_region)
    VALUES (7, 'F0000000-0000-0000-0000-000000000001', N'France (old)', N'Old region', 'OLD'),
           (3, 'F0000000-0000-0000-0000-000000000001', N'France', N'Europe', 'EMEA');

    INSERT INTO Layercake.brnz_contact (ContactId, Rics_contactno, rics_countryid, [_is_deleted])
    VALUES ('C0000000-0000-0000-0000-000000000901', N'C100001', 'F0000000-0000-0000-0000-000000000001', 0);

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTMST, TRANSDATE)
    VALUES (N'gb01', 90002, N'C100001', 15, -10.00, '2024-01-10');

    SELECT fo_transaction_recid, country_name, region_name, market_reporting_region
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, country_name, region_name, market_reporting_region
    INTO #Expected
    FROM (VALUES (CAST(90002 AS bigint), N'France', N'Europe', 'EMEA')) AS v(fo_transaction_recid, country_name, region_name, market_reporting_region);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001_dev.[test document date on cutoff day with a time of day uses transaction date]
AS
BEGIN
    -- vwCustTrans compares the datetime with '2021-08-23' (midnight), so
    -- a later time on that day is after the cutoff (test design sign-off).
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTMST, DOCUMENTDATE, TRANSDATE)
    VALUES (N'gb01', 90003, N'ACME01', 15, -10.00, '2021-08-23T10:30:00', '2021-09-01'),
           (N'gb01', 90004, N'ACME01', 15, -10.00, '2021-08-22T23:59:00', '2021-09-01');

    SELECT fo_transaction_recid, payment_date, payment_year, payment_month
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, payment_date, payment_year, payment_month
    INTO #Expected
    FROM (VALUES (CAST(90003 AS bigint), CAST('2021-09-01' AS date), 2021, CAST(9 AS tinyint)),
                 (CAST(90004 AS bigint), CAST('2021-08-22' AS date), 2021, CAST(8 AS tinyint)))
         AS v(fo_transaction_recid, payment_date, payment_year, payment_month);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001_dev.[test shared contact number with one deleted and two current contacts uses lowest current ContactId]
AS
BEGIN
    INSERT INTO Layercake.dim_country (id, country_id, country_name, region_name, market_reporting_region)
    VALUES (1, 'F0000000-0000-0000-0000-000000000001', N'France', N'Europe', 'EMEA'),
           (2, 'F0000000-0000-0000-0000-000000000002', N'Germany', N'Europe', 'EMEA'),
           (3, 'F0000000-0000-0000-0000-000000000003', N'Spain', N'Europe', 'EMEA');

    INSERT INTO Layercake.brnz_contact (ContactId, Rics_contactno, rics_countryid, [_is_deleted])
    VALUES ('C0000000-0000-0000-0000-000000000001', N'C100003', 'F0000000-0000-0000-0000-000000000003', 1),
           ('C0000000-0000-0000-0000-000000000003', N'C100003', 'F0000000-0000-0000-0000-000000000001', 0),
           ('C0000000-0000-0000-0000-000000000002', N'C100003', 'F0000000-0000-0000-0000-000000000002', 0);

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTMST, TRANSDATE)
    VALUES (N'gb01', 90005, N'C100003', 15, -10.00, '2024-01-10');

    SELECT fo_transaction_recid, is_corporate, contact_number, country_name
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, is_corporate, contact_number, country_name
    INTO #Expected
    FROM (VALUES (CAST(90005 AS bigint), CAST(0 AS bit), N'C100003', N'Germany')) AS v(fo_transaction_recid, is_corporate, contact_number, country_name);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001_dev.[test payment mode with a name of spaces in another entity still uses its own entity name]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTPAYMMODETABLE (DATAAREAID, PARTITION, RECID, PAYMMODE, NAME)
    VALUES (N'gb01', 1, 601, N'CHQ', N'   '),
           (N'us01', 1, 602, N'CHQ', N'Check');

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTMST, PAYMMODE, TRANSDATE)
    VALUES (N'gb01', 90006, N'ACME01', 15, -10.00, N'CHQ', '2024-01-10'),
           (N'us01', 90007, N'ACME02', 15, -10.00, N'CHQ', '2024-01-10');

    SELECT legal_entity, fo_transaction_recid, payment_method_code, payment_method
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT legal_entity, fo_transaction_recid, payment_method_code, payment_method
    INTO #Expected
    FROM (VALUES (N'gb01', CAST(90006 AS bigint), N'CHQ', N'CHQ'),
                 (N'us01', CAST(90007 AS bigint), N'CHQ', N'Check'))
         AS v(legal_entity, fo_transaction_recid, payment_method_code, payment_method);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

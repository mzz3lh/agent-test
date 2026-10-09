EXEC tSQLt.NewTestClass 'test_MOD001';
GO

CREATE PROCEDURE test_MOD001.[SetUp]
AS
BEGIN
    EXEC tSQLt.FakeTable 'synapse_fo.CUSTTRANS';
    EXEC tSQLt.FakeTable 'synapse_fo.CUSTPAYMMODETABLE';
    EXEC tSQLt.FakeTable 'CE.tblContact_Test_Records';
    EXEC tSQLt.FakeTable 'Layercake.brnz_contact';
    EXEC tSQLt.FakeTable 'Layercake.dim_country';

    INSERT INTO Layercake.dim_country (id, country_id, country_name, region_name, market_reporting_region)
    VALUES (1, 'F0000000-0000-0000-0000-000000000001', N'France', N'Europe', 'EMEA'),
           (2, 'F0000000-0000-0000-0000-000000000002', N'Germany', N'Europe', 'EMEA');
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-001 only TRANSTYPE 15 rows are in scope]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE)
    VALUES (N'gb01', 1001, N'C100001', 15, -100.00, -100.00, N'GBP', '2024-01-10'),
           (N'gb01', 1002, N'C100001', 8, -100.00, -100.00, N'GBP', '2024-01-10'),
           (N'gb01', 1003, N'C100001', 24, -100.00, -100.00, N'GBP', '2024-01-10');

    SELECT legal_entity, fo_transaction_recid
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source
    WHERE account_number = N'C100001';

    SELECT legal_entity, fo_transaction_recid
    INTO #Expected
    FROM (VALUES (N'gb01', CAST(1001 AS bigint))) AS v(legal_entity, fo_transaction_recid);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-002 row count per legal entity matches in-scope FO rows]
AS
BEGIN
    INSERT INTO CE.tblContact_Test_Records (contactid, apuk_contactnumber)
    VALUES ('D0000000-0000-0000-0000-000000000001', N'T900001');

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE)
    VALUES (N'gb01', 2001, N'C100001', 15, -10.00, -10.00, N'GBP', '2024-01-10'),
           (N'gb01', 2002, N'ACME01', 15, -20.00, -20.00, N'GBP', '2024-01-10'),
           (N'gb01', 2003, N'ACME01', 15, -30.00, -30.00, N'GBP', '2024-01-11'),
           (N'gb01', 2004, N'T900001', 15, -40.00, -40.00, N'GBP', '2024-01-12'),
           (N'gb01', 2007, N'ACME01', 8, -70.00, -70.00, N'GBP', '2024-01-12'),
           (N'us01', 2005, N'ACME02', 15, -50.00, -50.00, N'USD', '2024-01-10'),
           (N'us01', 2006, N'ACME02', 15, -60.00, -60.00, N'USD', '2024-01-11');

    SELECT legal_entity, COUNT(*) AS row_count
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source
    GROUP BY legal_entity;

    SELECT legal_entity, row_count
    INTO #Expected
    FROM (VALUES (N'gb01', 3), (N'us01', 2)) AS v(legal_entity, row_count);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-003 each payment appears once when account matches two contacts]
AS
BEGIN
    INSERT INTO Layercake.brnz_contact (ContactId, Rics_contactno, rics_countryid, [_is_deleted])
    VALUES ('C0000000-0000-0000-0000-000000000031', N'C100003', 'F0000000-0000-0000-0000-000000000001', 0),
           ('C0000000-0000-0000-0000-000000000032', N'C100003', 'F0000000-0000-0000-0000-000000000002', 0);

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE)
    VALUES (N'gb01', 3001, N'C100003', 15, -10.00, -10.00, N'GBP', '2024-01-10'),
           (N'gb01', 3002, N'C100003', 15, -20.00, -20.00, N'GBP', '2024-01-11'),
           (N'us01', 3003, N'C100003', 15, -30.00, -30.00, N'USD', '2024-01-12');

    SELECT legal_entity, fo_transaction_recid, COUNT(*) AS occurrences
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source
    GROUP BY legal_entity, fo_transaction_recid;

    SELECT legal_entity, fo_transaction_recid, occurrences
    INTO #Expected
    FROM (VALUES (N'gb01', CAST(3001 AS bigint), 1),
                 (N'gb01', CAST(3002 AS bigint), 1),
                 (N'us01', CAST(3003 AS bigint), 1)) AS v(legal_entity, fo_transaction_recid, occurrences);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-004 test account payments are left out in every legal entity]
AS
BEGIN
    INSERT INTO CE.tblContact_Test_Records (contactid, apuk_contactnumber)
    VALUES ('D0000000-0000-0000-0000-000000000001', N'T900001');

    INSERT INTO Layercake.brnz_contact (ContactId, Rics_contactno, rics_countryid, [_is_deleted])
    VALUES ('C0000000-0000-0000-0000-000000000041', N'T900001', 'F0000000-0000-0000-0000-000000000001', 0);

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE)
    VALUES (N'gb01', 4001, N'T900001', 15, -10.00, -10.00, N'GBP', '2024-01-10'),
           (N'us01', 4002, N'T900001', 15, -20.00, -20.00, N'USD', '2024-01-10'),
           (N'gb01', 4003, N'ACME01', 15, -30.00, -30.00, N'GBP', '2024-01-10');

    SELECT legal_entity, fo_transaction_recid
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT legal_entity, fo_transaction_recid
    INTO #Expected
    FROM (VALUES (N'gb01', CAST(4003 AS bigint))) AS v(legal_entity, fo_transaction_recid);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-005 test record with NULL contact number excludes nothing else]
AS
BEGIN
    INSERT INTO CE.tblContact_Test_Records (contactid, apuk_contactnumber)
    VALUES ('D0000000-0000-0000-0000-000000000001', N'T900001'),
           ('D0000000-0000-0000-0000-000000000002', NULL);

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE)
    VALUES (N'gb01', 5001, N'ACME01', 15, -10.00, -10.00, N'GBP', '2024-01-10'),
           (N'gb01', 5002, N'C100001', 15, -20.00, -20.00, N'GBP', '2024-01-10'),
           (N'gb01', 5003, N'T900001', 15, -30.00, -30.00, N'GBP', '2024-01-10');

    SELECT legal_entity, fo_transaction_recid
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT legal_entity, fo_transaction_recid
    INTO #Expected
    FROM (VALUES (N'gb01', CAST(5001 AS bigint)),
                 (N'gb01', CAST(5002 AS bigint))) AS v(legal_entity, fo_transaction_recid);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-006 row with null optional values is carried through]
AS
BEGIN
    INSERT INTO CE.tblContact_Test_Records (contactid, apuk_contactnumber)
    VALUES ('D0000000-0000-0000-0000-000000000001', N'T900001');

    INSERT INTO Layercake.brnz_contact (ContactId, Rics_contactno, rics_countryid, [_is_deleted])
    VALUES ('C0000000-0000-0000-0000-000000000061', NULL, 'F0000000-0000-0000-0000-000000000001', 0);

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, PAYMMODE, DOCUMENTDATE, TRANSDATE)
    VALUES (N'gb01', 6001, NULL, 15, NULL, NULL, NULL, NULL, NULL, NULL);

    SELECT legal_entity, fo_transaction_recid, account_number, contact_number, is_corporate,
           payment_date, payment_year, payment_month, amount_paid_currency, currency_code, amount_paid_gbp,
           payment_method_code, payment_method, country_name, region_name, market_reporting_region
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT CAST(N'gb01' AS nvarchar(4)) AS legal_entity,
           CAST(6001 AS bigint) AS fo_transaction_recid,
           CAST(NULL AS nvarchar(20)) AS account_number,
           CAST(NULL AS nvarchar(100)) AS contact_number,
           CAST(1 AS bit) AS is_corporate,
           CAST(NULL AS date) AS payment_date,
           CAST(NULL AS int) AS payment_year,
           CAST(NULL AS tinyint) AS payment_month,
           CAST(NULL AS decimal(32,6)) AS amount_paid_currency,
           CAST(NULL AS nvarchar(3)) AS currency_code,
           CAST(NULL AS decimal(32,6)) AS amount_paid_gbp,
           CAST(N'Unknown' AS nvarchar(10)) AS payment_method_code,
           CAST(N'Unknown' AS nvarchar(60)) AS payment_method,
           CAST(N'Unknown' AS nvarchar(200)) AS country_name,
           CAST(N'Unknown' AS nvarchar(200)) AS region_name,
           CAST('Unknown' AS varchar(15)) AS market_reporting_region
    INTO #Expected;

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-007 cancelled payment is kept]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE, CANCELLEDPAYMENT)
    VALUES (N'gb01', 7001, N'ACME01', 15, -40.00, -40.00, N'GBP', '2024-01-10', 1),
           (N'gb01', 7002, N'ACME01', 15, -60.00, -60.00, N'GBP', '2024-01-11', 0);

    SELECT legal_entity, fo_transaction_recid, amount_paid_gbp
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT legal_entity, fo_transaction_recid, amount_paid_gbp
    INTO #Expected
    FROM (VALUES (N'gb01', CAST(7001 AS bigint), CAST(40.000000 AS decimal(32,6))),
                 (N'gb01', CAST(7002 AS bigint), CAST(60.000000 AS decimal(32,6)))) AS v(legal_entity, fo_transaction_recid, amount_paid_gbp);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-008 identical payments with different RECIDs are both kept]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, PAYMMODE, TRANSDATE)
    VALUES (N'gb01', 8001, N'C100001', 15, -50.00, -50.00, N'GBP', N'DD', '2024-02-01'),
           (N'gb01', 8002, N'C100001', 15, -50.00, -50.00, N'GBP', N'DD', '2024-02-01');

    SELECT legal_entity, fo_transaction_recid, account_number, amount_paid_currency, amount_paid_gbp, payment_date, payment_method_code
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT legal_entity, fo_transaction_recid, account_number, amount_paid_currency, amount_paid_gbp, payment_date, payment_method_code
    INTO #Expected
    FROM (VALUES (N'gb01', CAST(8001 AS bigint), N'C100001', CAST(50.000000 AS decimal(32,6)), CAST(50.000000 AS decimal(32,6)), CAST('2024-02-01' AS date), N'DD'),
                 (N'gb01', CAST(8002 AS bigint), N'C100001', CAST(50.000000 AS decimal(32,6)), CAST(50.000000 AS decimal(32,6)), CAST('2024-02-01' AS date), N'DD'))
         AS v(legal_entity, fo_transaction_recid, account_number, amount_paid_currency, amount_paid_gbp, payment_date, payment_method_code);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-009 all legal entities and old dates are included]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE)
    VALUES (N'gb01', 9001, N'ACME01', 15, -10.00, -10.00, N'GBP', NULL, '2024-05-01'),
           (N'us01', 9002, N'ACME02', 15, -20.00, -20.00, N'USD', NULL, '2024-05-01'),
           (N'gb01', 9003, N'ACME01', 15, -30.00, -30.00, N'GBP', '2012-03-01', '2012-03-01');

    SELECT legal_entity, fo_transaction_recid, payment_date
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT legal_entity, fo_transaction_recid, payment_date
    INTO #Expected
    FROM (VALUES (N'gb01', CAST(9001 AS bigint), CAST('2024-05-01' AS date)),
                 (N'us01', CAST(9002 AS bigint), CAST('2024-05-01' AS date)),
                 (N'gb01', CAST(9003 AS bigint), CAST('2012-03-01' AS date))) AS v(legal_entity, fo_transaction_recid, payment_date);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-010 EUR payment shows positive currency and GBP amounts]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE)
    VALUES (N'gb01', 10001, N'ACME01', 15, -100.00, -85.00, N'EUR', '2024-01-10');

    SELECT fo_transaction_recid, amount_paid_currency, currency_code, amount_paid_gbp
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, amount_paid_currency, currency_code, amount_paid_gbp
    INTO #Expected
    FROM (VALUES (CAST(10001 AS bigint), CAST(100.000000 AS decimal(32,6)), N'EUR', CAST(85.000000 AS decimal(32,6))))
         AS v(fo_transaction_recid, amount_paid_currency, currency_code, amount_paid_gbp);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-011 amounts keep six decimal places without rounding]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE)
    VALUES (N'gb01', 11001, N'ACME01', 15, -12.345678, -10.123457, N'EUR', '2024-01-10'),
           (N'gb01', 11002, N'ACME01', 15, 0.000000, 0.000000, N'GBP', '2024-01-10'),
           (N'gb01', 11003, N'ACME01', 15, -0.000001, -0.000001, N'GBP', '2024-01-10');

    SELECT fo_transaction_recid, amount_paid_currency, amount_paid_gbp
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, amount_paid_currency, amount_paid_gbp
    INTO #Expected
    FROM (VALUES (CAST(11001 AS bigint), CAST(12.345678 AS decimal(32,6)), CAST(10.123457 AS decimal(32,6))),
                 (CAST(11002 AS bigint), CAST(0.000000 AS decimal(32,6)), CAST(0.000000 AS decimal(32,6))),
                 (CAST(11003 AS bigint), CAST(0.000001 AS decimal(32,6)), CAST(0.000001 AS decimal(32,6))))
         AS v(fo_transaction_recid, amount_paid_currency, amount_paid_gbp);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-012 refund shows negative and nets off against payment]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE)
    VALUES (N'gb01', 12001, N'ACME01', 15, 30.00, 30.00, N'GBP', '2024-01-12'),
           (N'gb01', 12002, N'ACME01', 15, -100.00, -100.00, N'GBP', '2024-01-10');

    SELECT fo_transaction_recid, amount_paid_currency, amount_paid_gbp
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, amount_paid_currency, amount_paid_gbp
    INTO #Expected
    FROM (VALUES (CAST(12001 AS bigint), CAST(-30.000000 AS decimal(32,6)), CAST(-30.000000 AS decimal(32,6))),
                 (CAST(12002 AS bigint), CAST(100.000000 AS decimal(32,6)), CAST(100.000000 AS decimal(32,6))))
         AS v(fo_transaction_recid, amount_paid_currency, amount_paid_gbp);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';

    SELECT account_number, SUM(amount_paid_currency) AS total_currency, SUM(amount_paid_gbp) AS total_gbp
    INTO #ActualTotal
    FROM Layercake.vw_fact_contact_payment_source
    GROUP BY account_number;

    SELECT account_number, total_currency, total_gbp
    INTO #ExpectedTotal
    FROM (VALUES (N'ACME01', CAST(70.000000 AS decimal(38,6)), CAST(70.000000 AS decimal(38,6)))) AS v(account_number, total_currency, total_gbp);

    EXEC tSQLt.AssertEqualsTable '#ExpectedTotal', '#ActualTotal';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-013 GBP payment shows positive amounts]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE)
    VALUES (N'gb01', 13001, N'ACME01', 15, -250.00, -250.00, N'GBP', '2024-01-10');

    SELECT fo_transaction_recid, amount_paid_currency, currency_code, amount_paid_gbp
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, amount_paid_currency, currency_code, amount_paid_gbp
    INTO #Expected
    FROM (VALUES (CAST(13001 AS bigint), CAST(250.000000 AS decimal(32,6)), N'GBP', CAST(250.000000 AS decimal(32,6))))
         AS v(fo_transaction_recid, amount_paid_currency, currency_code, amount_paid_gbp);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-014 payment method named from the legal entity mode table]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTPAYMMODETABLE (DATAAREAID, PAYMMODE, NAME)
    VALUES (N'gb01', N'DD', N'Direct Debit');

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, PAYMMODE, TRANSDATE)
    VALUES (N'gb01', 14001, N'ACME01', 15, -10.00, -10.00, N'GBP', N'DD', '2024-01-10');

    SELECT fo_transaction_recid, payment_method_code, payment_method
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, payment_method_code, payment_method
    INTO #Expected
    FROM (VALUES (CAST(14001 AS bigint), N'DD', N'Direct Debit')) AS v(fo_transaction_recid, payment_method_code, payment_method);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-015 null empty or blank payment mode shows Unknown]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTPAYMMODETABLE (DATAAREAID, PAYMMODE, NAME)
    VALUES (N'gb01', N'', N'Blank mode');

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, PAYMMODE, TRANSDATE)
    VALUES (N'gb01', 15001, N'ACME01', 15, -10.00, -10.00, N'GBP', NULL, '2024-01-10'),
           (N'gb01', 15002, N'ACME01', 15, -20.00, -20.00, N'GBP', N'', '2024-01-10'),
           (N'gb01', 15003, N'ACME01', 15, -30.00, -30.00, N'GBP', N'   ', '2024-01-10');

    SELECT fo_transaction_recid, payment_method_code, payment_method
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, payment_method_code, payment_method
    INTO #Expected
    FROM (VALUES (CAST(15001 AS bigint), N'Unknown', N'Unknown'),
                 (CAST(15002 AS bigint), N'Unknown', N'Unknown'),
                 (CAST(15003 AS bigint), N'Unknown', N'Unknown')) AS v(fo_transaction_recid, payment_method_code, payment_method);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-016 unmatched or unnamed payment mode shows its code]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTPAYMMODETABLE (DATAAREAID, PAYMMODE, NAME)
    VALUES (N'us01', N'XYZ', N'Other'),
           (N'gb01', N'CHQ', N'  '),
           (N'gb01', N'BAC', NULL);

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, PAYMMODE, TRANSDATE)
    VALUES (N'gb01', 16001, N'ACME01', 15, -10.00, -10.00, N'GBP', N'XYZ', '2024-01-10'),
           (N'gb01', 16002, N'ACME01', 15, -20.00, -20.00, N'GBP', N'CHQ', '2024-01-10'),
           (N'gb01', 16003, N'ACME01', 15, -30.00, -30.00, N'GBP', N'BAC', '2024-01-10');

    SELECT fo_transaction_recid, payment_method_code, payment_method
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, payment_method_code, payment_method
    INTO #Expected
    FROM (VALUES (CAST(16001 AS bigint), N'XYZ', N'XYZ'),
                 (CAST(16002 AS bigint), N'CHQ', N'CHQ'),
                 (CAST(16003 AS bigint), N'BAC', N'BAC')) AS v(fo_transaction_recid, payment_method_code, payment_method);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-017 payment method name depends on legal entity]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTPAYMMODETABLE (DATAAREAID, PAYMMODE, NAME)
    VALUES (N'gb01', N'DD', N'Direct Debit'),
           (N'us01', N'DD', N'ACH Debit');

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, PAYMMODE, TRANSDATE)
    VALUES (N'gb01', 17001, N'ACME01', 15, -10.00, -10.00, N'GBP', N'DD', '2024-01-10'),
           (N'us01', 17002, N'ACME02', 15, -20.00, -20.00, N'USD', N'DD', '2024-01-10');

    SELECT legal_entity, fo_transaction_recid, payment_method_code, payment_method
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT legal_entity, fo_transaction_recid, payment_method_code, payment_method
    INTO #Expected
    FROM (VALUES (N'gb01', CAST(17001 AS bigint), N'DD', N'Direct Debit'),
                 (N'us01', CAST(17002 AS bigint), N'DD', N'ACH Debit')) AS v(legal_entity, fo_transaction_recid, payment_method_code, payment_method);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-018 document date before cutoff is used]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE)
    VALUES (N'gb01', 18001, N'ACME01', 15, -10.00, -10.00, N'GBP', '2021-08-20', '2021-09-02');

    SELECT fo_transaction_recid, payment_date, payment_year, payment_month
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, payment_date, payment_year, payment_month
    INTO #Expected
    FROM (VALUES (CAST(18001 AS bigint), CAST('2021-08-20' AS date), 2021, CAST(8 AS tinyint))) AS v(fo_transaction_recid, payment_date, payment_year, payment_month);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-019 document date on cutoff date is used]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE)
    VALUES (N'gb01', 19001, N'ACME01', 15, -10.00, -10.00, N'GBP', '2021-08-23', '2021-09-01');

    SELECT fo_transaction_recid, payment_date, payment_year, payment_month
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, payment_date, payment_year, payment_month
    INTO #Expected
    FROM (VALUES (CAST(19001 AS bigint), CAST('2021-08-23' AS date), 2021, CAST(8 AS tinyint))) AS v(fo_transaction_recid, payment_date, payment_year, payment_month);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-020 document date after cutoff uses transaction date]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE)
    VALUES (N'gb01', 20001, N'ACME01', 15, -10.00, -10.00, N'GBP', '2021-08-24', '2021-08-30');

    SELECT fo_transaction_recid, payment_date, payment_year, payment_month
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, payment_date, payment_year, payment_month
    INTO #Expected
    FROM (VALUES (CAST(20001 AS bigint), CAST('2021-08-30' AS date), 2021, CAST(8 AS tinyint))) AS v(fo_transaction_recid, payment_date, payment_year, payment_month);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-021 year 1900 or null document date uses transaction date]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE)
    VALUES (N'gb01', 21001, N'ACME01', 15, -10.00, -10.00, N'GBP', '1900-01-01', '2020-05-05'),
           (N'gb01', 21002, N'ACME01', 15, -20.00, -20.00, N'GBP', NULL, '2019-12-31');

    SELECT fo_transaction_recid, payment_date, payment_year, payment_month
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, payment_date, payment_year, payment_month
    INTO #Expected
    FROM (VALUES (CAST(21001 AS bigint), CAST('2020-05-05' AS date), 2020, CAST(5 AS tinyint)),
                 (CAST(21002 AS bigint), CAST('2019-12-31' AS date), 2019, CAST(12 AS tinyint))) AS v(fo_transaction_recid, payment_date, payment_year, payment_month);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-022 any 1900 document date is ignored but 1901 is used]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE)
    VALUES (N'gb01', 22001, N'ACME01', 15, -10.00, -10.00, N'GBP', '1900-12-31', '2018-07-15'),
           (N'gb01', 22002, N'ACME01', 15, -20.00, -20.00, N'GBP', '1901-01-01', '2018-07-16');

    SELECT fo_transaction_recid, payment_date, payment_year, payment_month
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, payment_date, payment_year, payment_month
    INTO #Expected
    FROM (VALUES (CAST(22001 AS bigint), CAST('2018-07-15' AS date), 2018, CAST(7 AS tinyint)),
                 (CAST(22002 AS bigint), CAST('1901-01-01' AS date), 1901, CAST(1 AS tinyint))) AS v(fo_transaction_recid, payment_date, payment_year, payment_month);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-023 year and month are calendar values of payment date]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE)
    VALUES (N'gb01', 23001, N'ACME01', 15, -10.00, -10.00, N'GBP', '2024-03-28', '2024-03-31');

    SELECT fo_transaction_recid, payment_date, payment_year, payment_month
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, payment_date, payment_year, payment_month
    INTO #Expected
    FROM (VALUES (CAST(23001 AS bigint), CAST('2024-03-31' AS date), 2024, CAST(3 AS tinyint))) AS v(fo_transaction_recid, payment_date, payment_year, payment_month);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-024 payment on a current contact account is a contact payment]
AS
BEGIN
    INSERT INTO Layercake.brnz_contact (ContactId, Rics_contactno, rics_countryid, [_is_deleted])
    VALUES ('C0000000-0000-0000-0000-000000000241', N'C100001', 'F0000000-0000-0000-0000-000000000001', 0);

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE)
    VALUES (N'gb01', 24001, N'C100001', 15, -10.00, -10.00, N'GBP', '2024-01-10');

    SELECT fo_transaction_recid, is_corporate, contact_number, account_number
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, is_corporate, contact_number, account_number
    INTO #Expected
    FROM (VALUES (CAST(24001 AS bigint), CAST(0 AS bit), N'C100001', N'C100001')) AS v(fo_transaction_recid, is_corporate, contact_number, account_number);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-025 unmatched account is one unsplit corporate payment]
AS
BEGIN
    INSERT INTO Layercake.brnz_contact (ContactId, Rics_contactno, rics_countryid, [_is_deleted])
    VALUES ('C0000000-0000-0000-0000-000000000251', N'C100001', 'F0000000-0000-0000-0000-000000000001', 0);

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE)
    VALUES (N'gb01', 25001, N'ACME01', 15, -1200.00, -1200.00, N'GBP', '2024-01-10');

    SELECT fo_transaction_recid, is_corporate, contact_number, account_number, amount_paid_gbp
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, is_corporate, contact_number, account_number, amount_paid_gbp
    INTO #Expected
    FROM (VALUES (CAST(25001 AS bigint), CAST(1 AS bit), CAST(NULL AS nvarchar(100)), N'ACME01', CAST(1200.000000 AS decimal(32,6))))
         AS v(fo_transaction_recid, is_corporate, contact_number, account_number, amount_paid_gbp);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-026 account matching only a deleted contact is corporate]
AS
BEGIN
    INSERT INTO Layercake.brnz_contact (ContactId, Rics_contactno, rics_countryid, [_is_deleted])
    VALUES ('C0000000-0000-0000-0000-000000000261', N'C100002', 'F0000000-0000-0000-0000-000000000001', 1);

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE)
    VALUES (N'gb01', 26001, N'C100002', 15, -10.00, -10.00, N'GBP', '2024-01-10');

    SELECT fo_transaction_recid, is_corporate, contact_number, account_number, country_name, region_name, market_reporting_region
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, is_corporate, contact_number, account_number, country_name, region_name, market_reporting_region
    INTO #Expected
    FROM (VALUES (CAST(26001 AS bigint), CAST(1 AS bit), CAST(NULL AS nvarchar(100)), N'C100002', N'Unknown', N'Unknown', 'Unknown'))
         AS v(fo_transaction_recid, is_corporate, contact_number, account_number, country_name, region_name, market_reporting_region);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-027 deleted duplicate contact is ignored for attribution and country]
AS
BEGIN
    INSERT INTO Layercake.brnz_contact (ContactId, Rics_contactno, rics_countryid, [_is_deleted])
    VALUES ('C0000000-0000-0000-0000-000000000272', N'C100004', 'F0000000-0000-0000-0000-000000000002', 0),
           ('C0000000-0000-0000-0000-000000000271', N'C100004', 'F0000000-0000-0000-0000-000000000001', 1);

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE)
    VALUES (N'gb01', 27001, N'C100004', 15, -10.00, -10.00, N'GBP', '2024-01-10');

    SELECT fo_transaction_recid, is_corporate, contact_number, country_name
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, is_corporate, contact_number, country_name
    INTO #Expected
    FROM (VALUES (CAST(27001 AS bigint), CAST(0 AS bit), N'C100004', N'Germany')) AS v(fo_transaction_recid, is_corporate, contact_number, country_name);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-028 contact match applies in any legal entity]
AS
BEGIN
    INSERT INTO Layercake.brnz_contact (ContactId, Rics_contactno, rics_countryid, [_is_deleted])
    VALUES ('C0000000-0000-0000-0000-000000000281', N'C100001', 'F0000000-0000-0000-0000-000000000001', 0);

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE)
    VALUES (N'us01', 28001, N'C100001', 15, -10.00, -10.00, N'USD', '2024-01-10');

    SELECT legal_entity, fo_transaction_recid, is_corporate, contact_number
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT legal_entity, fo_transaction_recid, is_corporate, contact_number
    INTO #Expected
    FROM (VALUES (N'us01', CAST(28001 AS bigint), CAST(0 AS bit), N'C100001')) AS v(legal_entity, fo_transaction_recid, is_corporate, contact_number);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-029 contact plus corporate totals equal legal entity total]
AS
BEGIN
    INSERT INTO Layercake.brnz_contact (ContactId, Rics_contactno, rics_countryid, [_is_deleted])
    VALUES ('C0000000-0000-0000-0000-000000000291', N'C100001', 'F0000000-0000-0000-0000-000000000001', 0);

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE)
    VALUES (N'gb01', 29001, N'C100001', 15, -100.00, -100.00, N'GBP', '2024-01-10'),
           (N'gb01', 29002, N'ACME01', 15, -1200.00, -1200.00, N'GBP', '2024-01-10'),
           (N'gb01', 29003, N'ACME02', 15, -50.50, -50.50, N'GBP', '2024-01-10'),
           (N'us01', 29004, N'C100001', 15, -10.00, -10.00, N'USD', '2024-01-10'),
           (N'us01', 29005, N'ACME03', 15, -20.00, -20.00, N'USD', '2024-01-10');

    SELECT legal_entity,
           SUM(CASE WHEN is_corporate = 0 THEN amount_paid_gbp ELSE 0 END) AS contact_gbp,
           SUM(CASE WHEN is_corporate = 1 THEN amount_paid_gbp ELSE 0 END) AS corporate_gbp,
           SUM(amount_paid_gbp) AS total_gbp
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source
    GROUP BY legal_entity;

    SELECT legal_entity, contact_gbp, corporate_gbp, total_gbp
    INTO #Expected
    FROM (VALUES (N'gb01', CAST(100.000000 AS decimal(38,6)), CAST(1250.500000 AS decimal(38,6)), CAST(1350.500000 AS decimal(38,6))),
                 (N'us01', CAST(10.000000 AS decimal(38,6)), CAST(20.000000 AS decimal(38,6)), CAST(30.000000 AS decimal(38,6))))
         AS v(legal_entity, contact_gbp, corporate_gbp, total_gbp);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-030 contact payment shows country region and market]
AS
BEGIN
    INSERT INTO Layercake.brnz_contact (ContactId, Rics_contactno, rics_countryid, [_is_deleted])
    VALUES ('C0000000-0000-0000-0000-000000000301', N'C100001', 'F0000000-0000-0000-0000-000000000001', 0);

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE)
    VALUES (N'gb01', 30001, N'C100001', 15, -10.00, -10.00, N'GBP', '2024-01-10');

    SELECT fo_transaction_recid, country_name, region_name, market_reporting_region
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, country_name, region_name, market_reporting_region
    INTO #Expected
    FROM (VALUES (CAST(30001 AS bigint), N'France', N'Europe', 'EMEA')) AS v(fo_transaction_recid, country_name, region_name, market_reporting_region);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-031 contact without a known country shows Unknown]
AS
BEGIN
    INSERT INTO Layercake.brnz_contact (ContactId, Rics_contactno, rics_countryid, [_is_deleted])
    VALUES ('C0000000-0000-0000-0000-000000000311', N'C100005', NULL, 0),
           ('C0000000-0000-0000-0000-000000000312', N'C100006', 'F0000000-0000-0000-0000-000000000099', 0);

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE)
    VALUES (N'gb01', 31001, N'C100005', 15, -10.00, -10.00, N'GBP', '2024-01-10'),
           (N'gb01', 31002, N'C100006', 15, -20.00, -20.00, N'GBP', '2024-01-10');

    SELECT fo_transaction_recid, is_corporate, country_name, region_name, market_reporting_region
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, is_corporate, country_name, region_name, market_reporting_region
    INTO #Expected
    FROM (VALUES (CAST(31001 AS bigint), CAST(0 AS bit), N'Unknown', N'Unknown', 'Unknown'),
                 (CAST(31002 AS bigint), CAST(0 AS bit), N'Unknown', N'Unknown', 'Unknown'))
         AS v(fo_transaction_recid, is_corporate, country_name, region_name, market_reporting_region);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-032 corporate payment shows Unknown country region and market]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE)
    VALUES (N'gb01', 32001, N'ACME01', 15, -10.00, -10.00, N'GBP', '2024-01-10');

    SELECT fo_transaction_recid, country_name, region_name, market_reporting_region
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, country_name, region_name, market_reporting_region
    INTO #Expected
    FROM (VALUES (CAST(32001 AS bigint), N'Unknown', N'Unknown', 'Unknown')) AS v(fo_transaction_recid, country_name, region_name, market_reporting_region);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-033 Unknown fallbacks have exact case and no padding]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, PAYMMODE, TRANSDATE)
    VALUES (N'gb01', 33001, N'ACME01', 15, -10.00, -10.00, N'GBP', NULL, '2024-01-10');

    SELECT CAST(CAST(payment_method_code AS nvarchar(200)) AS varbinary(400)) AS payment_method_code_bytes,
           CAST(CAST(payment_method AS nvarchar(200)) AS varbinary(400)) AS payment_method_bytes,
           CAST(CAST(country_name AS nvarchar(200)) AS varbinary(400)) AS country_name_bytes,
           CAST(CAST(region_name AS nvarchar(200)) AS varbinary(400)) AS region_name_bytes,
           CAST(CAST(market_reporting_region AS nvarchar(200)) AS varbinary(400)) AS market_reporting_region_bytes
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT CAST(N'Unknown' AS varbinary(400)) AS payment_method_code_bytes,
           CAST(N'Unknown' AS varbinary(400)) AS payment_method_bytes,
           CAST(N'Unknown' AS varbinary(400)) AS country_name_bytes,
           CAST(N'Unknown' AS varbinary(400)) AS region_name_bytes,
           CAST(N'Unknown' AS varbinary(400)) AS market_reporting_region_bytes
    INTO #Expected;

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-034 shared contact number gives one row with one matching country]
AS
BEGIN
    INSERT INTO Layercake.brnz_contact (ContactId, Rics_contactno, rics_countryid, [_is_deleted])
    VALUES ('C0000000-0000-0000-0000-000000000341', N'C100003', 'F0000000-0000-0000-0000-000000000001', 0),
           ('C0000000-0000-0000-0000-000000000342', N'C100003', 'F0000000-0000-0000-0000-000000000002', 0);

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE)
    VALUES (N'gb01', 34001, N'C100003', 15, -10.00, -10.00, N'GBP', '2024-01-10');

    SELECT fo_transaction_recid, is_corporate, contact_number,
           CASE WHEN country_name IN (N'France', N'Germany') THEN 1 ELSE 0 END AS country_is_a_match
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT fo_transaction_recid, is_corporate, contact_number, country_is_a_match
    INTO #Expected
    FROM (VALUES (CAST(34001 AS bigint), CAST(0 AS bit), N'C100003', 1)) AS v(fo_transaction_recid, is_corporate, contact_number, country_is_a_match);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD001.[test TC-001-035 shared contact number uses lowest ContactId country]
AS
BEGIN
    INSERT INTO Layercake.brnz_contact (ContactId, Rics_contactno, rics_countryid, [_is_deleted])
    VALUES ('C0000000-0000-0000-0000-000000000002', N'C100003', 'F0000000-0000-0000-0000-000000000001', 0),
           ('C0000000-0000-0000-0000-000000000001', N'C100003', 'F0000000-0000-0000-0000-000000000002', 0);

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE)
    VALUES (N'gb01', 35001, N'C100003', 15, -10.00, -10.00, N'GBP', '2024-01-10'),
           (N'us01', 35002, N'C100003', 15, -20.00, -20.00, N'USD', '2024-01-11');

    SELECT legal_entity, fo_transaction_recid, country_name, region_name, market_reporting_region
    INTO #Actual
    FROM Layercake.vw_fact_contact_payment_source;

    SELECT legal_entity, fo_transaction_recid, country_name, region_name, market_reporting_region
    INTO #Expected
    FROM (VALUES (N'gb01', CAST(35001 AS bigint), N'Germany', N'Europe', 'EMEA'),
                 (N'us01', CAST(35002 AS bigint), N'Germany', N'Europe', 'EMEA'))
         AS v(legal_entity, fo_transaction_recid, country_name, region_name, market_reporting_region);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

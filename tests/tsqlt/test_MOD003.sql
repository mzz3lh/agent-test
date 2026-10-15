EXEC tSQLt.NewTestClass 'test_MOD003';
GO

CREATE PROCEDURE test_MOD003.[SetUp]
AS
BEGIN
    EXEC tSQLt.FakeTable 'synapse_fo.CUSTTRANS';
    EXEC tSQLt.FakeTable 'CE.tblContact_Test_Records';
    EXEC tSQLt.FakeTable 'Layercake.fact_contact_payment';
END;
GO

CREATE PROCEDURE test_MOD003.[test TC-003-001 gb01 reconciles with test account and other transtypes excluded from FO side]
AS
BEGIN
    INSERT INTO CE.tblContact_Test_Records (contactid, apuk_contactnumber)
    VALUES (NEWID(), N'T900001');

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, PARTITION, TRANSTYPE, ACCOUNTNUM, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, CANCELLEDPAYMENT)
    VALUES (N'gb01', 1001, 1, 15, N'C100001', -100.00, -100.00, N'GBP', 0),
           (N'gb01', 1002, 1, 15, N'C100002',  -50.00,  -50.00, N'GBP', 1),
           (N'gb01', 1003, 1, 15, N'ACME01',    30.00,   30.00, N'GBP', 0),
           (N'gb01', 1004, 1, 15, N'T900001', -999.00, -999.00, N'GBP', 0),
           (N'gb01', 1005, 1,  8, N'C100001', -500.00, -500.00, N'GBP', 0),
           (N'gb01', 1006, 1, 24, N'C100001', -700.00, -700.00, N'GBP', 0);

    INSERT INTO Layercake.fact_contact_payment (legal_entity, fo_transaction_recid, account_number, is_corporate, amount_paid_currency, currency_code, amount_paid_gbp)
    VALUES (N'gb01', 1001, N'C100001', 0, 100.00, N'GBP', 100.00),
           (N'gb01', 1002, N'C100002', 1,  50.00, N'GBP',  50.00),
           (N'gb01', 1003, N'ACME01',  1, -30.00, N'GBP', -30.00);

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Actual
    FROM Layercake.vw_contact_payment_reconciliation;

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Expected
    FROM (VALUES (CAST(N'gb01' AS nvarchar(4)), 3, 3, CAST(120.000000 AS decimal(38,6)), CAST(120.000000 AS decimal(38,6)), CAST(1 AS bit)))
         AS v(legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD003.[test TC-003-002 one row per legal entity with each entity reconciled separately]
AS
BEGIN
    INSERT INTO CE.tblContact_Test_Records (contactid, apuk_contactnumber)
    VALUES (NEWID(), N'T900001');

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, PARTITION, TRANSTYPE, ACCOUNTNUM, AMOUNTCUR, AMOUNTMST, CURRENCYCODE)
    VALUES (N'gb01', 2001, 1, 15, N'C100001', -100.00, -100.00, N'GBP'),
           (N'gb01', 2002, 1, 15, N'ACME01',   -25.50,  -25.50, N'GBP'),
           (N'us01', 2001, 1, 15, N'C100001', -200.00, -160.00, N'USD'),
           (N'us01', 2003, 1, 15, N'ACME02',   -40.00,  -32.00, N'USD'),
           (N'us01', 2004, 1, 15, N'T900001', -999.00, -999.00, N'USD');

    INSERT INTO Layercake.fact_contact_payment (legal_entity, fo_transaction_recid, account_number, is_corporate, amount_paid_currency, currency_code, amount_paid_gbp)
    VALUES (N'gb01', 2001, N'C100001', 0, 100.00, N'GBP', 100.00),
           (N'gb01', 2002, N'ACME01',  1,  25.50, N'GBP',  25.50),
           (N'us01', 2001, N'C100001', 0, 200.00, N'USD', 160.00),
           (N'us01', 2003, N'ACME02',  1,  40.00, N'USD',  32.00);

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Actual
    FROM Layercake.vw_contact_payment_reconciliation;

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Expected
    FROM (VALUES (CAST(N'gb01' AS nvarchar(4)), 2, 2, CAST(125.500000 AS decimal(38,6)), CAST(125.500000 AS decimal(38,6)), CAST(1 AS bit)),
                 (CAST(N'us01' AS nvarchar(4)), 2, 2, CAST(192.000000 AS decimal(38,6)), CAST(192.000000 AS decimal(38,6)), CAST(1 AS bit)))
         AS v(legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD003.[test TC-003-003 row count mismatch with equal totals is not reconciled]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, PARTITION, TRANSTYPE, ACCOUNTNUM, AMOUNTCUR, AMOUNTMST, CURRENCYCODE)
    VALUES (N'gb01', 3001, 1, 15, N'C100001', -100.00, -100.00, N'GBP'),
           (N'gb01', 3002, 1, 15, N'C100001',  -50.00,  -50.00, N'GBP'),
           (N'gb01', 3003, 1, 15, N'C100001',    0.00,    0.00, N'GBP');

    INSERT INTO Layercake.fact_contact_payment (legal_entity, fo_transaction_recid, account_number, is_corporate, amount_paid_currency, currency_code, amount_paid_gbp)
    VALUES (N'gb01', 3001, N'C100001', 0, 100.00, N'GBP', 100.00),
           (N'gb01', 3002, N'C100001', 0,  50.00, N'GBP',  50.00);

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Actual
    FROM Layercake.vw_contact_payment_reconciliation;

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Expected
    FROM (VALUES (CAST(N'gb01' AS nvarchar(4)), 2, 3, CAST(150.000000 AS decimal(38,6)), CAST(150.000000 AS decimal(38,6)), CAST(0 AS bit)))
         AS v(legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD003.[test TC-003-004 amount mismatch with equal counts is not reconciled]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, PARTITION, TRANSTYPE, ACCOUNTNUM, AMOUNTCUR, AMOUNTMST, CURRENCYCODE)
    VALUES (N'gb01', 4001, 1, 15, N'C100001', -100.00, -100.00, N'GBP'),
           (N'gb01', 4002, 1, 15, N'C100001',  -50.00,  -50.00, N'GBP');

    INSERT INTO Layercake.fact_contact_payment (legal_entity, fo_transaction_recid, account_number, is_corporate, amount_paid_currency, currency_code, amount_paid_gbp)
    VALUES (N'gb01', 4001, N'C100001', 0, 100.00, N'GBP', 100.00),
           (N'gb01', 4002, N'C100001', 0,  49.99, N'GBP',  49.99);

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Actual
    FROM Layercake.vw_contact_payment_reconciliation;

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Expected
    FROM (VALUES (CAST(N'gb01' AS nvarchar(4)), 2, 2, CAST(149.990000 AS decimal(38,6)), CAST(150.000000 AS decimal(38,6)), CAST(0 AS bit)))
         AS v(legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD003.[test TC-003-005 legal entity only in FO shows with dataset side zero and not reconciled]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, PARTITION, TRANSTYPE, ACCOUNTNUM, AMOUNTCUR, AMOUNTMST, CURRENCYCODE)
    VALUES (N'gb01', 5001, 1, 15, N'C100001', -100.00, -100.00, N'GBP'),
           (N'us01', 5002, 1, 15, N'ACME02',   -50.00,  -40.00, N'USD');

    INSERT INTO Layercake.fact_contact_payment (legal_entity, fo_transaction_recid, account_number, is_corporate, amount_paid_currency, currency_code, amount_paid_gbp)
    VALUES (N'gb01', 5001, N'C100001', 0, 100.00, N'GBP', 100.00);

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Actual
    FROM Layercake.vw_contact_payment_reconciliation;

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Expected
    FROM (VALUES (CAST(N'gb01' AS nvarchar(4)), 1, 1, CAST(100.000000 AS decimal(38,6)), CAST(100.000000 AS decimal(38,6)), CAST(1 AS bit)),
                 (CAST(N'us01' AS nvarchar(4)), 0, 1, CAST(0.000000 AS decimal(38,6)),   CAST(40.000000 AS decimal(38,6)),  CAST(0 AS bit)))
         AS v(legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD003.[test TC-003-006 legal entity only in dataset shows with FO side zero and not reconciled]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, PARTITION, TRANSTYPE, ACCOUNTNUM, AMOUNTCUR, AMOUNTMST, CURRENCYCODE)
    VALUES (N'gb01', 6001, 1, 15, N'C100001', -100.00, -100.00, N'GBP');

    INSERT INTO Layercake.fact_contact_payment (legal_entity, fo_transaction_recid, account_number, is_corporate, amount_paid_currency, currency_code, amount_paid_gbp)
    VALUES (N'gb01', 6001, N'C100001', 0, 100.00, N'GBP', 100.00),
           (N'ie01', 6002, N'C100005', 0,  10.00, N'EUR',  10.00);

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Actual
    FROM Layercake.vw_contact_payment_reconciliation;

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Expected
    FROM (VALUES (CAST(N'gb01' AS nvarchar(4)), 1, 1, CAST(100.000000 AS decimal(38,6)), CAST(100.000000 AS decimal(38,6)), CAST(1 AS bit)),
                 (CAST(N'ie01' AS nvarchar(4)), 1, 0, CAST(10.000000 AS decimal(38,6)),  CAST(0.000000 AS decimal(38,6)),   CAST(0 AS bit)))
         AS v(legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD003.[test TC-003-007 null account number and null amount rows are counted and test list null does not drop rows]
AS
BEGIN
    INSERT INTO CE.tblContact_Test_Records (contactid, apuk_contactnumber)
    VALUES (NEWID(), N'T900001'),
           (NEWID(), NULL);

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, PARTITION, TRANSTYPE, ACCOUNTNUM, AMOUNTCUR, AMOUNTMST, CURRENCYCODE)
    VALUES (N'gb01', 7001, 1, 15, NULL,       -100.00, -100.00, N'GBP'),
           (N'gb01', 7002, 1, 15, N'C100001',    NULL,    NULL, N'GBP'),
           (N'gb01', 7003, 1, 15, N'T900001', -999.00, -999.00, N'GBP');

    INSERT INTO Layercake.fact_contact_payment (legal_entity, fo_transaction_recid, account_number, is_corporate, amount_paid_currency, currency_code, amount_paid_gbp)
    VALUES (N'gb01', 7001, NULL,       1, 100.00, N'GBP', 100.00),
           (N'gb01', 7002, N'C100001', 0,   NULL, N'GBP',   NULL);

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Actual
    FROM Layercake.vw_contact_payment_reconciliation;

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Expected
    FROM (VALUES (CAST(N'gb01' AS nvarchar(4)), 2, 2, CAST(100.000000 AS decimal(38,6)), CAST(100.000000 AS decimal(38,6)), CAST(1 AS bit)))
         AS v(legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD003.[test TC-003-008 totals compared at six decimals without rounding]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, PARTITION, TRANSTYPE, ACCOUNTNUM, AMOUNTCUR, AMOUNTMST, CURRENCYCODE)
    VALUES (N'gb01', 8001, 1, 15, N'C100001', -10.123456, -10.123456, N'GBP'),
           (N'us01', 8002, 1, 15, N'ACME02',  -12.500000, -10.000001, N'USD');

    INSERT INTO Layercake.fact_contact_payment (legal_entity, fo_transaction_recid, account_number, is_corporate, amount_paid_currency, currency_code, amount_paid_gbp)
    VALUES (N'gb01', 8001, N'C100001', 0, 10.123456, N'GBP', 10.123456),
           (N'us01', 8002, N'ACME02',  1, 12.500000, N'USD', 10.000000);

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Actual
    FROM Layercake.vw_contact_payment_reconciliation;

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Expected
    FROM (VALUES (CAST(N'gb01' AS nvarchar(4)), 1, 1, CAST(10.123456 AS decimal(38,6)), CAST(10.123456 AS decimal(38,6)), CAST(1 AS bit)),
                 (CAST(N'us01' AS nvarchar(4)), 1, 1, CAST(10.000000 AS decimal(38,6)), CAST(10.000001 AS decimal(38,6)), CAST(0 AS bit)))
         AS v(legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD003.[test TC-003-009 payment and refund netting to zero reconcile at 0]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, PARTITION, TRANSTYPE, ACCOUNTNUM, AMOUNTCUR, AMOUNTMST, CURRENCYCODE)
    VALUES (N'gb01', 9001, 1, 15, N'C100001', -30.00, -30.00, N'GBP'),
           (N'gb01', 9002, 1, 15, N'C100001',  30.00,  30.00, N'GBP');

    INSERT INTO Layercake.fact_contact_payment (legal_entity, fo_transaction_recid, account_number, is_corporate, amount_paid_currency, currency_code, amount_paid_gbp)
    VALUES (N'gb01', 9001, N'C100001', 0,  30.00, N'GBP',  30.00),
           (N'gb01', 9002, N'C100001', 0, -30.00, N'GBP', -30.00);

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Actual
    FROM Layercake.vw_contact_payment_reconciliation;

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Expected
    FROM (VALUES (CAST(N'gb01' AS nvarchar(4)), 2, 2, CAST(0.000000 AS decimal(38,6)), CAST(0.000000 AS decimal(38,6)), CAST(1 AS bit)))
         AS v(legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD003.[test TC-003-010 identical FO payments both counted and duplicate test records do not multiply rows]
AS
BEGIN
    INSERT INTO CE.tblContact_Test_Records (contactid, apuk_contactnumber)
    VALUES (NEWID(), N'T900001'),
           (NEWID(), N'T900001');

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, PARTITION, TRANSTYPE, ACCOUNTNUM, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, PAYMMODE, TRANSDATE)
    VALUES (N'gb01', 10001, 1, 15, N'C100001',  -75.00,  -75.00, N'GBP', N'DD', '2024-01-15'),
           (N'gb01', 10002, 1, 15, N'C100001',  -75.00,  -75.00, N'GBP', N'DD', '2024-01-15'),
           (N'gb01', 10003, 1, 15, N'T900001', -999.00, -999.00, N'GBP', N'DD', '2024-01-15');

    INSERT INTO Layercake.fact_contact_payment (legal_entity, fo_transaction_recid, account_number, is_corporate, amount_paid_currency, currency_code, amount_paid_gbp)
    VALUES (N'gb01', 10001, N'C100001', 0, 75.00, N'GBP', 75.00),
           (N'gb01', 10002, N'C100001', 0, 75.00, N'GBP', 75.00);

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Actual
    FROM Layercake.vw_contact_payment_reconciliation;

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Expected
    FROM (VALUES (CAST(N'gb01' AS nvarchar(4)), 2, 2, CAST(150.000000 AS decimal(38,6)), CAST(150.000000 AS decimal(38,6)), CAST(1 AS bit)))
         AS v(legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

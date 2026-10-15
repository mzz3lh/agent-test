EXEC tSQLt.NewTestClass 'test_MOD003_dev';
GO

CREATE PROCEDURE test_MOD003_dev.[SetUp]
AS
BEGIN
    EXEC tSQLt.FakeTable 'synapse_fo.CUSTTRANS';
    EXEC tSQLt.FakeTable 'CE.tblContact_Test_Records';
    EXEC tSQLt.FakeTable 'Layercake.fact_contact_payment';
END;
GO

CREATE PROCEDURE test_MOD003_dev.[test entity whose amounts are all null on both sides shows 0 totals and reconciles]
AS
BEGIN
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, PARTITION, TRANSTYPE, ACCOUNTNUM, AMOUNTCUR, AMOUNTMST, CURRENCYCODE)
    VALUES (N'gb01', 1, 1, 15, N'C100001', NULL, NULL, N'GBP');

    INSERT INTO Layercake.fact_contact_payment (legal_entity, fo_transaction_recid, account_number, is_corporate, amount_paid_currency, currency_code, amount_paid_gbp)
    VALUES (N'gb01', 1, N'C100001', 0, NULL, N'GBP', NULL);

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Actual
    FROM Layercake.vw_contact_payment_reconciliation;

    SELECT legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled
    INTO #Expected
    FROM (VALUES (CAST(N'gb01' AS nvarchar(4)), 1, 1, CAST(0 AS decimal(38,6)), CAST(0 AS decimal(38,6)), CAST(1 AS bit)))
         AS v(legal_entity, dataset_row_count, fo_row_count, dataset_amount_paid_gbp, fo_amount_paid_gbp, is_reconciled);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD003_dev.[test entity with only out-of-scope FO rows and no dataset rows does not appear]
AS
BEGIN
    INSERT INTO CE.tblContact_Test_Records (contactid, apuk_contactnumber)
    VALUES (NEWID(), N'T900001');

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, RECID, PARTITION, TRANSTYPE, ACCOUNTNUM, AMOUNTCUR, AMOUNTMST, CURRENCYCODE)
    VALUES (N'us01', 1, 1,  8, N'C100001', -10.00, -10.00, N'USD'),
           (N'us01', 2, 1, 15, N'T900001', -20.00, -20.00, N'USD');

    SELECT legal_entity
    INTO #Actual
    FROM Layercake.vw_contact_payment_reconciliation;

    EXEC tSQLt.AssertEmptyTable '#Actual';
END;
GO

CREATE PROCEDURE test_MOD003_dev.[test every column of the view is reported not null]
AS
BEGIN
    DECLARE @NullableColumns int =
    (
        SELECT COUNT(*)
        FROM sys.columns AS c
        WHERE c.object_id = OBJECT_ID(N'Layercake.vw_contact_payment_reconciliation')
            AND c.is_nullable = 1
    );

    EXEC tSQLt.AssertEquals 0, @NullableColumns;
END;
GO

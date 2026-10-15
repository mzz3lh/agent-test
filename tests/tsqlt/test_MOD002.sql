EXEC tSQLt.NewTestClass 'test_MOD002';
GO

CREATE PROCEDURE test_MOD002.[SetUp]
AS
BEGIN
    EXEC tSQLt.FakeTable 'synapse_fo.CUSTTRANS';
    EXEC tSQLt.FakeTable 'synapse_fo.CUSTPAYMMODETABLE';
    EXEC tSQLt.FakeTable 'CE.tblContact_Test_Records';
    EXEC tSQLt.FakeTable 'Layercake.brnz_contact';
    EXEC tSQLt.FakeTable 'Layercake.dim_country';
    EXEC tSQLt.FakeTable 'Layercake.etl_run_log', @Identity = 1, @Defaults = 1;
    EXEC tSQLt.FakeTable 'audit.LoadLog', @Identity = 1;
    EXEC tSQLt.FakeTable 'audit.ErrorLog', @Identity = 1;

    INSERT INTO Layercake.dim_country (id, country_id, country_name, region_name, market_reporting_region)
    VALUES (1, '11111111-1111-1111-1111-111111111111', N'France', N'Europe', 'EMEA'),
           (2, '22222222-2222-2222-2222-222222222222', N'Germany', N'Central Europe', 'DACH');

    INSERT INTO Layercake.brnz_contact (ContactId, Rics_contactno, rics_countryid, _is_deleted)
    VALUES ('C0000000-0000-0000-0000-000000000001', N'C100001', '11111111-1111-1111-1111-111111111111', 0);

    INSERT INTO synapse_fo.CUSTPAYMMODETABLE (DATAAREAID, PARTITION, RECID, PAYMMODE, NAME)
    VALUES (N'gb01', 5637144576, 1, N'DD', N'Direct Debit');

    INSERT INTO CE.tblContact_Test_Records (contactid, apuk_contactnumber)
    VALUES ('F0000000-0000-0000-0000-000000000001', N'T900001');
END;
GO

CREATE PROCEDURE test_MOD002.[test TC-002-001 load persists contact and corporate payments with all columns and the passed run_id]
AS
BEGIN
    EXEC tSQLt.FakeTable 'Layercake.fact_contact_payment';
    DECLARE @run_id uniqueidentifier = 'A0000000-0000-0000-0000-000000000001';

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, PARTITION, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE, PAYMMODE, CANCELLEDPAYMENT)
    VALUES (N'gb01', 5637144576, 5001, N'C100001', 15, -100.00, -85.00, N'EUR', NULL, '2024-03-31', N'DD', 0),
           (N'gb01', 5637144576, 5002, N'ACME01', 15, -1200.00, -1200.00, N'GBP', '2019-06-15', '2019-06-20', N'CHQ', 0);

    EXEC Layercake.usp_load_fact_contact_payment @run_id = @run_id;

    SELECT legal_entity, fo_transaction_recid, account_number, contact_number, is_corporate, payment_date, payment_year, payment_month,
           amount_paid_currency, currency_code, amount_paid_gbp, payment_method_code, payment_method, country_name, region_name, market_reporting_region, run_id
    INTO #Actual
    FROM Layercake.fact_contact_payment;

    SELECT * INTO #Expected FROM (VALUES
        (CAST(N'gb01' AS nvarchar(4)), CAST(5001 AS bigint), CAST(N'C100001' AS nvarchar(20)), CAST(N'C100001' AS nvarchar(100)), CAST(0 AS bit), CAST('2024-03-31' AS date), 2024, CAST(3 AS tinyint),
         CAST(100.000000 AS decimal(32,6)), CAST(N'EUR' AS nvarchar(3)), CAST(85.000000 AS decimal(32,6)), CAST(N'DD' AS nvarchar(10)), CAST(N'Direct Debit' AS nvarchar(60)), CAST(N'France' AS nvarchar(200)), CAST(N'Europe' AS nvarchar(200)), CAST('EMEA' AS varchar(15)), CAST('A0000000-0000-0000-0000-000000000001' AS uniqueidentifier)),
        (N'gb01', 5002, N'ACME01', NULL, 1, '2019-06-15', 2019, 6,
         1200.000000, N'GBP', 1200.000000, N'CHQ', N'CHQ', N'Unknown', N'Unknown', 'Unknown', 'A0000000-0000-0000-0000-000000000001')
    ) AS v(legal_entity, fo_transaction_recid, account_number, contact_number, is_corporate, payment_date, payment_year, payment_month,
           amount_paid_currency, currency_code, amount_paid_gbp, payment_method_code, payment_method, country_name, region_name, market_reporting_region, run_id);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';

    DECLARE @missing_stamps int = (SELECT COUNT(*) FROM Layercake.fact_contact_payment WHERE created_at IS NULL OR updated_at IS NULL);
    EXEC tSQLt.AssertEquals 0, @missing_stamps, 'created_at and updated_at must be set on every row';
END;
GO

CREATE PROCEDURE test_MOD002.[test TC-002-002 dataset table has the designed columns all named in lower snake case]
AS
BEGIN
    EXEC tSQLt.FakeTable 'Layercake.fact_contact_payment';

    SELECT CAST(c.name AS nvarchar(128)) AS column_name
    INTO #Actual
    FROM sys.columns AS c
    WHERE c.object_id = OBJECT_ID(N'Layercake.fact_contact_payment');

    SELECT * INTO #Expected FROM (VALUES
        (CAST(N'legal_entity' AS nvarchar(128))), (N'fo_transaction_recid'), (N'account_number'), (N'contact_number'), (N'is_corporate'),
        (N'payment_date'), (N'payment_year'), (N'payment_month'), (N'amount_paid_currency'), (N'currency_code'), (N'amount_paid_gbp'),
        (N'payment_method_code'), (N'payment_method'), (N'country_name'), (N'region_name'), (N'market_reporting_region'),
        (N'run_id'), (N'created_at'), (N'updated_at')
    ) AS v(column_name);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';

    DECLARE @bad_names int = (
        SELECT COUNT(*)
        FROM sys.columns AS c
        WHERE c.object_id = OBJECT_ID(N'Layercake.fact_contact_payment')
          AND (c.name COLLATE Latin1_General_BIN LIKE N'%[^a-z0-9_]%'
               OR LEFT(c.name, 1) COLLATE Latin1_General_BIN NOT LIKE N'[a-z]'));
    EXEC tSQLt.AssertEquals 0, @bad_names, 'every column name must match ^[a-z][a-z0-9_]*$';
END;
GO

CREATE PROCEDURE test_MOD002.[test TC-002-003 payment added to CUSTTRANS after a load appears on the next load]
AS
BEGIN
    EXEC tSQLt.FakeTable 'Layercake.fact_contact_payment';

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, PARTITION, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE, PAYMMODE, CANCELLEDPAYMENT)
    VALUES (N'gb01', 5637144576, 11001, N'C100001', 15, -100.00, -100.00, N'GBP', NULL, '2024-03-31', N'DD', 0);

    EXEC Layercake.usp_load_fact_contact_payment @run_id = 'A0000000-0000-0000-0000-000000000031';

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, PARTITION, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE, PAYMMODE, CANCELLEDPAYMENT)
    VALUES (N'gb01', 5637144576, 11002, N'ACME01', 15, -75.50, -75.50, N'GBP', NULL, '2024-04-02', N'DD', 0);

    EXEC Layercake.usp_load_fact_contact_payment @run_id = 'A0000000-0000-0000-0000-000000000032';

    SELECT legal_entity, fo_transaction_recid, account_number, amount_paid_gbp
    INTO #Actual
    FROM Layercake.fact_contact_payment;

    SELECT * INTO #Expected FROM (VALUES
        (CAST(N'gb01' AS nvarchar(4)), CAST(11001 AS bigint), CAST(N'C100001' AS nvarchar(20)), CAST(100.000000 AS decimal(32,6))),
        (N'gb01', 11002, N'ACME01', 75.500000)
    ) AS v(legal_entity, fo_transaction_recid, account_number, amount_paid_gbp);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD002.[test TC-002-004 FO correction to an already loaded payment is restated on the next load]
AS
BEGIN
    EXEC tSQLt.FakeTable 'Layercake.fact_contact_payment';

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, PARTITION, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE, PAYMMODE, CANCELLEDPAYMENT)
    VALUES (N'gb01', 5637144576, 12101, N'C100001', 15, -100.00, -100.00, N'GBP', NULL, '2024-03-31', N'DD', 0);

    EXEC Layercake.usp_load_fact_contact_payment @run_id = 'A0000000-0000-0000-0000-000000000041';

    UPDATE synapse_fo.CUSTTRANS
    SET AMOUNTCUR = -110.00, AMOUNTMST = -110.00
    WHERE DATAAREAID = N'gb01' AND RECID = 12101;

    EXEC Layercake.usp_load_fact_contact_payment @run_id = 'A0000000-0000-0000-0000-000000000042';

    SELECT legal_entity, fo_transaction_recid, amount_paid_currency, amount_paid_gbp
    INTO #Actual
    FROM Layercake.fact_contact_payment;

    SELECT * INTO #Expected FROM (VALUES
        (CAST(N'gb01' AS nvarchar(4)), CAST(12101 AS bigint), CAST(110.000000 AS decimal(32,6)), CAST(110.000000 AS decimal(32,6)))
    ) AS v(legal_entity, fo_transaction_recid, amount_paid_currency, amount_paid_gbp);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD002.[test TC-002-005 payment removed from CUSTTRANS disappears from the dataset on the next load]
AS
BEGIN
    EXEC tSQLt.FakeTable 'Layercake.fact_contact_payment';

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, PARTITION, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE, PAYMMODE, CANCELLEDPAYMENT)
    VALUES (N'gb01', 5637144576, 12001, N'C100001', 15, -100.00, -100.00, N'GBP', NULL, '2024-03-31', N'DD', 0),
           (N'gb01', 5637144576, 12002, N'ACME01', 15, -60.00, -60.00, N'GBP', NULL, '2024-03-31', N'DD', 0);

    EXEC Layercake.usp_load_fact_contact_payment @run_id = 'A0000000-0000-0000-0000-000000000051';

    DELETE FROM synapse_fo.CUSTTRANS WHERE DATAAREAID = N'gb01' AND RECID = 12002;

    EXEC Layercake.usp_load_fact_contact_payment @run_id = 'A0000000-0000-0000-0000-000000000052';

    SELECT legal_entity, fo_transaction_recid
    INTO #Actual
    FROM Layercake.fact_contact_payment;

    SELECT * INTO #Expected FROM (VALUES
        (CAST(N'gb01' AS nvarchar(4)), CAST(12001 AS bigint))
    ) AS v(legal_entity, fo_transaction_recid);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD002.[test TC-002-006 load with no in-scope source rows leaves the dataset empty]
AS
BEGIN
    EXEC tSQLt.FakeTable 'Layercake.fact_contact_payment';

    INSERT INTO Layercake.fact_contact_payment (legal_entity, fo_transaction_recid, account_number, contact_number, is_corporate, payment_date, payment_year, payment_month,
        amount_paid_currency, currency_code, amount_paid_gbp, payment_method_code, payment_method, country_name, region_name, market_reporting_region, run_id, created_at, updated_at)
    VALUES (N'gb01', 99001, N'ACME01', NULL, 1, '2020-01-10', 2020, 1, 10.000000, N'GBP', 10.000000, N'DD', N'Direct Debit', N'Unknown', N'Unknown', 'Unknown',
            'A0000000-0000-0000-0000-000000000060', '2020-01-11T00:00:00', '2020-01-11T00:00:00');

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, PARTITION, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE, PAYMMODE, CANCELLEDPAYMENT)
    VALUES (N'gb01', 5637144576, 99002, N'T900001', 15, -999.00, -999.00, N'GBP', NULL, '2024-03-31', N'DD', 0);

    EXEC Layercake.usp_load_fact_contact_payment @run_id = 'A0000000-0000-0000-0000-000000000061';

    EXEC tSQLt.AssertEmptyTable 'Layercake.fact_contact_payment';
END;
GO

CREATE PROCEDURE test_MOD002.[test TC-002-007 second load with unchanged sources leaves row counts and totals per legal entity unchanged]
AS
BEGIN
    EXEC tSQLt.FakeTable 'Layercake.fact_contact_payment';

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, PARTITION, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE, PAYMMODE, CANCELLEDPAYMENT)
    VALUES (N'gb01', 5637144576, 7001, N'C100001', 15, -100.00, -85.00, N'EUR', NULL, '2024-03-31', N'DD', 0),
           (N'gb01', 5637144576, 7002, N'ACME01', 15, -250.00, -250.00, N'GBP', NULL, '2024-03-31', N'DD', 0),
           (N'gb01', 5637144576, 7003, N'C100001', 15, 30.00, 30.00, N'GBP', NULL, '2024-04-01', N'DD', 0),
           (N'us01', 5637144576, 7004, N'C100001', 15, -200.00, -160.00, N'USD', NULL, '2024-03-31', N'DD', 0),
           (N'us01', 5637144576, 7005, N'ACME02', 15, -40.00, -32.00, N'USD', NULL, '2024-03-31', N'DD', 0);

    EXEC Layercake.usp_load_fact_contact_payment @run_id = 'A0000000-0000-0000-0000-000000000071';

    SELECT legal_entity, COUNT(*) AS row_count, SUM(amount_paid_currency) AS total_currency, SUM(amount_paid_gbp) AS total_gbp
    INTO #AfterFirst
    FROM Layercake.fact_contact_payment
    GROUP BY legal_entity;

    EXEC Layercake.usp_load_fact_contact_payment @run_id = 'A0000000-0000-0000-0000-000000000072';

    SELECT legal_entity, COUNT(*) AS row_count, SUM(amount_paid_currency) AS total_currency, SUM(amount_paid_gbp) AS total_gbp
    INTO #Actual
    FROM Layercake.fact_contact_payment
    GROUP BY legal_entity;

    SELECT * INTO #Expected FROM (VALUES
        (CAST(N'gb01' AS nvarchar(4)), 3, CAST(320.000000 AS decimal(38,6)), CAST(305.000000 AS decimal(38,6))),
        (N'us01', 2, 240.000000, 192.000000)
    ) AS v(legal_entity, row_count, total_currency, total_gbp);

    EXEC tSQLt.AssertEqualsTable '#AfterFirst', '#Actual';
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD002.[test TC-002-008 rerun keeps one row per payment, all stamped with the latest run_id]
AS
BEGIN
    EXEC tSQLt.FakeTable 'Layercake.fact_contact_payment';

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, PARTITION, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE, PAYMMODE, CANCELLEDPAYMENT)
    VALUES (N'gb01', 5637144576, 8101, N'C100001', 15, -100.00, -100.00, N'GBP', NULL, '2024-03-31', N'DD', 0),
           (N'us01', 5637144576, 8102, N'ACME02', 15, -40.00, -32.00, N'USD', NULL, '2024-03-31', N'DD', 0);

    EXEC Layercake.usp_load_fact_contact_payment @run_id = 'A0000000-0000-0000-0000-000000000081';
    EXEC Layercake.usp_load_fact_contact_payment @run_id = 'A0000000-0000-0000-0000-000000000082';

    SELECT legal_entity, fo_transaction_recid, run_id
    INTO #Actual
    FROM Layercake.fact_contact_payment;

    SELECT * INTO #Expected FROM (VALUES
        (CAST(N'gb01' AS nvarchar(4)), CAST(8101 AS bigint), CAST('A0000000-0000-0000-0000-000000000082' AS uniqueidentifier)),
        (N'us01', 8102, 'A0000000-0000-0000-0000-000000000082')
    ) AS v(legal_entity, fo_transaction_recid, run_id);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD002.[test TC-002-009 successful load logs an ended etl_run_log entry under its run_id with rows deleted and inserted]
AS
BEGIN
    EXEC tSQLt.FakeTable 'Layercake.fact_contact_payment';
    DECLARE @run_id uniqueidentifier = 'A0000000-0000-0000-0000-000000000091';

    INSERT INTO Layercake.fact_contact_payment (legal_entity, fo_transaction_recid, account_number, contact_number, is_corporate, payment_date, payment_year, payment_month,
        amount_paid_currency, currency_code, amount_paid_gbp, payment_method_code, payment_method, country_name, region_name, market_reporting_region, run_id, created_at, updated_at)
    VALUES (N'gb01', 99101, N'ACME01', NULL, 1, '2020-01-10', 2020, 1, 10.000000, N'GBP', 10.000000, N'DD', N'Direct Debit', N'Unknown', N'Unknown', 'Unknown',
            'A0000000-0000-0000-0000-000000000090', '2020-01-11T00:00:00', '2020-01-11T00:00:00'),
           (N'gb01', 99102, N'ACME01', NULL, 1, '2020-01-12', 2020, 1, 20.000000, N'GBP', 20.000000, N'DD', N'Direct Debit', N'Unknown', N'Unknown', 'Unknown',
            'A0000000-0000-0000-0000-000000000090', '2020-01-13T00:00:00', '2020-01-13T00:00:00');

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, PARTITION, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE, PAYMMODE, CANCELLEDPAYMENT)
    VALUES (N'gb01', 5637144576, 9201, N'C100001', 15, -100.00, -100.00, N'GBP', NULL, '2024-03-31', N'DD', 0),
           (N'gb01', 5637144576, 9202, N'ACME01', 15, -50.00, -50.00, N'GBP', NULL, '2024-03-31', N'DD', 0),
           (N'us01', 5637144576, 9203, N'ACME02', 15, -40.00, -32.00, N'USD', NULL, '2024-03-31', N'DD', 0);

    EXEC Layercake.usp_load_fact_contact_payment @run_id = @run_id;

    SELECT run_id, status, rows_inserted, rows_deleted,
           CASE WHEN started_at IS NULL THEN 0 ELSE 1 END AS has_started_at
    INTO #Actual
    FROM Layercake.etl_run_log
    WHERE run_id = @run_id AND finished_at IS NOT NULL;

    SELECT * INTO #Expected FROM (VALUES
        (CAST('A0000000-0000-0000-0000-000000000091' AS uniqueidentifier), CAST('Success' AS varchar(10)), 3, 2, 1)
    ) AS v(run_id, status, rows_inserted, rows_deleted, has_started_at);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

--[@tSQLt:NoTransaction](DEFAULT)
CREATE PROCEDURE test_MOD002.[test TC-002-010 failing load re-raises, logs the error and a failed run, and leaves the previous dataset in place]
AS
BEGIN
    DECLARE @pk_name sysname = (
        SELECT kc.name
        FROM sys.key_constraints AS kc
        WHERE kc.parent_object_id = OBJECT_ID(N'Layercake.fact_contact_payment') AND kc.type = 'PK');

    EXEC tSQLt.FakeTable 'Layercake.fact_contact_payment';
    EXEC tSQLt.ApplyConstraint 'Layercake.fact_contact_payment', @pk_name;

    DECLARE @run_ok uniqueidentifier = 'A0000000-0000-0000-0000-000000000101';
    DECLARE @run_fail uniqueidentifier = 'A0000000-0000-0000-0000-000000000102';

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, PARTITION, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE, PAYMMODE, CANCELLEDPAYMENT)
    VALUES (N'gb01', 5637144576, 6001, N'C100001', 15, -100.00, -100.00, N'GBP', NULL, '2024-03-31', N'DD', 0);

    EXEC Layercake.usp_load_fact_contact_payment @run_id = @run_ok;

    SELECT * INTO #Before FROM Layercake.fact_contact_payment;
    DECLARE @ok_status varchar(10) = (SELECT MAX(status) FROM Layercake.etl_run_log WHERE run_id = @run_ok AND finished_at IS NOT NULL);

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, PARTITION, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE, PAYMMODE, CANCELLEDPAYMENT)
    VALUES (N'gb01', 5637144576, 6002, N'ACME01', 15, -20.00, -20.00, N'GBP', NULL, '2024-04-01', N'DD', 0),
           (N'gb01', 5637144576, 6002, N'ACME01', 15, -20.00, -20.00, N'GBP', NULL, '2024-04-01', N'DD', 0);

    DECLARE @error_number int = NULL;
    BEGIN TRY
        EXEC Layercake.usp_load_fact_contact_payment @run_id = @run_fail;
        EXEC tSQLt.Fail 'The load did not raise an error for a duplicate legal_entity and fo_transaction_recid';
    END TRY
    BEGIN CATCH
        SET @error_number = ERROR_NUMBER();
        IF @error_number <> 2627
            THROW;
    END CATCH;

    EXEC tSQLt.AssertEquals 2627, @error_number, 'primary key violation must reach the caller';

    DECLARE @logged_errors int = (SELECT COUNT(*) FROM audit.ErrorLog WHERE ErrorNumber = 2627);
    EXEC tSQLt.AssertEquals 1, @logged_errors, 'audit.ErrorLog must hold one row for the error';

    DECLARE @fail_status varchar(10) = (SELECT MAX(status) FROM Layercake.etl_run_log WHERE run_id = @run_fail AND finished_at IS NOT NULL);
    EXEC tSQLt.AssertEqualsString 'Success', @ok_status, 'the successful run must be ended as Success in Layercake.etl_run_log';
    EXEC tSQLt.AssertEqualsString 'Failed', @fail_status, 'the failed run must be ended as Failed in Layercake.etl_run_log';

    SELECT * INTO #After FROM Layercake.fact_contact_payment;
    EXEC tSQLt.AssertEqualsTable '#Before', '#After';
END;
GO

CREATE PROCEDURE test_MOD002.[test TC-002-011 country change in brnz_contact restates every payment of the contact on the next load]
AS
BEGIN
    EXEC tSQLt.FakeTable 'Layercake.fact_contact_payment';

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, PARTITION, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE, PAYMMODE, CANCELLEDPAYMENT)
    VALUES (N'gb01', 5637144576, 10001, N'C100001', 15, -100.00, -100.00, N'GBP', '2019-06-15', '2019-06-20', N'DD', 0),
           (N'gb01', 5637144576, 10002, N'C100001', 15, -120.00, -120.00, N'GBP', NULL, '2024-03-31', N'DD', 0);

    EXEC Layercake.usp_load_fact_contact_payment @run_id = 'A0000000-0000-0000-0000-000000000111';

    UPDATE Layercake.brnz_contact
    SET rics_countryid = '22222222-2222-2222-2222-222222222222'
    WHERE Rics_contactno = N'C100001';

    EXEC Layercake.usp_load_fact_contact_payment @run_id = 'A0000000-0000-0000-0000-000000000112';

    SELECT fo_transaction_recid, payment_date, country_name, region_name, market_reporting_region
    INTO #Actual
    FROM Layercake.fact_contact_payment;

    SELECT * INTO #Expected FROM (VALUES
        (CAST(10001 AS bigint), CAST('2019-06-15' AS date), CAST(N'Germany' AS nvarchar(200)), CAST(N'Central Europe' AS nvarchar(200)), CAST('DACH' AS varchar(15))),
        (10002, '2024-03-31', N'Germany', N'Central Europe', 'DACH')
    ) AS v(fo_transaction_recid, payment_date, country_name, region_name, market_reporting_region);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD002.[test TC-002-012 gb01 dataset holds 3 rows totalling 120.00 GBP with the test account excluded]
AS
BEGIN
    EXEC tSQLt.FakeTable 'Layercake.fact_contact_payment';

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, PARTITION, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE, PAYMMODE, CANCELLEDPAYMENT)
    VALUES (N'gb01', 5637144576, 8001, N'C100001', 15, -100.00, -100.00, N'GBP', NULL, '2024-03-31', N'DD', 0),
           (N'gb01', 5637144576, 8002, N'C100001', 15, -50.00, -50.00, N'GBP', NULL, '2024-03-31', N'DD', 0),
           (N'gb01', 5637144576, 8003, N'ACME01', 15, 30.00, 30.00, N'GBP', NULL, '2024-03-31', N'DD', 0),
           (N'gb01', 5637144576, 8004, N'T900001', 15, -999.00, -999.00, N'GBP', NULL, '2024-03-31', N'DD', 0);

    EXEC Layercake.usp_load_fact_contact_payment @run_id = 'A0000000-0000-0000-0000-000000000121';

    SELECT legal_entity, COUNT(*) AS row_count, SUM(amount_paid_gbp) AS total_gbp
    INTO #Actual
    FROM Layercake.fact_contact_payment
    GROUP BY legal_entity;

    SELECT * INTO #Expected FROM (VALUES
        (CAST(N'gb01' AS nvarchar(4)), 3, CAST(120.000000 AS decimal(38,6)))
    ) AS v(legal_entity, row_count, total_gbp);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD002.[test TC-002-013 payment with null account, amounts, currency and dates is loaded, not rejected]
AS
BEGIN
    EXEC tSQLt.FakeTable 'Layercake.fact_contact_payment';

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, PARTITION, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE, PAYMMODE, CANCELLEDPAYMENT)
    VALUES (N'gb01', 5637144576, 13001, NULL, 15, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

    EXEC Layercake.usp_load_fact_contact_payment @run_id = 'A0000000-0000-0000-0000-000000000131';

    SELECT legal_entity, fo_transaction_recid, account_number, contact_number, is_corporate, payment_date, payment_year, payment_month,
           amount_paid_currency, currency_code, amount_paid_gbp, payment_method_code, payment_method, country_name, region_name, market_reporting_region
    INTO #Actual
    FROM Layercake.fact_contact_payment;

    SELECT * INTO #Expected FROM (VALUES
        (CAST(N'gb01' AS nvarchar(4)), CAST(13001 AS bigint), CAST(NULL AS nvarchar(20)), CAST(NULL AS nvarchar(100)), CAST(1 AS bit), CAST(NULL AS date), CAST(NULL AS int), CAST(NULL AS tinyint),
         CAST(NULL AS decimal(32,6)), CAST(NULL AS nvarchar(3)), CAST(NULL AS decimal(32,6)), CAST(N'Unknown' AS nvarchar(10)), CAST(N'Unknown' AS nvarchar(60)), CAST(N'Unknown' AS nvarchar(200)), CAST(N'Unknown' AS nvarchar(200)), CAST('Unknown' AS varchar(15)))
    ) AS v(legal_entity, fo_transaction_recid, account_number, contact_number, is_corporate, payment_date, payment_year, payment_month,
           amount_paid_currency, currency_code, amount_paid_gbp, payment_method_code, payment_method, country_name, region_name, market_reporting_region);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD002.[test TC-002-014 amount_paid_currency totals per legal entity and currency equal minus the FO AMOUNTCUR totals]
AS
BEGIN
    EXEC tSQLt.FakeTable 'Layercake.fact_contact_payment';

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, PARTITION, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE, PAYMMODE, CANCELLEDPAYMENT)
    VALUES (N'us01', 5637144576, 9001, N'ACME02', 15, -200.00, -150.00, N'USD', NULL, '2024-03-31', N'DD', 0),
           (N'us01', 5637144576, 9002, N'C100001', 15, -40.00, -30.00, N'USD', NULL, '2024-03-31', N'DD', 0),
           (N'us01', 5637144576, 9005, N'T900001', 15, -999.00, -750.00, N'USD', NULL, '2024-03-31', N'DD', 0),
           (N'gb01', 5637144576, 9003, N'C100001', 15, -100.00, -85.00, N'EUR', NULL, '2024-03-31', N'DD', 0),
           (N'gb01', 5637144576, 9004, N'ACME01', 15, -250.00, -250.00, N'GBP', NULL, '2024-03-31', N'DD', 0);

    EXEC Layercake.usp_load_fact_contact_payment @run_id = 'A0000000-0000-0000-0000-000000000141';

    SELECT legal_entity, currency_code, SUM(amount_paid_currency) AS total_currency
    INTO #Actual
    FROM Layercake.fact_contact_payment
    GROUP BY legal_entity, currency_code;

    SELECT * INTO #Expected FROM (VALUES
        (CAST(N'us01' AS nvarchar(4)), CAST(N'USD' AS nvarchar(3)), CAST(240.000000 AS decimal(38,6))),
        (N'gb01', N'EUR', 100.000000),
        (N'gb01', N'GBP', 250.000000)
    ) AS v(legal_entity, currency_code, total_currency);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD002.[test TC-002-015 amounts keep six decimal places without rounding]
AS
BEGIN
    EXEC tSQLt.FakeTable 'Layercake.fact_contact_payment';

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, PARTITION, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, DOCUMENTDATE, TRANSDATE, PAYMMODE, CANCELLEDPAYMENT)
    VALUES (N'gb01', 5637144576, 9101, N'ACME01', 15, -12.345678, -10.987654, N'EUR', NULL, '2024-03-31', N'DD', 0),
           (N'gb01', 5637144576, 9102, N'ACME01', 15, -0.000001, -0.000001, N'GBP', NULL, '2024-03-31', N'DD', 0);

    EXEC Layercake.usp_load_fact_contact_payment @run_id = 'A0000000-0000-0000-0000-000000000151';

    SELECT fo_transaction_recid, amount_paid_currency, amount_paid_gbp
    INTO #Actual
    FROM Layercake.fact_contact_payment;

    SELECT * INTO #Expected FROM (VALUES
        (CAST(9101 AS bigint), CAST(12.345678 AS decimal(32,6)), CAST(10.987654 AS decimal(32,6))),
        (9102, 0.000001, 0.000001)
    ) AS v(fo_transaction_recid, amount_paid_currency, amount_paid_gbp);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD002.[test TC-002-016 usp_load_gold runs the payment load once with its run_id after every dimension load]
AS
BEGIN
    CREATE TABLE #calls (seq int IDENTITY(1, 1), step sysname NOT NULL);

    DECLARE @steps TABLE (step sysname NOT NULL);
    INSERT INTO @steps (step)
    VALUES (N'usp_load_dim_membership_grade'), (N'usp_load_dim_assessment_route'), (N'usp_load_dim_rpq_variant'),
           (N'usp_load_dim_country'), (N'usp_load_dim_gender'), (N'usp_load_dim_membership_status'),
           (N'usp_load_dim_lapse_reason'), (N'usp_load_dim_campaign_year'), (N'usp_load_dim_date'),
           (N'usp_load_fact_membership_events'), (N'usp_load_fact_daily_member_count_detail'),
           (N'usp_load_fact_annual_rate_base'), (N'usp_load_fact_contact_payment');

    DECLARE @step sysname, @proc nvarchar(300), @cmd nvarchar(400);
    DECLARE steps CURSOR LOCAL FAST_FORWARD FOR SELECT step FROM @steps;
    OPEN steps;
    FETCH NEXT FROM steps INTO @step;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @proc = N'Layercake.' + @step;
        SET @cmd = N'INSERT INTO #calls (step) VALUES (N''' + @step + N''');';
        EXEC tSQLt.SpyProcedure @ProcedureName = @proc, @CommandToExecute = @cmd;
        FETCH NEXT FROM steps INTO @step;
    END;
    CLOSE steps;
    DEALLOCATE steps;

    DECLARE @run_id uniqueidentifier = 'A0000000-0000-0000-0000-000000000161';
    EXEC Layercake.usp_load_gold @run_id = @run_id;

    SELECT run_id INTO #Actual FROM Layercake.usp_load_fact_contact_payment_SpyProcedureLog;
    SELECT * INTO #Expected FROM (VALUES (CAST('A0000000-0000-0000-0000-000000000161' AS uniqueidentifier))) AS v(run_id);
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';

    DECLARE @payment_seq int = (SELECT MIN(seq) FROM #calls WHERE step = N'usp_load_fact_contact_payment');
    DECLARE @last_dim_seq int = (SELECT MAX(seq) FROM #calls WHERE step LIKE N'usp[_]load[_]dim[_]%');
    DECLARE @dim_calls int = (SELECT COUNT(DISTINCT step) FROM #calls WHERE step LIKE N'usp[_]load[_]dim[_]%');
    EXEC tSQLt.AssertEquals 9, @dim_calls, 'usp_load_gold must still run all nine dimension loads';
    IF @payment_seq IS NULL OR @last_dim_seq IS NULL OR @payment_seq < @last_dim_seq
        EXEC tSQLt.Fail 'usp_load_fact_contact_payment must run after every dimension load';
END;
GO

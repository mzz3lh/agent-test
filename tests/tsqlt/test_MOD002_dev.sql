EXEC tSQLt.NewTestClass 'test_MOD002_dev';
GO

CREATE PROCEDURE test_MOD002_dev.[SetUp]
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
END;
GO

CREATE PROCEDURE test_MOD002_dev.[test load logs layer gold, its step name and counts inserted 2, updated 0, deleted 1]
AS
BEGIN
    EXEC tSQLt.FakeTable 'Layercake.fact_contact_payment';

    INSERT INTO Layercake.fact_contact_payment (legal_entity, fo_transaction_recid, is_corporate, payment_method_code, payment_method,
        country_name, region_name, market_reporting_region, run_id, created_at, updated_at)
    VALUES (N'gb01', 1, 1, N'DD', N'DD', N'Unknown', N'Unknown', 'Unknown',
            'B0000000-0000-0000-0000-000000000000', '2020-01-01T00:00:00', '2020-01-01T00:00:00');

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, PARTITION, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE, PAYMMODE)
    VALUES (N'gb01', 5637144576, 2, N'ACME01', 15, -10.00, -10.00, N'GBP', '2024-01-01', N'DD'),
           (N'gb01', 5637144576, 3, N'ACME01', 15, -20.00, -20.00, N'GBP', '2024-01-02', N'DD');

    EXEC Layercake.usp_load_fact_contact_payment @run_id = 'B0000000-0000-0000-0000-000000000001';

    SELECT run_id, layer, step_name, status, rows_inserted, rows_updated, rows_deleted, error_message
    INTO #Actual
    FROM Layercake.etl_run_log;

    SELECT * INTO #Expected FROM (VALUES
        (CAST('B0000000-0000-0000-0000-000000000001' AS uniqueidentifier), CAST('gold' AS varchar(12)), CAST('fact_contact_payment' AS varchar(128)),
         CAST('Success' AS varchar(10)), 2, 0, 1, CAST(NULL AS nvarchar(4000)))
    ) AS v(run_id, layer, step_name, status, rows_inserted, rows_updated, rows_deleted, error_message);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE test_MOD002_dev.[test every row of a run gets one shared stamp with created_at equal to updated_at]
AS
BEGIN
    EXEC tSQLt.FakeTable 'Layercake.fact_contact_payment';

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, PARTITION, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE, PAYMMODE)
    VALUES (N'gb01', 5637144576, 2, N'ACME01', 15, -10.00, -10.00, N'GBP', '2024-01-01', N'DD'),
           (N'us01', 5637144576, 3, N'ACME02', 15, -20.00, -16.00, N'USD', '2024-01-02', N'DD');

    EXEC Layercake.usp_load_fact_contact_payment @run_id = 'B0000000-0000-0000-0000-000000000002';

    DECLARE @distinct_stamps int = (SELECT COUNT(DISTINCT created_at) FROM Layercake.fact_contact_payment);
    DECLARE @unequal int = (SELECT COUNT(*) FROM Layercake.fact_contact_payment WHERE created_at <> updated_at);
    DECLARE @rows int = (SELECT COUNT(*) FROM Layercake.fact_contact_payment);

    EXEC tSQLt.AssertEquals 2, @rows;
    EXEC tSQLt.AssertEquals 1, @distinct_stamps, 'one load timestamp per run';
    EXEC tSQLt.AssertEquals 0, @unequal, 'updated_at equals created_at under a full rebuild';
END;
GO

CREATE PROCEDURE test_MOD002_dev.[test load called without run_id generates one and logs under it]
AS
BEGIN
    EXEC tSQLt.FakeTable 'Layercake.fact_contact_payment';

    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, PARTITION, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE, PAYMMODE)
    VALUES (N'gb01', 5637144576, 2, N'ACME01', 15, -10.00, -10.00, N'GBP', '2024-01-01', N'DD');

    EXEC Layercake.usp_load_fact_contact_payment;

    DECLARE @matching int = (
        SELECT COUNT(*)
        FROM Layercake.fact_contact_payment AS f
        JOIN Layercake.etl_run_log AS l ON l.run_id = f.run_id
        WHERE f.run_id IS NOT NULL AND l.status = 'Success');
    EXEC tSQLt.AssertEquals 1, @matching, 'the row and the log entry share the generated run_id';
END;
GO

--[@tSQLt:NoTransaction](DEFAULT)
CREATE PROCEDURE test_MOD002_dev.[test failed load logs zero counts, the error text, an ErrorLog row without LoadId and keeps the target]
AS
BEGIN
    DECLARE @pk_name sysname = (
        SELECT kc.name
        FROM sys.key_constraints AS kc
        WHERE kc.parent_object_id = OBJECT_ID(N'Layercake.fact_contact_payment') AND kc.type = 'PK');

    EXEC tSQLt.FakeTable 'Layercake.fact_contact_payment';
    EXEC tSQLt.ApplyConstraint 'Layercake.fact_contact_payment', @pk_name;

    INSERT INTO Layercake.fact_contact_payment (legal_entity, fo_transaction_recid, is_corporate, payment_method_code, payment_method,
        country_name, region_name, market_reporting_region, run_id, created_at, updated_at)
    VALUES (N'gb01', 1, 1, N'DD', N'DD', N'Unknown', N'Unknown', 'Unknown',
            'B0000000-0000-0000-0000-000000000000', '2020-01-01T00:00:00', '2020-01-01T00:00:00');

    -- the same legal entity and RECID twice: the primary key rejects the rebuild
    INSERT INTO synapse_fo.CUSTTRANS (DATAAREAID, PARTITION, RECID, ACCOUNTNUM, TRANSTYPE, AMOUNTCUR, AMOUNTMST, CURRENCYCODE, TRANSDATE, PAYMMODE)
    VALUES (N'gb01', 5637144576, 2, N'ACME01', 15, -10.00, -10.00, N'GBP', '2024-01-01', N'DD'),
           (N'gb01', 5637144576, 2, N'ACME01', 15, -10.00, -10.00, N'GBP', '2024-01-01', N'DD');

    BEGIN TRY
        EXEC Layercake.usp_load_fact_contact_payment @run_id = 'B0000000-0000-0000-0000-000000000004';
        EXEC tSQLt.Fail 'The load did not raise the primary key violation';
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() <> 2627
            THROW;
    END CATCH;

    SELECT status, rows_inserted, rows_updated, rows_deleted,
           CASE WHEN error_message LIKE N'%(error 2627, line %' THEN 1 ELSE 0 END AS has_error_text,
           CASE WHEN finished_at IS NULL THEN 0 ELSE 1 END AS is_ended
    INTO #ActualLog
    FROM Layercake.etl_run_log
    WHERE run_id = 'B0000000-0000-0000-0000-000000000004';

    SELECT * INTO #ExpectedLog FROM (VALUES
        (CAST('Failed' AS varchar(10)), 0, 0, 0, 1, 1)
    ) AS v(status, rows_inserted, rows_updated, rows_deleted, has_error_text, is_ended);
    EXEC tSQLt.AssertEqualsTable '#ExpectedLog', '#ActualLog';

    -- ERROR_PROCEDURE() may or may not be schema-qualified, so match the name's end
    SELECT LoadId, ErrorNumber,
           CASE WHEN ProcedureName LIKE N'%usp[_]load[_]fact[_]contact[_]payment' THEN 1 ELSE 0 END AS is_load_procedure
    INTO #ActualError
    FROM audit.ErrorLog;

    SELECT * INTO #ExpectedError FROM (VALUES
        (CAST(NULL AS int), 2627, 1)
    ) AS v(LoadId, ErrorNumber, is_load_procedure);
    EXEC tSQLt.AssertEqualsTable '#ExpectedError', '#ActualError';

    SELECT legal_entity, fo_transaction_recid, run_id
    INTO #ActualTarget
    FROM Layercake.fact_contact_payment;

    SELECT * INTO #ExpectedTarget FROM (VALUES
        (CAST(N'gb01' AS nvarchar(4)), CAST(1 AS bigint), CAST('B0000000-0000-0000-0000-000000000000' AS uniqueidentifier))
    ) AS v(legal_entity, fo_transaction_recid, run_id);
    EXEC tSQLt.AssertEqualsTable '#ExpectedTarget', '#ActualTarget';
END;
GO

CREATE PROCEDURE test_MOD002_dev.[test usp_load_gold runs the payment load last, after the existing facts]
AS
BEGIN
    CREATE TABLE #calls (seq int IDENTITY(1, 1), step sysname NOT NULL);

    EXEC tSQLt.SpyProcedure 'Layercake.usp_load_dim_membership_grade';
    EXEC tSQLt.SpyProcedure 'Layercake.usp_load_dim_assessment_route';
    EXEC tSQLt.SpyProcedure 'Layercake.usp_load_dim_rpq_variant';
    EXEC tSQLt.SpyProcedure 'Layercake.usp_load_dim_country';
    EXEC tSQLt.SpyProcedure 'Layercake.usp_load_dim_gender';
    EXEC tSQLt.SpyProcedure 'Layercake.usp_load_dim_membership_status';
    EXEC tSQLt.SpyProcedure 'Layercake.usp_load_dim_lapse_reason';
    EXEC tSQLt.SpyProcedure 'Layercake.usp_load_dim_campaign_year';
    EXEC tSQLt.SpyProcedure 'Layercake.usp_load_dim_date';
    EXEC tSQLt.SpyProcedure 'Layercake.usp_load_fact_membership_events';
    EXEC tSQLt.SpyProcedure 'Layercake.usp_load_fact_daily_member_count_detail';
    EXEC tSQLt.SpyProcedure 'Layercake.usp_load_fact_annual_rate_base',
         @CommandToExecute = N'INSERT INTO #calls (step) VALUES (N''usp_load_fact_annual_rate_base'');';
    EXEC tSQLt.SpyProcedure 'Layercake.usp_load_fact_contact_payment',
         @CommandToExecute = N'INSERT INTO #calls (step) VALUES (N''usp_load_fact_contact_payment'');';

    EXEC Layercake.usp_load_gold @run_id = 'B0000000-0000-0000-0000-000000000005';

    SELECT seq, step INTO #Actual FROM #calls;
    SELECT * INTO #Expected FROM (VALUES
        (1, CAST(N'usp_load_fact_annual_rate_base' AS sysname)),
        (2, N'usp_load_fact_contact_payment')
    ) AS v(seq, step);

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

-- Smoke tests proving tSQLt is installed and can isolate tables.
-- Run: EXEC tSQLt.Run 'test_Smoke';
EXEC tSQLt.NewTestClass 'test_Smoke';
GO
CREATE PROCEDURE test_Smoke.[test tSQLt is installed]
AS
BEGIN
    DECLARE @v nvarchar(100) = (SELECT TOP (1) Version FROM tSQLt.Info());
    EXEC tSQLt.AssertNotEquals @Expected = NULL, @Actual = @v;
END;
GO
CREATE PROCEDURE test_Smoke.[test FakeTable isolates data]
AS
BEGIN
    -- Self-contained so it runs in RICS_Dev and RICS_Test; tSQLt rolls everything back.
    CREATE TABLE test_Smoke.Probe (Id int NOT NULL PRIMARY KEY, Label varchar(10) NOT NULL);
    INSERT test_Smoke.Probe VALUES (1, 'a'), (2, 'b');
    EXEC tSQLt.FakeTable 'test_Smoke.Probe';
    INSERT test_Smoke.Probe (Id) VALUES (3);   -- NOT NULL dropped by FakeTable
    DECLARE @n int = (SELECT COUNT(*) FROM test_Smoke.Probe);
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @n;
END;
GO

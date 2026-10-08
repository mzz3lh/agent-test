-- MIG-0000 (down): removes the migration framework. Refuses to run while any later
-- migration is still applied, and keeps the history by renaming it rather than dropping it.
-- The layer schemas stay: they are environment infrastructure, not part of the history framework.
-- SQLCMD mode.
:on error exit
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO
IF OBJECT_ID(N'etl.MigrationHistory', N'U') IS NULL
BEGIN
    PRINT 'MIG-0000 not present; nothing to roll back.';
    SET NOEXEC ON;
END
GO
IF EXISTS (SELECT 1 FROM etl.vw_MigrationState WHERE MigrationId <> 'MIG-0000' AND CurrentState = 'up')
    THROW 50010, 'Roll back every later migration before MIG-0000.', 1;
GO
BEGIN TRANSACTION;
DROP PROCEDURE IF EXISTS etl.usp_RecordMigration;
DROP FUNCTION IF EXISTS etl.fn_MigrationIsApplied;
DROP VIEW IF EXISTS etl.vw_DatabaseVersion;
DROP VIEW IF EXISTS etl.vw_MigrationState;
EXEC sp_rename N'etl.MigrationHistory', N'MigrationHistory_rolledback_MIG0000';
COMMIT;
GO
SET NOEXEC OFF;
GO

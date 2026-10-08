-- MIG-0001 (down): removes the load audit framework. Refuses while any later migration is applied.
-- Keeps any logged history: a log table that holds rows is renamed to <Table>_rolledback_MIG0001.
-- SQLCMD mode with -v CommitHash=<git sha>. Safe to run twice.
:on error exit
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO
IF etl.fn_MigrationIsApplied('MIG-0001') = 0
BEGIN
    PRINT 'MIG-0001 not applied; nothing to roll back.';
    SET NOEXEC ON;
END
GO
IF EXISTS (SELECT 1 FROM etl.vw_MigrationState WHERE MigrationId > 'MIG-0001' AND CurrentState = 'up')
    THROW 50011, 'Roll back later migrations before MIG-0001.', 1;
GO
BEGIN TRANSACTION;
GO
DROP PROCEDURE IF EXISTS audit.usp_LogError;
DROP PROCEDURE IF EXISTS audit.usp_EndLoad;
DROP PROCEDURE IF EXISTS audit.usp_StartLoad;
ALTER TABLE audit.ErrorLog DROP CONSTRAINT FK_audit_ErrorLog_LoadLog;
-- Constraint names are unique per schema, so a kept table's constraints are renamed with it,
-- leaving the names free if MIG-0001 is applied again.
IF EXISTS (SELECT 1 FROM audit.ErrorLog)
BEGIN
    EXEC sp_rename N'audit.PK_audit_ErrorLog', N'PK_audit_ErrorLog_rolledback_MIG0001', N'OBJECT';
    EXEC sp_rename N'audit.DF_audit_ErrorLog_LoggedAt', N'DF_audit_ErrorLog_LoggedAt_rolledback_MIG0001', N'OBJECT';
    EXEC sp_rename N'audit.DF_audit_ErrorLog_LoggedBy', N'DF_audit_ErrorLog_LoggedBy_rolledback_MIG0001', N'OBJECT';
    EXEC sp_rename N'audit.ErrorLog', N'ErrorLog_rolledback_MIG0001';
END
ELSE
    DROP TABLE audit.ErrorLog;
IF EXISTS (SELECT 1 FROM audit.LoadLog)
BEGIN
    EXEC sp_rename N'audit.PK_audit_LoadLog', N'PK_audit_LoadLog_rolledback_MIG0001', N'OBJECT';
    EXEC sp_rename N'audit.DF_audit_LoadLog_StartedAt', N'DF_audit_LoadLog_StartedAt_rolledback_MIG0001', N'OBJECT';
    EXEC sp_rename N'audit.DF_audit_LoadLog_Outcome', N'DF_audit_LoadLog_Outcome_rolledback_MIG0001', N'OBJECT';
    EXEC sp_rename N'audit.CK_audit_LoadLog_Outcome', N'CK_audit_LoadLog_Outcome_rolledback_MIG0001', N'OBJECT';
    EXEC sp_rename N'audit.LoadLog', N'LoadLog_rolledback_MIG0001';
END
ELSE
    DROP TABLE audit.LoadLog;
GO
EXEC etl.usp_RecordMigration @MigrationId = 'MIG-0001', @Description = N'Rollback of MIG-0001',
     @Direction = 'down', @ScriptName = N'MIG-0001_bootstrap_audit-tables.down.sql', @CommitHash = '$(CommitHash)';
COMMIT;
GO
SET NOEXEC OFF;
GO

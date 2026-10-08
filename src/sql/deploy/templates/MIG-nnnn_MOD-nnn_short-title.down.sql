-- MIG-nnnn (down) for MOD-nnn: reverses MIG-nnnn_MOD-nnn_short-title.up.sql exactly.
-- Rules (PROJECT_STANDARDS.md 3.1):
--  * Returns the schema to the state before the up script ran.
--  * Never silently destroys data: a table with rows is renamed to <Table>_rolledback_MIGnnnn,
--    unless an ADR records that the data may be dropped.
--  * Refuses to run while any later migration is still applied (rollback in reverse order).
-- Run in SQLCMD mode with -v CommitHash=<git sha>. Safe to run twice.
:on error exit
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO
IF etl.fn_MigrationIsApplied('MIG-nnnn') = 0
BEGIN
    PRINT 'MIG-nnnn not applied; nothing to roll back.';
    SET NOEXEC ON;
END
GO
-- Rollbacks run in reverse order: refuse while any later migration is still applied.
IF EXISTS (SELECT 1 FROM etl.vw_MigrationState WHERE MigrationId > 'MIG-nnnn' AND CurrentState = 'up')
    THROW 50011, 'Roll back later migrations before MIG-nnnn.', 1;
GO
BEGIN TRANSACTION;
GO
-- ===== reversal start (reverse order of the up script) =====
-- ===== reversal end =====
GO
EXEC etl.usp_RecordMigration @MigrationId = 'MIG-nnnn', @ModuleId = 'MOD-nnn',
     @Description = N'Rollback of MIG-nnnn', @Direction = 'down',
     @ScriptName = N'MIG-nnnn_MOD-nnn_short-title.down.sql', @CommitHash = '$(CommitHash)';
COMMIT;
GO
SET NOEXEC OFF;
GO

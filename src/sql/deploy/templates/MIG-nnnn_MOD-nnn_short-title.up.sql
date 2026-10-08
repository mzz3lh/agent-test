-- MIG-nnnn (up) for MOD-nnn: <what this migration changes>. Requirement IDs: REQ-nnn.
-- Copy this file and its .down.sql partner; replace every MIG-nnnn / MOD-nnn / text placeholder.
-- Run in SQLCMD mode with -v CommitHash=<git sha>. Safe to run twice: a second run does nothing.
:on error exit
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO
IF etl.fn_MigrationIsApplied('MIG-nnnn') = 1
BEGIN
    PRINT 'MIG-nnnn already applied; skipping.';
    SET NOEXEC ON;
END
GO
BEGIN TRANSACTION;
GO
-- ===== changes start =====
-- Tables: guarded CREATE / ALTER. Code objects: CREATE OR ALTER (each in its own batch).
-- ===== changes end =====
GO
EXEC etl.usp_RecordMigration @MigrationId = 'MIG-nnnn', @ModuleId = 'MOD-nnn',
     @Description = N'<what this migration changes>', @Direction = 'up',
     @ScriptName = N'MIG-nnnn_MOD-nnn_short-title.up.sql', @CommitHash = '$(CommitHash)';
COMMIT;
GO
SET NOEXEC OFF;
GO

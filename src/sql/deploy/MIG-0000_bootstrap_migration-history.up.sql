-- MIG-0000 (up): migration framework. Creates the layer schemas, the migration history table,
-- the database version views and the helper objects every later migration uses.
-- Schemas are created only here, owned by dbo, by a human admin (base standards 3.1). Agents
-- build objects inside them but never create or own a schema: CREATE SCHEMA ... AUTHORIZATION dbo
-- needs IMPERSONATE on dbo, and an agent-owned schema would give the agent CONTROL (and so GRANT)
-- on everything in it and break ownership chains with dbo-owned schemas.
-- Run once per database (RICS_Dev, RICS_Test, and any later environment) before any other migration.
-- SQLCMD mode. Idempotent: safe to run again.
:on error exit
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO
IF SCHEMA_ID(N'stg')   IS NULL EXEC (N'CREATE SCHEMA stg AUTHORIZATION dbo;');
IF SCHEMA_ID(N'core')  IS NULL EXEC (N'CREATE SCHEMA core AUTHORIZATION dbo;');
IF SCHEMA_ID(N'pres')  IS NULL EXEC (N'CREATE SCHEMA pres AUTHORIZATION dbo;');
IF SCHEMA_ID(N'audit') IS NULL EXEC (N'CREATE SCHEMA audit AUTHORIZATION dbo;');
IF SCHEMA_ID(N'etl')   IS NULL EXEC (N'CREATE SCHEMA etl AUTHORIZATION dbo;');
IF SCHEMA_ID(N'Layercake') IS NULL EXEC (N'CREATE SCHEMA Layercake AUTHORIZATION dbo;');   -- existing solution (baseline)
GO
IF OBJECT_ID(N'etl.MigrationHistory', N'U') IS NULL
CREATE TABLE etl.MigrationHistory (
    MigrationHistoryId int IDENTITY(1, 1) NOT NULL CONSTRAINT PK_etl_MigrationHistory PRIMARY KEY,
    MigrationId        varchar(10)    NOT NULL,
    ModuleId           varchar(10)    NULL,
    Description        nvarchar(200)  NOT NULL,
    Direction          varchar(4)     NOT NULL CONSTRAINT CK_etl_MigrationHistory_Direction CHECK (Direction IN ('up', 'down')),
    ScriptName         nvarchar(260)  NOT NULL,
    CommitHash         varchar(40)    NULL,
    AppliedAt          datetime2(3)   NOT NULL CONSTRAINT DF_etl_MigrationHistory_AppliedAt DEFAULT (SYSUTCDATETIME()),
    AppliedBy          sysname        NOT NULL CONSTRAINT DF_etl_MigrationHistory_AppliedBy DEFAULT (ORIGINAL_LOGIN()),
    CONSTRAINT CK_etl_MigrationHistory_MigrationId CHECK (MigrationId LIKE 'MIG-[0-9][0-9][0-9][0-9]')
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_MigrationHistory_MigrationId_AppliedAt')
CREATE INDEX IX_MigrationHistory_MigrationId_AppliedAt ON etl.MigrationHistory (MigrationId, MigrationHistoryId DESC);
GO
-- Latest state of every migration: applied ('up') or rolled back ('down').
CREATE OR ALTER VIEW etl.vw_MigrationState
AS
SELECT h.MigrationId, h.ModuleId, h.Description, h.Direction AS CurrentState, h.ScriptName,
       h.CommitHash, h.AppliedAt, h.AppliedBy
FROM (
    SELECT mh.*, ROW_NUMBER() OVER (PARTITION BY mh.MigrationId ORDER BY mh.MigrationHistoryId DESC) AS rn
    FROM etl.MigrationHistory AS mh
) AS h
WHERE h.rn = 1;
GO
-- The database version is the highest migration currently applied.
CREATE OR ALTER VIEW etl.vw_DatabaseVersion
AS
SELECT TOP (1) s.MigrationId AS DatabaseVersion, s.ModuleId, s.Description, s.AppliedAt, s.AppliedBy, s.CommitHash
FROM etl.vw_MigrationState AS s
WHERE s.CurrentState = 'up'
ORDER BY s.MigrationId DESC;
GO
CREATE OR ALTER FUNCTION etl.fn_MigrationIsApplied (@MigrationId varchar(10))
RETURNS bit
AS
BEGIN
    RETURN CASE WHEN EXISTS (SELECT 1 FROM etl.vw_MigrationState
                             WHERE MigrationId = @MigrationId AND CurrentState = 'up')
                THEN 1 ELSE 0 END;
END;
GO
CREATE OR ALTER PROCEDURE etl.usp_RecordMigration
    @MigrationId varchar(10),
    @ModuleId    varchar(10) = NULL,
    @Description nvarchar(200),
    @Direction   varchar(4),
    @ScriptName  nvarchar(260),
    @CommitHash  varchar(40) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT etl.MigrationHistory (MigrationId, ModuleId, Description, Direction, ScriptName, CommitHash)
    VALUES (@MigrationId, @ModuleId, @Description, @Direction, @ScriptName, @CommitHash);
END;
GO
IF etl.fn_MigrationIsApplied('MIG-0000') = 0
    EXEC etl.usp_RecordMigration @MigrationId = 'MIG-0000', @Description = N'Migration framework',
         @Direction = 'up', @ScriptName = N'MIG-0000_bootstrap_migration-history.up.sql',
         @CommitHash = '$(CommitHash)';
GO

-- MIG-0001 (up): load audit framework (base standards 3). Creates, in the audit schema (from MIG-0000), the load log
-- and error log every load procedure writes to, and the helper procedures that write them.
-- Part of every project, run once per database right after MIG-0000. Designs reuse these objects;
-- they never redesign them.
-- SQLCMD mode with -v CommitHash=<git sha>. Idempotent: safe to run again.
:on error exit
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO
IF etl.fn_MigrationIsApplied('MIG-0001') = 1
BEGIN
    PRINT 'MIG-0001 already applied.';
    SET NOEXEC ON;
END
GO
BEGIN TRANSACTION;
GO
IF OBJECT_ID(N'audit.LoadLog', N'U') IS NULL
CREATE TABLE audit.LoadLog (
    LoadId        int IDENTITY(1, 1) NOT NULL CONSTRAINT PK_audit_LoadLog PRIMARY KEY,
    ProcessName   nvarchar(256)  NOT NULL,
    ModuleId      varchar(10)    NULL,
    StartedAt     datetime2(3)   NOT NULL CONSTRAINT DF_audit_LoadLog_StartedAt DEFAULT (SYSUTCDATETIME()),
    EndedAt       datetime2(3)   NULL,
    RowsRead      int            NULL,
    RowsInserted  int            NULL,
    RowsUpdated   int            NULL,
    RowsDeleted   int            NULL,
    RowsRejected  int            NULL,
    Outcome       varchar(20)    NOT NULL CONSTRAINT DF_audit_LoadLog_Outcome DEFAULT ('Running'),
    Message       nvarchar(4000) NULL,
    CONSTRAINT CK_audit_LoadLog_Outcome CHECK (Outcome IN ('Running', 'Succeeded', 'Failed'))
);
GO
IF OBJECT_ID(N'audit.ErrorLog', N'U') IS NULL
CREATE TABLE audit.ErrorLog (
    ErrorLogId     int IDENTITY(1, 1) NOT NULL CONSTRAINT PK_audit_ErrorLog PRIMARY KEY,
    LoadId         int            NULL CONSTRAINT FK_audit_ErrorLog_LoadLog REFERENCES audit.LoadLog (LoadId),
    ProcedureName  nvarchar(256)  NULL,
    ErrorNumber    int            NOT NULL,
    ErrorSeverity  int            NOT NULL,
    ErrorState     int            NOT NULL,
    ErrorLine      int            NULL,
    ErrorMessage   nvarchar(4000) NOT NULL,
    LoggedAt       datetime2(3)   NOT NULL CONSTRAINT DF_audit_ErrorLog_LoggedAt DEFAULT (SYSUTCDATETIME()),
    LoggedBy       sysname        NOT NULL CONSTRAINT DF_audit_ErrorLog_LoggedBy DEFAULT (ORIGINAL_LOGIN())
);
GO
-- Start a load: call before the load's transaction, so the row survives a rollback.
CREATE OR ALTER PROCEDURE audit.usp_StartLoad
    @ProcessName nvarchar(256),
    @ModuleId    varchar(10) = NULL,
    @LoadId      int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT audit.LoadLog (ProcessName, ModuleId) VALUES (@ProcessName, @ModuleId);
    SET @LoadId = CAST(SCOPE_IDENTITY() AS int);
END;
GO
-- End a load with its outcome and row counts.
CREATE OR ALTER PROCEDURE audit.usp_EndLoad
    @LoadId       int,
    @Outcome      varchar(20),
    @RowsRead     int = NULL,
    @RowsInserted int = NULL,
    @RowsUpdated  int = NULL,
    @RowsDeleted  int = NULL,
    @RowsRejected int = NULL,
    @Message      nvarchar(4000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE audit.LoadLog
    SET EndedAt = SYSUTCDATETIME(), Outcome = @Outcome, RowsRead = @RowsRead, RowsInserted = @RowsInserted,
        RowsUpdated = @RowsUpdated, RowsDeleted = @RowsDeleted, RowsRejected = @RowsRejected, Message = @Message
    WHERE LoadId = @LoadId;
END;
GO
-- Log the current error. Call inside CATCH after ROLLBACK, then THROW.
CREATE OR ALTER PROCEDURE audit.usp_LogError
    @LoadId int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT audit.ErrorLog (LoadId, ProcedureName, ErrorNumber, ErrorSeverity, ErrorState, ErrorLine, ErrorMessage)
    VALUES (@LoadId, ERROR_PROCEDURE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), ERROR_LINE(),
            COALESCE(ERROR_MESSAGE(), N'(no error message)'));
END;
GO
EXEC etl.usp_RecordMigration @MigrationId = 'MIG-0001', @Description = N'Load audit framework',
     @Direction = 'up', @ScriptName = N'MIG-0001_bootstrap_audit-tables.up.sql', @CommitHash = '$(CommitHash)';
COMMIT;
GO
SET NOEXEC OFF;
GO

-- HUMAN-RUN, once, on a database that ALREADY holds the existing solution (a client environment), after
-- MIG-0000 and MIG-0001. Records MIG-0002 as applied without running it, so module migrations
-- (MIG-0003 onwards) apply on top. Never run it on a blank database: run MIG-0002_bootstrap_phase1-layercake.up.sql there instead.
:on error exit
SET NOCOUNT ON;
GO
IF OBJECT_ID(N'Layercake.brnz_contact', N'U') IS NULL
    THROW 50014, 'This database does not hold the existing solution (Layercake.brnz_contact is missing): run the baseline migration instead.', 1;
GO
IF etl.fn_MigrationIsApplied('MIG-0002') = 0
    EXEC etl.usp_RecordMigration @MigrationId = 'MIG-0002', @ModuleId = NULL,
         @Description = N'Baseline adopted: existing solution (phase1-layercake)', @Direction = 'up',
         @ScriptName = N'MIG-0002_bootstrap_phase1-layercake.up.sql', @CommitHash = '$(CommitHash)';
GO

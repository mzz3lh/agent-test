-- HUMAN-RUN. Creates this project's dev and test databases on the local SQL Server.
-- Run as an admin login. Idempotent. One-time server preparation (CLR for tSQLt) is in the
-- agent team framework: local-sql/00_prepare_server.sql.
-- Both are created with the production database's default collation (project.collation in
-- config/project.yaml), so collation conflicts show here rather than in production. A database created
-- with another collation is dropped and created again: the dev and test databases are rebuilt from the repo.
SET NOCOUNT ON;
IF DB_ID(N'RICS_Dev')  IS NULL CREATE DATABASE [RICS_Dev] COLLATE SQL_Latin1_General_CP1_CI_AS;
IF DB_ID(N'RICS_Test') IS NULL CREATE DATABASE [RICS_Test] COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

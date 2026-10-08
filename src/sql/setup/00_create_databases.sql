-- HUMAN-RUN. Creates this project's dev and test databases on the local SQL Server.
-- Run as an admin login. Idempotent. One-time server preparation (CLR for tSQLt) is in the
-- agent team framework: local-sql/00_prepare_server.sql.
SET NOCOUNT ON;
IF DB_ID(N'RICS_Dev')  IS NULL CREATE DATABASE [RICS_Dev];
IF DB_ID(N'RICS_Test') IS NULL CREATE DATABASE [RICS_Test];
GO

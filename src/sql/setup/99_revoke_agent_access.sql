-- HUMAN-RUN. Emergency stop / teardown: removes every agent user and role from the
-- current database. On SQL Server also disable the logins:
--   ALTER LOGIN [rics_agent_<name>] DISABLE;
SET NOCOUNT ON;
DECLARE @sql nvarchar(max) = N'';
SELECT @sql += N'ALTER ROLE ' + QUOTENAME(r.name) + N' DROP MEMBER ' + QUOTENAME(m.name) + N';' + CHAR(10)
FROM sys.database_role_members rm
JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
WHERE m.name LIKE N'rics[_]agent[_]%' OR m.name LIKE N'agent[_]%';
SELECT @sql += N'DROP USER ' + QUOTENAME(name) + N';' + CHAR(10)
FROM sys.database_principals WHERE type IN ('S','E','X') AND name LIKE N'rics[_]agent[_]%';
SELECT @sql += N'DROP ROLE ' + QUOTENAME(name) + N';' + CHAR(10)
FROM sys.database_principals WHERE type = 'R' AND name LIKE N'agent[_]%';
PRINT @sql;
EXEC (@sql);
GO

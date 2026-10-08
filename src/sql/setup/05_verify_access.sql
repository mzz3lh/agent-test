-- HUMAN-RUN, read-only. Run in each database after setup and attach the output to the
-- access request record. Shows every agent principal, its roles and explicit permissions.
SET NOCOUNT ON;
SELECT DB_NAME() AS database_name, m.name AS member, r.name AS role
FROM sys.database_role_members rm
JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
WHERE m.name LIKE N'agent[_]%' OR m.name LIKE N'rics[_]agent[_]%'
ORDER BY member, role;

SELECT DB_NAME() AS database_name, pr.name AS principal, pe.permission_name, pe.state_desc, pe.class_desc
FROM sys.database_permissions pe
JOIN sys.database_principals pr ON pr.principal_id = pe.grantee_principal_id
WHERE pr.name LIKE N'agent[_]%' OR pr.name LIKE N'rics[_]agent[_]%'
ORDER BY principal, permission_name;

-- Must return zero rows: no agent principal may hold grant-capable roles.
SELECT m.name AS member, r.name AS forbidden_role
FROM sys.database_role_members rm
JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
WHERE r.name IN (N'db_owner', N'db_securityadmin', N'db_accessadmin')
  AND (m.name LIKE N'agent[_]%' OR m.name LIKE N'rics[_]agent[_]%');
GO

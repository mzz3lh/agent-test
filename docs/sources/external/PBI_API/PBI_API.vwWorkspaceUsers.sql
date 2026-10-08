CREATE   VIEW [PBI_API].[vwWorkspaceUsers]
AS
SELECT 
	t1.[id] AS [WorkspaceId],
	t1.[Name] AS [Workspace_Name],
	t1.[capacityId],
	t1.[description],
	t1.[isOnDedicatedCapacity],
	t1.[type],
	t2.[displayName] AS [User_Name],
	t2.[emailAddress],
	t2.[groupUserAccessRight] AS [User_Right],
	t2.[principalType] AS [User_Type]
FROM [PBI_API].[tblWorkspaces] t1
	LEFT JOIN pbi_api.tblworkspaceusers  t2
		ON t1.id = t2.workspaceid

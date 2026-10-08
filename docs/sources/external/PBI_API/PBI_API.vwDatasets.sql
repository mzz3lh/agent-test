CREATE   VIEW [PBI_API].[vwDatasets]
AS
SELECT 
	t1.[id] AS [DatasetId],
	t1.[name] AS [Dtaset_Name],
	t1.[configuredBy],
	t1.[createdDate],
	t1.[contentProviderType],
	t1.[description],
	t1.[isEffectiveIdentityRequired],
	t1.[isEffectiveIdentityRolesRequired],
	t1.[isOnPremGatewayRequired],
	t1.[isRefreshable],
	t2.[id] AS [ReportId],
	t2.[name] AS [Report_Name],
	t2.[reportType] AS [Report_Type],
	t3.[name] AS [Workspace_Name]
FROM PBI_API.tblDatasets T1
	LEFT JOIN PBI_API.tblWorkspaceReports T2
		ON T1.id = t2.datasetId
	LEFT JOIN [PBI_API].[tblWorkspaces] T3
		ON t2.[WorkspaceId] = T3.[id]

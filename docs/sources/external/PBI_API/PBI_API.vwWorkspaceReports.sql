CREATE   VIEW [PBI_API].[vwWorkspaceReports]
AS
SELECT 
	t1.[id] AS [WorkspaceId],
	t1.[Name] AS [Workspace_Name],
	t1.[capacityId],
	t1.[description],
	t1.[isOnDedicatedCapacity],
	t1.[type],
	t2.[datasetid],
	t2.[embedurl],
	t2.[id] AS [ReportId],
	t2.[name] AS [Report_Name],
	t2.[reporttype] AS [Report_Type],
	t2.[webUrl],
	t2.[createdBy],
	t2.[createdDateTime],
	t2.[modifiedBy],
	t2.[modifiedDateTime]

FROM [PBI_API].[tblWorkspaces] t1
	LEFT JOIN pbi_api.tblworkspacereports  t2
		ON t1.id = t2.workspaceid

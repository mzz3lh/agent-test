CREATE   VIEW [PBI_API].[vwActivityEvents]
AS
SELECT
	[Activity],
	[ActivityId],
	[ArtifactName],
	[CapacityId],
	[CapacityName],
	[ClientIP],
	[CreationTime],
	CAST([CreationTime] AS DATE) AS [Activity Date],
	[DataConnectivityMode],
	[DatasetId],
	[DatasetName],
	[Id],
	[IsSuccess],
	[ItemId],
	[ItemName],
	[LastRefreshTime],
	[ModelsSnapshots],
	[ObjectId],
	[Operation],
	[OrganizationId],
	[RecordType],
	[RefreshEnforcementPolicy],
	[RequestId],
	[UserAgent],
	[UserId],
	[UserKey],
	[UserType],
	[Workload],
	[WorkspaceId],
	[WorkSpaceName]
FROM [PBI_API].[tblPBIActivityEvents]
WHERE [Operation] IN
(
	'CreateApp'
	, 'InstallApp'
	, 'CreateReport'
	, 'PrintReport'
	, 'ExportReport'
	, 'CreateFolder'
	, 'ViewReport'
	, 'UpdateApp'
	, 'EditDataset'
	, 'CreateDataset'
	, 'AnalyzeInExcel'
	, 'ExportArtifact'
	, 'RefreshDataset'
	,'ShareReport'
	, 'Import'
	, 'DownloadReport'
	, 'SetScheduledRefresh'
	, 'TakeOverDataset'
	, 'ViewDashboard'
)
AND [UserId] NOT IN (masked@example.invalid', masked@example.invalid')

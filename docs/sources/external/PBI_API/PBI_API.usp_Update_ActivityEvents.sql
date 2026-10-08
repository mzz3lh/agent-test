CREATE   PROCEDURE [PBI_API].[usp_Update_ActivityEvents]
AS
BEGIN

	UPDATE tgt SET
		tgt.[Activity] = src.[Activity],
		tgt.[ActivityId] = src.[ActivityId],
		tgt.[ArtifactName] = src.[ArtifactName],
		tgt.[CapacityId] = src.[CapacityId],
		tgt.[CapacityName] = src.[CapacityName],
		tgt.[ClientIP] = src.[ClientIP],
		tgt.[CreationTime] = src.[CreationTime],
		tgt.[DataConnectivityMode] = src.[DataConnectivityMode],
		tgt.[DatasetId] = src.[DatasetId],
		tgt.[DatasetName] = src.[DatasetName],
		tgt.[IsSuccess] = src.[IsSuccess],
		tgt.[ItemId] = src.[ItemId],
		tgt.[ItemName] = src.[ItemName],
		tgt.[LastRefreshTime] = src.[LastRefreshTime],
		tgt.[ModelsSnapshots] = src.[ModelsSnapshots],
		tgt.[ObjectId] = src.[ObjectId],
		tgt.[Operation] = src.[Operation],
		tgt.[OrganizationId] = src.[OrganizationId],
		tgt.[RecordType] = src.[RecordType],
		tgt.[RefreshEnforcementPolicy] = src.[RefreshEnforcementPolicy],
		tgt.[RequestId] = src.[RequestId],
		tgt.[UserAgent] = src.[UserAgent],
		tgt.[UserId] = src.[UserId],
		tgt.[UserKey] = src.[UserKey],
		tgt.[UserType] = src.[UserType],
		tgt.[Workload] = src.[Workload],
		tgt.[WorkspaceId] = src.[WorkspaceId],
		tgt.[WorkSpaceName] = src.[WorkSpaceName]
	FROM [PBI_API].[tblPBIActivityEvents] tgt
		INNER JOIN
		(
			SELECT
				CAST(src.[Activity] AS NVARCHAR(100)) AS [Activity],
				CAST(src.[ActivityId] AS uniqueidentifier) AS [ActivityId],
				CAST(src.[ArtifactName] AS NVARCHAR(255)) AS [ArtifactName],
				CAST(src.[CapacityId] AS uniqueidentifier) AS [CapacityId],
				CAST(src.[CapacityName] AS NVARCHAR(50)) AS [CapacityName],
				CAST(src.[ClientIP] AS NVARCHAR(25)) AS [ClientIP],
				CAST(src.[CreationTime] AS datetime) AS [CreationTime],
				CAST(src.[DataConnectivityMode] AS NVARCHAR(50)) AS [DataConnectivityMode],
				CAST(src.[DatasetId] AS uniqueidentifier) AS [DatasetId],
				CAST(src.[DatasetName] AS NVARCHAR(100)) AS [DatasetName],
				CAST(src.[Id] AS uniqueidentifier) AS [Id],
				CAST(src.[IsSuccess] AS bit) AS [IsSuccess],
				CAST(src.[ItemId] AS uniqueidentifier) AS [ItemId],
				CAST(src.[ItemName] AS NVARCHAR(100)) AS [ItemName],
				CAST(src.[LastRefreshTime] AS datetime) AS [LastRefreshTime],
				CAST(src.[ModelsSnapshots] AS NVARCHAR(4000)) AS [ModelsSnapshots],
				CAST(src.[ObjectId] AS NVARCHAR(100)) AS [ObjectId],
				CAST(src.[Operation] AS NVARCHAR(100)) AS [Operation],
				CAST(src.[OrganizationId] AS uniqueidentifier) AS [OrganizationId],
				CAST(src.[RecordType] AS int) AS [RecordType],
				CAST(src.[RefreshEnforcementPolicy] AS int) AS [RefreshEnforcementPolicy],
				CAST(src.[RequestId] AS uniqueidentifier) AS [RequestId],
				CAST(src.[UserAgent] AS NVARCHAR(255)) AS [UserAgent],
				CAST(src.[UserId] AS NVARCHAR(100)) AS [UserId],
				CAST(src.[UserKey] AS NVARCHAR(50)) AS [UserKey],
				CAST(src.[UserType] AS int) AS [UserType],
				CAST(src.[Workload] AS NVARCHAR(25)) AS [Workload],
				CAST(src.[WorkspaceId] AS uniqueidentifier) AS [WorkspaceId],
				CAST(src.[WorkSpaceName] AS NVARCHAR(100)) AS [WorkSpaceName]
			FROM [Work].[tblPBIActivityEvents_PBI_API] src
		) src
		ON src.[Id] = tgt.[Id]

END

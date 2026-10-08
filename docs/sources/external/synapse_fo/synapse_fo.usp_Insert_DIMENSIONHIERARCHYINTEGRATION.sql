CREATE     PROCEDURE [synapse_fo].[usp_Insert_DIMENSIONHIERARCHYINTEGRATION]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:44
	Description: Insert stored procedure for DIMENSIONHIERARCHYINTEGRATION from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[DIMENSIONHIERARCHYINTEGRATION]
	(
		[DataLakeModified_DateTime],
		[DIMENSIONHIERARCHY],
		[DISPLAYSTRING],
		--[FileName],
		[ISDEFAULT],
		[LastProcessedChange_DateTime],
		--[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[DataLakeModified_DateTime],
		stg.[DIMENSIONHIERARCHY],
		stg.[DISPLAYSTRING],
		--stg.--[FileName],
		stg.[ISDEFAULT],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[DIMENSIONHIERARCHYINTEGRATION] stg
		LEFT JOIN [synapse_fo].[DIMENSIONHIERARCHYINTEGRATION] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

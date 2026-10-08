CREATE     PROCEDURE [synapse_fo].[usp_Insert_DIMENSIONHIERARCHYLEVEL]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:44
	Description: Insert stored procedure for DIMENSIONHIERARCHYLEVEL from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[DIMENSIONHIERARCHYLEVEL]
	(
		[CREATEDBY],
		[CREATEDDATETIME],
		[DataLakeModified_DateTime],
		[DIMENSIONATTRIBUTE],
		[DIMENSIONHIERARCHY],
		--[FileName],
		[LastProcessedChange_DateTime],
		--[LEVEL_],
		--[LSN],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[PARTITION],
		[RECID],
		[RECVERSION],
		--[SysRowId],
		[TEMPORARYDIMENSIONHIERARCHYLEVEL]
	)
	SELECT 
		stg.[CREATEDBY],
		stg.[CREATEDDATETIME],
		stg.[DataLakeModified_DateTime],
		stg.[DIMENSIONATTRIBUTE],
		stg.[DIMENSIONHIERARCHY],
		--stg.--[FileName],
		stg.[LastProcessedChange_DateTime],
		--stg.[LEVEL_],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		--stg.--[SysRowId],
		stg.[TEMPORARYDIMENSIONHIERARCHYLEVEL]	
	FROM [staging_fo].[DIMENSIONHIERARCHYLEVEL] stg
		LEFT JOIN [synapse_fo].[DIMENSIONHIERARCHYLEVEL] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

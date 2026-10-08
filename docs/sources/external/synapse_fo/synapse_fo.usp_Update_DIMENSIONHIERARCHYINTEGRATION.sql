CREATE     PROCEDURE [synapse_fo].[usp_Update_DIMENSIONHIERARCHYINTEGRATION]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:37
	Description: Update stored procedure for DIMENSIONHIERARCHYINTEGRATION from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DIMENSIONHIERARCHY] = stg.[DIMENSIONHIERARCHY],
		tgt.[DISPLAYSTRING] = stg.[DISPLAYSTRING],
		--tgt.[FileName] = stg.[FileName],
		tgt.[ISDEFAULT] = stg.[ISDEFAULT],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[DIMENSIONHIERARCHYINTEGRATION] tgt
		INNER JOIN [staging_fo].[DIMENSIONHIERARCHYINTEGRATION] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

CREATE     PROCEDURE [synapse_fo].[usp_Update_DIMENSIONHIERARCHYLEVEL]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:37
	Description: Update stored procedure for DIMENSIONHIERARCHYLEVEL from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CREATEDBY] = stg.[CREATEDBY],
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DIMENSIONATTRIBUTE] = stg.[DIMENSIONATTRIBUTE],
		tgt.[DIMENSIONHIERARCHY] = stg.[DIMENSIONHIERARCHY],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LEVEL_] = stg.[LEVEL_],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TEMPORARYDIMENSIONHIERARCHYLEVEL] = stg.[TEMPORARYDIMENSIONHIERARCHYLEVEL]
	 FROM [synapse_fo].[DIMENSIONHIERARCHYLEVEL] tgt
		INNER JOIN [staging_fo].[DIMENSIONHIERARCHYLEVEL] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

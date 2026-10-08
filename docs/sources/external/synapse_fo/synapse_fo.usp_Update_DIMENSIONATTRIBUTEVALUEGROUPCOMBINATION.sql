CREATE     PROCEDURE [synapse_fo].[usp_Update_DIMENSIONATTRIBUTEVALUEGROUPCOMBINATION]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:36
	Description: Update stored procedure for DIMENSIONATTRIBUTEVALUEGROUPCOMBINATION from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CREATEDBY] = stg.[CREATEDBY],
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DIMENSIONATTRIBUTEVALUECOMBINATION] = stg.[DIMENSIONATTRIBUTEVALUECOMBINATION],
		tgt.[DIMENSIONATTRIBUTEVALUEGROUP] = stg.[DIMENSIONATTRIBUTEVALUEGROUP],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[MODIFIEDTRANSACTIONID] = stg.[MODIFIEDTRANSACTIONID],
		tgt.[ORDINAL] = stg.[ORDINAL],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[DIMENSIONATTRIBUTEVALUEGROUPCOMBINATION] tgt
		INNER JOIN [staging_fo].[DIMENSIONATTRIBUTEVALUEGROUPCOMBINATION] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

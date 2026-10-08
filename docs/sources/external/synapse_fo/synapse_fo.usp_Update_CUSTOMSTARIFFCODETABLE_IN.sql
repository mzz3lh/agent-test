CREATE     PROCEDURE [synapse_fo].[usp_Update_CUSTOMSTARIFFCODETABLE_IN]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:34
	Description: Update stored procedure for CUSTOMSTARIFFCODETABLE_IN from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DIRECTION] = stg.[DIRECTION],
		tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TARIFFCODE] = stg.[TARIFFCODE]
	 FROM [synapse_fo].[CUSTOMSTARIFFCODETABLE_IN] tgt
		INNER JOIN [staging_fo].[CUSTOMSTARIFFCODETABLE_IN] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

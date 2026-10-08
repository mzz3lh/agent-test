CREATE     PROCEDURE [synapse_fo].[usp_Update_DIRNAMEAFFIX]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:37
	Description: Update stored procedure for DIRNAMEAFFIX from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[AFFIX] = stg.[AFFIX],
		tgt.[AFFIXTYPE] = stg.[AFFIXTYPE],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[DIRNAMEAFFIX] tgt
		INNER JOIN [staging_fo].[DIRNAMEAFFIX] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

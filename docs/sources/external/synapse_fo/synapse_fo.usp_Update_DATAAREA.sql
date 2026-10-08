CREATE      PROCEDURE [synapse_fo].[usp_Update_DATAAREA]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:35
	Description: Update stored procedure for DATAAREA from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[ALWAYSNATIVE] = stg.[ALWAYSNATIVE],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[ISVIRTUAL] = stg.[ISVIRTUAL],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TIMEZONE] = stg.[TIMEZONE],
		tgt.[fno_id] = stg.[fno_id]
	 FROM [synapse_fo].[DATAAREA] tgt
		INNER JOIN [staging_fo].[DATAAREA] stg
			ON  stg.[RecId] = tgt.[RecId] 
		
END

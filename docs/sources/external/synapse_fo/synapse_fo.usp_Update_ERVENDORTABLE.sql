CREATE     PROCEDURE [synapse_fo].[usp_Update_ERVENDORTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:41
	Description: Update stored procedure for ERVENDORTABLE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[URL] = stg.[URL]
	 FROM [synapse_fo].[ERVENDORTABLE] tgt
		INNER JOIN [staging_fo].[ERVENDORTABLE] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

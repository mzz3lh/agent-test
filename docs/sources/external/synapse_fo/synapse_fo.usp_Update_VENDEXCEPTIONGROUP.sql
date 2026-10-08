CREATE     PROCEDURE [synapse_fo].[usp_Update_VENDEXCEPTIONGROUP]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:54
	Description: Update stored procedure for VENDEXCEPTIONGROUP from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CREATEDBY] = stg.[CREATEDBY],
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SysRowId] = stg.[SysRowId],
		tgt.[VENDEXCEPTIONGROUP] = stg.[VENDEXCEPTIONGROUP]
	 FROM [synapse_fo].[VENDEXCEPTIONGROUP] tgt
		INNER JOIN [staging_fo].[VENDEXCEPTIONGROUP] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

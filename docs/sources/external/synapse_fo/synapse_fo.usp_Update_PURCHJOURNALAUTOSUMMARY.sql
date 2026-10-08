CREATE      PROCEDURE [synapse_fo].[usp_Update_PURCHJOURNALAUTOSUMMARY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-18 12:54:35
	Description: Update stored procedure for PURCHJOURNALAUTOSUMMARY from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[AUTOSUMMARY] = stg.[AUTOSUMMARY],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DOCUMENTSTATUS] = stg.[DOCUMENTSTATUS],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODULETYPE] = stg.[MODULETYPE],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PURCHID] = stg.[PURCHID],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[VENDACCOUNT] = stg.[VENDACCOUNT]
	 FROM [synapse_fo].[PURCHJOURNALAUTOSUMMARY] tgt
		INNER JOIN [staging_fo].[PURCHJOURNALAUTOSUMMARY] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

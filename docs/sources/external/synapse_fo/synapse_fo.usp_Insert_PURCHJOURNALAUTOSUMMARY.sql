CREATE      PROCEDURE [synapse_fo].[usp_Insert_PURCHJOURNALAUTOSUMMARY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-18 12:54:22
	Description: Insert stored procedure for PURCHJOURNALAUTOSUMMARY from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[PURCHJOURNALAUTOSUMMARY]
	(
		[AUTOSUMMARY],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[DOCUMENTSTATUS],
		--[FileName],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDBY],
		[MODULETYPE],
		[PARTITION],
		[PURCHID],
		[RECID],
		[RECVERSION],
		--[SysRowId],
		[VENDACCOUNT]
	)
	SELECT 
		stg.[AUTOSUMMARY],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[DOCUMENTSTATUS],
		--stg.[FileName],
		stg.[LastProcessedChange_DateTime],
		--stg.[LSN],
		stg.[MODIFIEDBY],
		stg.[MODULETYPE],
		stg.[PARTITION],
		stg.[PURCHID],
		stg.[RECID],
		stg.[RECVERSION],
		--stg.[SysRowId],
		stg.[VENDACCOUNT]	
	FROM [staging_fo].[PURCHJOURNALAUTOSUMMARY] stg
		LEFT JOIN [synapse_fo].[PURCHJOURNALAUTOSUMMARY] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

CREATE      PROCEDURE [synapse_fo].[usp_Insert_DATAAREA]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:42
	Description: Insert stored procedure for DATAAREA from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[DATAAREA]
	(
		[ALWAYSNATIVE],
		[DataLakeModified_DateTime],
		--[FileName],
		[ID],
		[ISVIRTUAL],
		[LastProcessedChange_DateTime],
		--[LSN],
		[NAME],
		[PARTITION],
		[RECID],
		[RECVERSION],
		--[SysRowId],
		[TIMEZONE],
		[fno_Id]
	)
	SELECT 
		stg.[ALWAYSNATIVE],
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[ID],
		stg.[ISVIRTUAL],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[NAME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		--stg.--[SysRowId],
		stg.[TIMEZONE],
		stg.[fno_id]
	FROM [staging_fo].[DATAAREA] stg
		LEFT JOIN [synapse_fo].[DATAAREA] tgt
			ON stg.[RecId] = tgt.[RecId] 
		
	WHERE tgt.[RECID] IS NULL
END

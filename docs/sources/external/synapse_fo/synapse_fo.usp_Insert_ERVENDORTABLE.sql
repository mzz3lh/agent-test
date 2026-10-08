CREATE     PROCEDURE [synapse_fo].[usp_Insert_ERVENDORTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:48
	Description: Insert stored procedure for ERVENDORTABLE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[ERVENDORTABLE]
	(
		[DataLakeModified_DateTime],
		--[FileName],
		[LastProcessedChange_DateTime],
		--[LSN],
		[NAME],
		[PARTITION],
		[RECID],
		[RECVERSION],
		--[SysRowId],
		[URL]
	)
	SELECT 
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[NAME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		--stg.--[SysRowId],
		stg.[URL]	
	FROM [staging_fo].[ERVENDORTABLE] stg
		LEFT JOIN [synapse_fo].[ERVENDORTABLE] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

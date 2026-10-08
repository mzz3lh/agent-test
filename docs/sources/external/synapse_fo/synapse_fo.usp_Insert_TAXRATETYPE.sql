CREATE     PROCEDURE [synapse_fo].[usp_Insert_TAXRATETYPE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:01
	Description: Insert stored procedure for TAXRATETYPE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[TAXRATETYPE]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		[FileName],
		[LastProcessedChange_DateTime],
		[LSN],
		[NAME],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SysRowId]
	)
	SELECT 
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		stg.[FileName],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[NAME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId]	
	FROM [staging_fo].[TAXRATETYPE] stg
		LEFT JOIN [synapse_fo].[TAXRATETYPE] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

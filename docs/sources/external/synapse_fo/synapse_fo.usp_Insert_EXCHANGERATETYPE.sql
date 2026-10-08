CREATE     PROCEDURE [synapse_fo].[usp_Insert_EXCHANGERATETYPE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:49
	Description: Insert stored procedure for EXCHANGERATETYPE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[EXCHANGERATETYPE]
	(
		[CALENDARID],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		--[FileName],
		[LastProcessedChange_DateTime],
		--[LSN],
		[NAME],
		[PARTITION],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[CALENDARID],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		--stg.--[FileName],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[NAME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[EXCHANGERATETYPE] stg
		LEFT JOIN [synapse_fo].[EXCHANGERATETYPE] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

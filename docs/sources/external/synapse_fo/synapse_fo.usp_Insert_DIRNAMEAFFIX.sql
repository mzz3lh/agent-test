CREATE     PROCEDURE [synapse_fo].[usp_Insert_DIRNAMEAFFIX]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:45
	Description: Insert stored procedure for DIRNAMEAFFIX from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[DIRNAMEAFFIX]
	(
		[AFFIX],
		[AFFIXTYPE],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		--[FileName],
		[LastProcessedChange_DateTime],
		--[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[AFFIX],
		stg.[AFFIXTYPE],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		--stg.--[FileName],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[DIRNAMEAFFIX] stg
		LEFT JOIN [synapse_fo].[DIRNAMEAFFIX] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

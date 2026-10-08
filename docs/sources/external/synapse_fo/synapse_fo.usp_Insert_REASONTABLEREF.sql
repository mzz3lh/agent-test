CREATE     PROCEDURE [synapse_fo].[usp_Insert_REASONTABLEREF]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:58
	Description: Insert stored procedure for REASONTABLEREF from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[REASONTABLEREF]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		--[FileName],
		[LastProcessedChange_DateTime],
		--[LSN],
		[PARTITION],
		[REASON],
		[REASONCOMMENT],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[PARTITION],
		stg.[REASON],
		stg.[REASONCOMMENT],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[REASONTABLEREF] stg
		LEFT JOIN [synapse_fo].[REASONTABLEREF] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

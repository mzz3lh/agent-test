CREATE     PROCEDURE [synapse_fo].[usp_Insert_SHAREDCATEGORY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:59
	Description: Insert stored procedure for SHAREDCATEGORY from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[SHAREDCATEGORY]
	(
		[CATEGORYID],
		[CATEGORYNAME],
		[DataLakeModified_DateTime],
		--[FileName],
		[LastProcessedChange_DateTime],
		--[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[CATEGORYID],
		stg.[CATEGORYNAME],
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[SHAREDCATEGORY] stg
		LEFT JOIN [synapse_fo].[SHAREDCATEGORY] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

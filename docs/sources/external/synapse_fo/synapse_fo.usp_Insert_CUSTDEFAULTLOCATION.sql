CREATE     PROCEDURE [synapse_fo].[usp_Insert_CUSTDEFAULTLOCATION]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:40
	Description: Insert stored procedure for CUSTDEFAULTLOCATION from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[CUSTDEFAULTLOCATION]
	(
		[ACCOUNTNUM],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		--[FileName],
		[LastProcessedChange_DateTime],
		--[LSN],
		[PARTITION],
		[PARTYLOCATIONROLE],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[ACCOUNTNUM],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[PARTITION],
		stg.[PARTYLOCATIONROLE],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[CUSTDEFAULTLOCATION] stg
		LEFT JOIN [synapse_fo].[CUSTDEFAULTLOCATION] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

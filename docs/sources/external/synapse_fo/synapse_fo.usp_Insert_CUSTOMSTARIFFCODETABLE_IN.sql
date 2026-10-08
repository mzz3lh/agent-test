CREATE     PROCEDURE [synapse_fo].[usp_Insert_CUSTOMSTARIFFCODETABLE_IN]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:41
	Description: Insert stored procedure for CUSTOMSTARIFFCODETABLE_IN from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[CUSTOMSTARIFFCODETABLE_IN]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[DIRECTION],
		[FileName],
		[LastProcessedChange_DateTime],
		[LSN],
		[MODIFIEDBY],
		[NAME],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SysRowId],
		[TARIFFCODE]
	)
	SELECT 
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[DIRECTION],
		stg.[FileName],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[MODIFIEDBY],
		stg.[NAME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId],
		stg.[TARIFFCODE]	
	FROM [staging_fo].[CUSTOMSTARIFFCODETABLE_IN] stg
		LEFT JOIN [synapse_fo].[CUSTOMSTARIFFCODETABLE_IN] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

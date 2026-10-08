CREATE     PROCEDURE [synapse_fo].[usp_Insert_SERVICEACCOUNTINGCODETABLE_IN]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:59
	Description: Insert stored procedure for SERVICEACCOUNTINGCODETABLE_IN from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[SERVICEACCOUNTINGCODETABLE_IN]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		[FileName],
		[LastProcessedChange_DateTime],
		[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SAC],
		[SysRowId]
	)
	SELECT 
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		stg.[FileName],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SAC],
		stg.[SysRowId]	
	FROM [staging_fo].[SERVICEACCOUNTINGCODETABLE_IN] stg
		LEFT JOIN [synapse_fo].[SERVICEACCOUNTINGCODETABLE_IN] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

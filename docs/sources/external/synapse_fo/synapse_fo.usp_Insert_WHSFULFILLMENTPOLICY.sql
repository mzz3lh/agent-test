CREATE     PROCEDURE [synapse_fo].[usp_Insert_WHSFULFILLMENTPOLICY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:04
	Description: Insert stored procedure for WHSFULFILLMENTPOLICY from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[WHSFULFILLMENTPOLICY]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		[FileName],
		[FULFILLMENTERRORTOLERANCE],
		[FULFILLMENTRATE],
		[FULFILLMENTTYPE],
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
		stg.[FULFILLMENTERRORTOLERANCE],
		stg.[FULFILLMENTRATE],
		stg.[FULFILLMENTTYPE],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[NAME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId]	
	FROM [staging_fo].[WHSFULFILLMENTPOLICY] stg
		LEFT JOIN [synapse_fo].[WHSFULFILLMENTPOLICY] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

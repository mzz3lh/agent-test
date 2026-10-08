CREATE     PROCEDURE [synapse_fo].[usp_Insert_WHSCUSTTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:04
	Description: Insert stored procedure for WHSCUSTTABLE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[WHSCUSTTABLE]
	(
		[ACCOUNTNUM],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		--[FileName],
		[FILLENTIREORDER],
		[FULFILLMENTPOLICY],
		[GENERATEASN],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[PARTITION],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[ACCOUNTNUM],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[FILLENTIREORDER],
		stg.[FULFILLMENTPOLICY],
		stg.[GENERATEASN],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[WHSCUSTTABLE] stg
		LEFT JOIN [synapse_fo].[WHSCUSTTABLE] tgt
			ON stg.[AccountNum] = tgt.[AccountNum] 
			AND stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
	WHERE tgt.[RECID] IS NULL
END

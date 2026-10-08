CREATE     PROCEDURE [synapse_fo].[usp_Insert_ECORESATTRIBUTE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:45
	Description: Insert stored procedure for ECORESATTRIBUTE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[ECORESATTRIBUTE]
	(
		[ATTRIBUTEMODIFIER],
		[ATTRIBUTETYPE],
		[DataLakeModified_DateTime],
		[ENGCHGATTRIBUTEMAX],
		[ENGCHGATTRIBUTEMIN],
		[ENGCHGATTRIBUTEMULTIPLE],
		[ENGCHGATTRIBUTETOLERANCEACTION],
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
		stg.[ATTRIBUTEMODIFIER],
		stg.[ATTRIBUTETYPE],
		stg.[DataLakeModified_DateTime],
		stg.[ENGCHGATTRIBUTEMAX],
		stg.[ENGCHGATTRIBUTEMIN],
		stg.[ENGCHGATTRIBUTEMULTIPLE],
		stg.[ENGCHGATTRIBUTETOLERANCEACTION],
		--stg.--[FileName],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[NAME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[ECORESATTRIBUTE] stg
		LEFT JOIN [synapse_fo].[ECORESATTRIBUTE] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

CREATE     PROCEDURE [synapse_fo].[usp_Insert_PDSCATCHWEIGHTITEM]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:56
	Description: Insert stored procedure for PDSCATCHWEIGHTITEM from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[PDSCATCHWEIGHTITEM]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[FileName],
		[ITEMID],
		[LastProcessedChange_DateTime],
		[LSN],
		[PARTITION],
		[PDSCWMAX],
		[PDSCWMIN],
		[PDSCWUNITID],
		[RECID],
		[RECVERSION],
		[SysRowId]
	)
	SELECT 
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[FileName],
		stg.[ITEMID],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[PARTITION],
		stg.[PDSCWMAX],
		stg.[PDSCWMIN],
		stg.[PDSCWUNITID],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId]	
	FROM [staging_fo].[PDSCATCHWEIGHTITEM] stg
		LEFT JOIN [synapse_fo].[PDSCATCHWEIGHTITEM] tgt
			ON stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[ItemId] = tgt.[ItemId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
	WHERE tgt.[RECID] IS NULL
END

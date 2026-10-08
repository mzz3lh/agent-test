CREATE     PROCEDURE [synapse_fo].[usp_Insert_ECORESPRODUCTSERVICEWARRANTY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:47
	Description: Insert stored procedure for ECORESPRODUCTSERVICEWARRANTY from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[ECORESPRODUCTSERVICEWARRANTY]
	(
		[DataLakeModified_DateTime],
		[DISTINCTPRODUCT],
		[DURATIONTIME],
		[DURATIONTIMEUNIT],
		[FileName],
		[LastProcessedChange_DateTime],
		[LSN],
		[MODIFIEDBY],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SysRowId]
	)
	SELECT 
		stg.[DataLakeModified_DateTime],
		stg.[DISTINCTPRODUCT],
		stg.[DURATIONTIME],
		stg.[DURATIONTIMEUNIT],
		stg.[FileName],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[MODIFIEDBY],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId]	
	FROM [staging_fo].[ECORESPRODUCTSERVICEWARRANTY] stg
		LEFT JOIN [synapse_fo].[ECORESPRODUCTSERVICEWARRANTY] tgt
			ON stg.[DistinctProduct] = tgt.[DistinctProduct] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
	WHERE tgt.[RECID] IS NULL
END

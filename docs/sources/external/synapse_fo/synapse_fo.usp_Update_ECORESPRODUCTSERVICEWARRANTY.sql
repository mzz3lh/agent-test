CREATE     PROCEDURE [synapse_fo].[usp_Update_ECORESPRODUCTSERVICEWARRANTY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:39
	Description: Update stored procedure for ECORESPRODUCTSERVICEWARRANTY from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DISTINCTPRODUCT] = stg.[DISTINCTPRODUCT],
		tgt.[DURATIONTIME] = stg.[DURATIONTIME],
		tgt.[DURATIONTIMEUNIT] = stg.[DURATIONTIMEUNIT],
		tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[ECORESPRODUCTSERVICEWARRANTY] tgt
		INNER JOIN [staging_fo].[ECORESPRODUCTSERVICEWARRANTY] stg
			ON  stg.[DistinctProduct] = tgt.[DistinctProduct] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
END

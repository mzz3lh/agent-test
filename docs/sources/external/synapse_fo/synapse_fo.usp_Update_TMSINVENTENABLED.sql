CREATE     PROCEDURE [synapse_fo].[usp_Update_TMSINVENTENABLED]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:53
	Description: Update stored procedure for TMSINVENTENABLED from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[FileName] = stg.[FileName],
		tgt.[ITEMID] = stg.[ITEMID],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[TMSINVENTENABLED] tgt
		INNER JOIN [staging_fo].[TMSINVENTENABLED] stg
			ON  stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[ItemId] = tgt.[ItemId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
END

CREATE     PROCEDURE [synapse_fo].[usp_Update_ECORESTRACKINGDIMENSIONGROUPITEM]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:40
	Description: Update stored procedure for ECORESTRACKINGDIMENSIONGROUPITEM from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[ITEMDATAAREAID] = stg.[ITEMDATAAREAID],
		tgt.[ITEMID] = stg.[ITEMID],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TRACKINGDIMENSIONGROUP] = stg.[TRACKINGDIMENSIONGROUP]
	 FROM [synapse_fo].[ECORESTRACKINGDIMENSIONGROUPITEM] tgt
		INNER JOIN [staging_fo].[ECORESTRACKINGDIMENSIONGROUPITEM] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

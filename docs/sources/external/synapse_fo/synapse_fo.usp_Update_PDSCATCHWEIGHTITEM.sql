CREATE     PROCEDURE [synapse_fo].[usp_Update_PDSCATCHWEIGHTITEM]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:48
	Description: Update stored procedure for PDSCATCHWEIGHTITEM from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[FileName] = stg.[FileName],
		tgt.[ITEMID] = stg.[ITEMID],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PDSCWMAX] = stg.[PDSCWMAX],
		tgt.[PDSCWMIN] = stg.[PDSCWMIN],
		tgt.[PDSCWUNITID] = stg.[PDSCWUNITID],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[PDSCATCHWEIGHTITEM] tgt
		INNER JOIN [staging_fo].[PDSCATCHWEIGHTITEM] stg
			ON  stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[ItemId] = tgt.[ItemId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
END

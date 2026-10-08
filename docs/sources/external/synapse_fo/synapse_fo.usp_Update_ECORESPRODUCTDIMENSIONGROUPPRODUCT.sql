CREATE     PROCEDURE [synapse_fo].[usp_Update_ECORESPRODUCTDIMENSIONGROUPPRODUCT]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:39
	Description: Update stored procedure for ECORESPRODUCTDIMENSIONGROUPPRODUCT from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PRODUCT] = stg.[PRODUCT],
		tgt.[PRODUCTDIMENSIONGROUP] = stg.[PRODUCTDIMENSIONGROUP],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[ECORESPRODUCTDIMENSIONGROUPPRODUCT] tgt
		INNER JOIN [staging_fo].[ECORESPRODUCTDIMENSIONGROUPPRODUCT] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

CREATE     PROCEDURE [synapse_fo].[usp_Insert_ECORESPRODUCTDIMENSIONGROUPPRODUCT]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:47
	Description: Insert stored procedure for ECORESPRODUCTDIMENSIONGROUPPRODUCT from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[ECORESPRODUCTDIMENSIONGROUPPRODUCT]
	(
		[DataLakeModified_DateTime],
		[FileName],
		[LastProcessedChange_DateTime],
		[LSN],
		[MODIFIEDBY],
		[PARTITION],
		[PRODUCT],
		[PRODUCTDIMENSIONGROUP],
		[RECID],
		[RECVERSION],
		[SysRowId]
	)
	SELECT 
		stg.[DataLakeModified_DateTime],
		stg.[FileName],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[MODIFIEDBY],
		stg.[PARTITION],
		stg.[PRODUCT],
		stg.[PRODUCTDIMENSIONGROUP],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId]	
	FROM [staging_fo].[ECORESPRODUCTDIMENSIONGROUPPRODUCT] stg
		LEFT JOIN [synapse_fo].[ECORESPRODUCTDIMENSIONGROUPPRODUCT] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

CREATE     PROCEDURE [synapse_fo].[usp_Update_WHSCUSTTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:56
	Description: Update stored procedure for WHSCUSTTABLE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[ACCOUNTNUM] = stg.[ACCOUNTNUM],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[FILLENTIREORDER] = stg.[FILLENTIREORDER],
		tgt.[FULFILLMENTPOLICY] = stg.[FULFILLMENTPOLICY],
		tgt.[GENERATEASN] = stg.[GENERATEASN],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[WHSCUSTTABLE] tgt
		INNER JOIN [staging_fo].[WHSCUSTTABLE] stg
			ON  stg.[AccountNum] = tgt.[AccountNum] 
			AND stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
END

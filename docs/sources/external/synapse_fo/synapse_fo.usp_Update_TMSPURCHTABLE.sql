CREATE     PROCEDURE [synapse_fo].[usp_Update_TMSPURCHTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:53
	Description: Update stored procedure for TMSPURCHTABLE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CARRIERCODE] = stg.[CARRIERCODE],
		tgt.[CARRIERGROUPCODE] = stg.[CARRIERGROUPCODE],
		tgt.[CARRIERSERVICECODE] = stg.[CARRIERSERVICECODE],
		tgt.[CREATEDBY] = stg.[CREATEDBY],
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[MODECODE] = stg.[MODECODE],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PURCHID] = stg.[PURCHID],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[ROUTECONFIGCODE] = stg.[ROUTECONFIGCODE],
		tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TRANSPORTATIONTEMPLATEID] = stg.[TRANSPORTATIONTEMPLATEID]
	 FROM [synapse_fo].[TMSPURCHTABLE] tgt
		INNER JOIN [staging_fo].[TMSPURCHTABLE] stg
			ON  stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
			AND stg.[PurchId] = tgt.[PurchId] 
		
END

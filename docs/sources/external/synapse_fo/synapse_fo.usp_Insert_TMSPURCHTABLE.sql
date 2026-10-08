CREATE     PROCEDURE [synapse_fo].[usp_Insert_TMSPURCHTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:01
	Description: Insert stored procedure for TMSPURCHTABLE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[TMSPURCHTABLE]
	(
		[CARRIERCODE],
		[CARRIERGROUPCODE],
		[CARRIERSERVICECODE],
		[CREATEDBY],
		[CREATEDDATETIME],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[FileName],
		[LastProcessedChange_DateTime],
		[LSN],
		[MODECODE],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[PARTITION],
		[PURCHID],
		[RECID],
		[RECVERSION],
		[ROUTECONFIGCODE],
		[SysRowId],
		[TRANSPORTATIONTEMPLATEID]
	)
	SELECT 
		stg.[CARRIERCODE],
		stg.[CARRIERGROUPCODE],
		stg.[CARRIERSERVICECODE],
		stg.[CREATEDBY],
		stg.[CREATEDDATETIME],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[FileName],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[MODECODE],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[PARTITION],
		stg.[PURCHID],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[ROUTECONFIGCODE],
		stg.[SysRowId],
		stg.[TRANSPORTATIONTEMPLATEID]	
	FROM [staging_fo].[TMSPURCHTABLE] stg
		LEFT JOIN [synapse_fo].[TMSPURCHTABLE] tgt
			ON stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
			AND stg.[PurchId] = tgt.[PurchId] 
		
	WHERE tgt.[RECID] IS NULL
END

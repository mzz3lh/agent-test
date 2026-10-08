CREATE     PROCEDURE [synapse_fo].[usp_Insert_WHSPURCHLINE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:04
	Description: Insert stored procedure for WHSPURCHLINE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[WHSPURCHLINE]
	(
		[CREATEDBY],
		[CREATEDDATETIME],
		[CROSSDOCK],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[FileName],
		[INVENTTRANSID],
		[LastProcessedChange_DateTime],
		[LSN],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[PARTITION],
		[QTYLEFTTOLOAD],
		[RECID],
		[RECVERSION],
		[SysRowId]
	)
	SELECT 
		stg.[CREATEDBY],
		stg.[CREATEDDATETIME],
		stg.[CROSSDOCK],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[FileName],
		stg.[INVENTTRANSID],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[PARTITION],
		stg.[QTYLEFTTOLOAD],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId]	
	FROM [staging_fo].[WHSPURCHLINE] stg
		LEFT JOIN [synapse_fo].[WHSPURCHLINE] tgt
			ON stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[InventTransId] = tgt.[InventTransId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
	WHERE tgt.[RECID] IS NULL
END

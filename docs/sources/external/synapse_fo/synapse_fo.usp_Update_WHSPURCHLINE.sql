CREATE     PROCEDURE [synapse_fo].[usp_Update_WHSPURCHLINE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:57
	Description: Update stored procedure for WHSPURCHLINE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CREATEDBY] = stg.[CREATEDBY],
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[CROSSDOCK] = stg.[CROSSDOCK],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[FileName] = stg.[FileName],
		tgt.[INVENTTRANSID] = stg.[INVENTTRANSID],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[QTYLEFTTOLOAD] = stg.[QTYLEFTTOLOAD],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[WHSPURCHLINE] tgt
		INNER JOIN [staging_fo].[WHSPURCHLINE] stg
			ON  stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[InventTransId] = tgt.[InventTransId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
END

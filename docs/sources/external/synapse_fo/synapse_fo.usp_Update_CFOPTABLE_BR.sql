CREATE     PROCEDURE [synapse_fo].[usp_Update_CFOPTABLE_BR]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:32
	Description: Update stored procedure for CFOPTABLE_BR from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CFOPID] = stg.[CFOPID],
		tgt.[CONSIDERINCIAP] = stg.[CONSIDERINCIAP],
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[CUSTVENDCFOPNAMEALIAS] = stg.[CUSTVENDCFOPNAMEALIAS],
		tgt.[CUSTVENDLOCATION] = stg.[CUSTVENDLOCATION],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DELIVERYCFOPTABLE_BR] = stg.[DELIVERYCFOPTABLE_BR],
		tgt.[DIRECTION] = stg.[DIRECTION],
		tgt.[FileName] = stg.[FileName],
		tgt.[FISCALDOCUMENTTEXTID] = stg.[FISCALDOCUMENTTEXTID],
		tgt.[FISCALREFLEGALTXTID] = stg.[FISCALREFLEGALTXTID],
		tgt.[FISCALREFMANDATORY] = stg.[FISCALREFMANDATORY],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PURPOSE] = stg.[PURPOSE],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[RETAILFISCALREFLEGALTXTID] = stg.[RETAILFISCALREFLEGALTXTID],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[CFOPTABLE_BR] tgt
		INNER JOIN [staging_fo].[CFOPTABLE_BR] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

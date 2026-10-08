CREATE     PROCEDURE [synapse_fo].[usp_Insert_CFOPTABLE_BR]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:39
	Description: Insert stored procedure for CFOPTABLE_BR from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[CFOPTABLE_BR]
	(
		[CFOPID],
		[CONSIDERINCIAP],
		[CREATEDDATETIME],
		[CUSTVENDCFOPNAMEALIAS],
		[CUSTVENDLOCATION],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[DELIVERYCFOPTABLE_BR],
		[DIRECTION],
		[FileName],
		[FISCALDOCUMENTTEXTID],
		[FISCALREFLEGALTXTID],
		[FISCALREFMANDATORY],
		[LastProcessedChange_DateTime],
		[LSN],
		[MODIFIEDDATETIME],
		[NAME],
		[PARTITION],
		[PURPOSE],
		[RECID],
		[RECVERSION],
		[RETAILFISCALREFLEGALTXTID],
		[SysRowId]
	)
	SELECT 
		stg.[CFOPID],
		stg.[CONSIDERINCIAP],
		stg.[CREATEDDATETIME],
		stg.[CUSTVENDCFOPNAMEALIAS],
		stg.[CUSTVENDLOCATION],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[DELIVERYCFOPTABLE_BR],
		stg.[DIRECTION],
		stg.[FileName],
		stg.[FISCALDOCUMENTTEXTID],
		stg.[FISCALREFLEGALTXTID],
		stg.[FISCALREFMANDATORY],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[MODIFIEDDATETIME],
		stg.[NAME],
		stg.[PARTITION],
		stg.[PURPOSE],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[RETAILFISCALREFLEGALTXTID],
		stg.[SysRowId]	
	FROM [staging_fo].[CFOPTABLE_BR] stg
		LEFT JOIN [synapse_fo].[CFOPTABLE_BR] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

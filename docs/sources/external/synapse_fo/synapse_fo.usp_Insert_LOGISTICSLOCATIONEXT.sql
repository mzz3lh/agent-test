CREATE     PROCEDURE [synapse_fo].[usp_Insert_LOGISTICSLOCATIONEXT]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:53
	Description: Insert stored procedure for LOGISTICSLOCATIONEXT from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[LOGISTICSLOCATIONEXT]
	(
		[CNPJCPFNUM_BR],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[FileName],
		[IENUM_BR],
		[LastProcessedChange_DateTime],
		[LOCATION],
		[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SALESCALENDARID],
		[SysRowId],
		[TAXGROUP],
		[TAXGSTEPZCODE_IN]
	)
	SELECT 
		stg.[CNPJCPFNUM_BR],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[FileName],
		stg.[IENUM_BR],
		stg.[LastProcessedChange_DateTime],
		stg.[LOCATION],
		stg.[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SALESCALENDARID],
		stg.[SysRowId],
		stg.[TAXGROUP],
		stg.[TAXGSTEPZCODE_IN]	
	FROM [staging_fo].[LOGISTICSLOCATIONEXT] stg
		LEFT JOIN [synapse_fo].[LOGISTICSLOCATIONEXT] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

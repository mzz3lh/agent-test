CREATE     PROCEDURE [synapse_fo].[usp_Update_LOGISTICSLOCATIONEXT]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:45
	Description: Update stored procedure for LOGISTICSLOCATIONEXT from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CNPJCPFNUM_BR] = stg.[CNPJCPFNUM_BR],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[FileName] = stg.[FileName],
		tgt.[IENUM_BR] = stg.[IENUM_BR],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LOCATION] = stg.[LOCATION],
		tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SALESCALENDARID] = stg.[SALESCALENDARID],
		tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TAXGROUP] = stg.[TAXGROUP],
		tgt.[TAXGSTEPZCODE_IN] = stg.[TAXGSTEPZCODE_IN]
	 FROM [synapse_fo].[LOGISTICSLOCATIONEXT] tgt
		INNER JOIN [staging_fo].[LOGISTICSLOCATIONEXT] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

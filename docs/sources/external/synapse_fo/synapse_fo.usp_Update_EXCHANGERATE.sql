CREATE     PROCEDURE [synapse_fo].[usp_Update_EXCHANGERATE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:41
	Description: Update stored procedure for EXCHANGERATE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CREATEDBY] = stg.[CREATEDBY],
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[EXCHANGERATE] = stg.[EXCHANGERATE],
		tgt.[EXCHANGERATECURRENCYPAIR] = stg.[EXCHANGERATECURRENCYPAIR],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[VALIDFROM] = stg.[VALIDFROM],
		tgt.[VALIDTO] = stg.[VALIDTO]
	 FROM [synapse_fo].[EXCHANGERATE] tgt
		INNER JOIN [staging_fo].[EXCHANGERATE] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

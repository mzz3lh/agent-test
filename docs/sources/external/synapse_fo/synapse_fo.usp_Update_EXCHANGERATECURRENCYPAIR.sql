CREATE     PROCEDURE [synapse_fo].[usp_Update_EXCHANGERATECURRENCYPAIR]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:41
	Description: Update stored procedure for EXCHANGERATECURRENCYPAIR from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[EXCHANGERATEDISPLAYFACTOR] = stg.[EXCHANGERATEDISPLAYFACTOR],
		tgt.[EXCHANGERATETYPE] = stg.[EXCHANGERATETYPE],
		--tgt.[FileName] = stg.[FileName],
		tgt.[FROMCURRENCYCODE] = stg.[FROMCURRENCYCODE],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TOCURRENCYCODE] = stg.[TOCURRENCYCODE]
	 FROM [synapse_fo].[EXCHANGERATECURRENCYPAIR] tgt
		INNER JOIN [staging_fo].[EXCHANGERATECURRENCYPAIR] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

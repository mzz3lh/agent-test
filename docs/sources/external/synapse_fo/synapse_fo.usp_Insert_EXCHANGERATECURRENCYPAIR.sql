CREATE     PROCEDURE [synapse_fo].[usp_Insert_EXCHANGERATECURRENCYPAIR]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:49
	Description: Insert stored procedure for EXCHANGERATECURRENCYPAIR from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[EXCHANGERATECURRENCYPAIR]
	(
		[DataLakeModified_DateTime],
		[EXCHANGERATEDISPLAYFACTOR],
		[EXCHANGERATETYPE],
		--[FileName],
		[FROMCURRENCYCODE],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDDATETIME],
		[PARTITION],
		[RECID],
		[RECVERSION],
		--[SysRowId],
		[TOCURRENCYCODE]
	)
	SELECT 
		stg.[DataLakeModified_DateTime],
		stg.[EXCHANGERATEDISPLAYFACTOR],
		stg.[EXCHANGERATETYPE],
		--stg.--[FileName],
		stg.[FROMCURRENCYCODE],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODIFIEDDATETIME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		--stg.--[SysRowId],
		stg.[TOCURRENCYCODE]	
	FROM [staging_fo].[EXCHANGERATECURRENCYPAIR] stg
		LEFT JOIN [synapse_fo].[EXCHANGERATECURRENCYPAIR] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

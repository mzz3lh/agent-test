CREATE     PROCEDURE [synapse_fo].[usp_Insert_CURRENCY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:40
	Description: Insert stored procedure for CURRENCY from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[CURRENCY]
	(
		[CURRENCYCODE],
		[CURRENCYCODEISO],
		[DataLakeModified_DateTime],
		[DECIMALSCOUNT_MX],
		[EXCHRATEMAXVARIATIONPERCENT_MX],
		----[FileName],
		[ISEURO],
		[LastProcessedChange_DateTime],
		----[LSN],
		[LTMROUNDOFFLINEAMOUNT],
		[LTMROUNDOFFTYPELINEAMOUNT],
		[MODIFIEDDATETIME],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[ROUNDINGPRECISION],
		[ROUNDOFFASSETDEP_JP],
		[ROUNDOFFPRICE],
		[ROUNDOFFPURCH],
		[ROUNDOFFSALES],
		[ROUNDOFFTYPEASSETDEP_JP],
		[ROUNDOFFTYPEPRICE],
		[ROUNDOFFTYPEPURCH],
		[ROUNDOFFTYPESALES],
		[SYMBOL],
		----[SysRowId],
		[TXT]
	)
	SELECT 
		stg.[CURRENCYCODE],
		stg.[CURRENCYCODEISO],
		stg.[DataLakeModified_DateTime],
		stg.[DECIMALSCOUNT_MX],
		stg.[EXCHRATEMAXVARIATIONPERCENT_MX],
		----stg.--[FileName],
		stg.[ISEURO],
		stg.[LastProcessedChange_DateTime],
		----stg.--[LSN],
		stg.[LTMROUNDOFFLINEAMOUNT],
		stg.[LTMROUNDOFFTYPELINEAMOUNT],
		stg.[MODIFIEDDATETIME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[ROUNDINGPRECISION],
		stg.[ROUNDOFFASSETDEP_JP],
		stg.[ROUNDOFFPRICE],
		stg.[ROUNDOFFPURCH],
		stg.[ROUNDOFFSALES],
		stg.[ROUNDOFFTYPEASSETDEP_JP],
		stg.[ROUNDOFFTYPEPRICE],
		stg.[ROUNDOFFTYPEPURCH],
		stg.[ROUNDOFFTYPESALES],
		stg.[SYMBOL],
		----stg.--[SysRowId],
		stg.[TXT]	
	FROM [staging_fo].[CURRENCY] stg
		LEFT JOIN [synapse_fo].[CURRENCY] tgt
			ON stg.[CurrencyCode] = tgt.[CurrencyCode] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
	WHERE tgt.[RECID] IS NULL
END

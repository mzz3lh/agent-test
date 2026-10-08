CREATE     PROCEDURE [synapse_fo].[usp_Update_CURRENCY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:33
	Description: Update stored procedure for CURRENCY from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CURRENCYCODE] = stg.[CURRENCYCODE],
		tgt.[CURRENCYCODEISO] = stg.[CURRENCYCODEISO],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DECIMALSCOUNT_MX] = stg.[DECIMALSCOUNT_MX],
		tgt.[EXCHRATEMAXVARIATIONPERCENT_MX] = stg.[EXCHRATEMAXVARIATIONPERCENT_MX],
		--tgt.[FileName] = stg.[FileName],
		tgt.[ISEURO] = stg.[ISEURO],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[LTMROUNDOFFLINEAMOUNT] = stg.[LTMROUNDOFFLINEAMOUNT],
		tgt.[LTMROUNDOFFTYPELINEAMOUNT] = stg.[LTMROUNDOFFTYPELINEAMOUNT],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[ROUNDINGPRECISION] = stg.[ROUNDINGPRECISION],
		tgt.[ROUNDOFFASSETDEP_JP] = stg.[ROUNDOFFASSETDEP_JP],
		tgt.[ROUNDOFFPRICE] = stg.[ROUNDOFFPRICE],
		tgt.[ROUNDOFFPURCH] = stg.[ROUNDOFFPURCH],
		tgt.[ROUNDOFFSALES] = stg.[ROUNDOFFSALES],
		tgt.[ROUNDOFFTYPEASSETDEP_JP] = stg.[ROUNDOFFTYPEASSETDEP_JP],
		tgt.[ROUNDOFFTYPEPRICE] = stg.[ROUNDOFFTYPEPRICE],
		tgt.[ROUNDOFFTYPEPURCH] = stg.[ROUNDOFFTYPEPURCH],
		tgt.[ROUNDOFFTYPESALES] = stg.[ROUNDOFFTYPESALES],
		tgt.[SYMBOL] = stg.[SYMBOL],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TXT] = stg.[TXT]
	 FROM [synapse_fo].[CURRENCY] tgt
		INNER JOIN [staging_fo].[CURRENCY] stg
			ON  stg.[CurrencyCode] = tgt.[CurrencyCode] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
END

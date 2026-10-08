CREATE     PROCEDURE [synapse_fo].[usp_Insert_PAYMSCHED]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:55
	Description: Insert stored procedure for PAYMSCHED from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[PAYMSCHED]
	(
		[AMOUNTCUR],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		--[FileName],
		[LastProcessedChange_DateTime],
		[LOWESTAMOUNT],
		--[LSN],
		[MCRFLEXIBLEPLAN],
		[MCRMAXNUMINSTALLMENTS],
		[MCRMAXORDERVALUE],
		[MCRMINNUMINSTALLMENTS],
		[MCRMINORDERVALUE],
		[MCRMISCCHARGEDIST],
		[NAME],
		[NUMOFPAYMENT],
		[PARTITION],
		[PAYMBY],
		[PAYMENTTYPE_ES],
		[PERIODUNIT],
		[QTYUNIT],
		[RECID],
		[RECVERSION],
		--[RICFIXEDPAYMDAYS],
		--[SysRowId],
		[TAXDISTRIBUTION],
		[TAXWITHHOLDDISTRIBUTION_IN]
	)
	SELECT 
		stg.[AMOUNTCUR],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		--stg.--[FileName],
		stg.[LastProcessedChange_DateTime],
		stg.[LOWESTAMOUNT],
		--stg.--[LSN],
		stg.[MCRFLEXIBLEPLAN],
		stg.[MCRMAXNUMINSTALLMENTS],
		stg.[MCRMAXORDERVALUE],
		stg.[MCRMINNUMINSTALLMENTS],
		stg.[MCRMINORDERVALUE],
		stg.[MCRMISCCHARGEDIST],
		stg.[NAME],
		stg.[NUMOFPAYMENT],
		stg.[PARTITION],
		stg.[PAYMBY],
		stg.[PAYMENTTYPE_ES],
		stg.[PERIODUNIT],
		stg.[QTYUNIT],
		stg.[RECID],
		stg.[RECVERSION],
		--stg.[RICFIXEDPAYMDAYS],
		--stg.--[SysRowId],
		stg.[TAXDISTRIBUTION],
		stg.[TAXWITHHOLDDISTRIBUTION_IN]	
	FROM [staging_fo].[PAYMSCHED] stg
		LEFT JOIN [synapse_fo].[PAYMSCHED] tgt
			ON stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[Name] = tgt.[Name] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
	WHERE tgt.[RECID] IS NULL
END

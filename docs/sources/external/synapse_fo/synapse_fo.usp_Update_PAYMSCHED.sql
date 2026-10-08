CREATE     PROCEDURE [synapse_fo].[usp_Update_PAYMSCHED]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:48
	Description: Update stored procedure for PAYMSCHED from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[AMOUNTCUR] = stg.[AMOUNTCUR],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LOWESTAMOUNT] = stg.[LOWESTAMOUNT],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MCRFLEXIBLEPLAN] = stg.[MCRFLEXIBLEPLAN],
		tgt.[MCRMAXNUMINSTALLMENTS] = stg.[MCRMAXNUMINSTALLMENTS],
		tgt.[MCRMAXORDERVALUE] = stg.[MCRMAXORDERVALUE],
		tgt.[MCRMINNUMINSTALLMENTS] = stg.[MCRMINNUMINSTALLMENTS],
		tgt.[MCRMINORDERVALUE] = stg.[MCRMINORDERVALUE],
		tgt.[MCRMISCCHARGEDIST] = stg.[MCRMISCCHARGEDIST],
		tgt.[NAME] = stg.[NAME],
		tgt.[NUMOFPAYMENT] = stg.[NUMOFPAYMENT],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PAYMBY] = stg.[PAYMBY],
		tgt.[PAYMENTTYPE_ES] = stg.[PAYMENTTYPE_ES],
		tgt.[PERIODUNIT] = stg.[PERIODUNIT],
		tgt.[QTYUNIT] = stg.[QTYUNIT],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		--tgt.[RICFIXEDPAYMDAYS] = stg.[RICFIXEDPAYMDAYS],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TAXDISTRIBUTION] = stg.[TAXDISTRIBUTION],
		tgt.[TAXWITHHOLDDISTRIBUTION_IN] = stg.[TAXWITHHOLDDISTRIBUTION_IN]
	 FROM [synapse_fo].[PAYMSCHED] tgt
		INNER JOIN [staging_fo].[PAYMSCHED] stg
			ON  stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[Name] = tgt.[Name] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
END

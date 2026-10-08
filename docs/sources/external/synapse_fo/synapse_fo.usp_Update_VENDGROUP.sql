CREATE     PROCEDURE [synapse_fo].[usp_Update_VENDGROUP]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:54
	Description: Update stored procedure for VENDGROUP from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CLEARINGPERIOD] = stg.[CLEARINGPERIOD],
		tgt.[CREATEDBY] = stg.[CREATEDBY],
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DEFAULTDIMENSION] = stg.[DEFAULTDIMENSION],
		tgt.[EXCLUDEFROMSIGNUP_PSN] = stg.[EXCLUDEFROMSIGNUP_PSN],
		--tgt.[FileName] = stg.[FileName],
		tgt.[ISPUBLICSECTOR_IT] = stg.[ISPUBLICSECTOR_IT],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PAYMTERMID] = stg.[PAYMTERMID],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TAXGROUPID] = stg.[TAXGROUPID],
		tgt.[TAXPERIODPAYMENTCODE_PL] = stg.[TAXPERIODPAYMENTCODE_PL],
		tgt.[VENDACCOUNTNUMSEQ] = stg.[VENDACCOUNTNUMSEQ],
		tgt.[VENDGROUP] = stg.[VENDGROUP]
	 FROM [synapse_fo].[VENDGROUP] tgt
		INNER JOIN [staging_fo].[VENDGROUP] stg
			ON  stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
			AND stg.[VendGroup] = tgt.[VendGroup] 
		
END

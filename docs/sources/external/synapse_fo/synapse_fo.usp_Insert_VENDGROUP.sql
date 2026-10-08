CREATE     PROCEDURE [synapse_fo].[usp_Insert_VENDGROUP]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:02
	Description: Insert stored procedure for VENDGROUP from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[VENDGROUP]
	(
		[CLEARINGPERIOD],
		[CREATEDBY],
		[CREATEDDATETIME],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[DEFAULTDIMENSION],
		[EXCLUDEFROMSIGNUP_PSN],
		--[FileName],
		[ISPUBLICSECTOR_IT],
		[LastProcessedChange_DateTime],
		--[LSN],
		[NAME],
		[PARTITION],
		[PAYMTERMID],
		[RECID],
		[RECVERSION],
		--[SysRowId],
		[TAXGROUPID],
		[TAXPERIODPAYMENTCODE_PL],
		[VENDACCOUNTNUMSEQ],
		[VENDGROUP]
	)
	SELECT 
		stg.[CLEARINGPERIOD],
		stg.[CREATEDBY],
		stg.[CREATEDDATETIME],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[DEFAULTDIMENSION],
		stg.[EXCLUDEFROMSIGNUP_PSN],
		--stg.--[FileName],
		stg.[ISPUBLICSECTOR_IT],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[NAME],
		stg.[PARTITION],
		stg.[PAYMTERMID],
		stg.[RECID],
		stg.[RECVERSION],
		--stg.--[SysRowId],
		stg.[TAXGROUPID],
		stg.[TAXPERIODPAYMENTCODE_PL],
		stg.[VENDACCOUNTNUMSEQ],
		stg.[VENDGROUP]	
	FROM [staging_fo].[VENDGROUP] stg
		LEFT JOIN [synapse_fo].[VENDGROUP] tgt
			ON stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
			AND stg.[VendGroup] = tgt.[VendGroup] 
		
	WHERE tgt.[RECID] IS NULL
END

CREATE     PROCEDURE [synapse_fo].[usp_Insert_PURCHTABLE_W]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:58
	Description: Insert stored procedure for PURCHTABLE_W from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[PURCHTABLE_W]
	(
		[CREATEDDATETIME],
		[CUSTOMSIMPORTORDER_IN],
		[CUSTOMSINVOICEREGISTERED_IN],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[EMPLACCOUNT_RU],
		[FileName],
		[GSTAPPROVALNUMBER_MY],
		[INVOICEPOSTALADDRESS_TH],
		[INVOICETYPE_MY],
		[LastProcessedChange_DateTime],
		[LSN],
		[NATUREOFASSESSEE_IN],
		[PARTITION],
		[PURCHTABLE],
		[RECID],
		[RECVERSION],
		[SysRowId],
		[TAXBRANCH],
		[TAXGSTIMPORTDECLARATIONNO_MY],
		[TCSGROUP_IN],
		[TDSGROUP_IN],
		[WITHIGSTPAYMENT_IN]
	)
	SELECT 
		stg.[CREATEDDATETIME],
		stg.[CUSTOMSIMPORTORDER_IN],
		stg.[CUSTOMSINVOICEREGISTERED_IN],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[EMPLACCOUNT_RU],
		stg.[FileName],
		stg.[GSTAPPROVALNUMBER_MY],
		stg.[INVOICEPOSTALADDRESS_TH],
		stg.[INVOICETYPE_MY],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[NATUREOFASSESSEE_IN],
		stg.[PARTITION],
		stg.[PURCHTABLE],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId],
		stg.[TAXBRANCH],
		stg.[TAXGSTIMPORTDECLARATIONNO_MY],
		stg.[TCSGROUP_IN],
		stg.[TDSGROUP_IN],
		stg.[WITHIGSTPAYMENT_IN]	
	FROM [staging_fo].[PURCHTABLE_W] stg
		LEFT JOIN [synapse_fo].[PURCHTABLE_W] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

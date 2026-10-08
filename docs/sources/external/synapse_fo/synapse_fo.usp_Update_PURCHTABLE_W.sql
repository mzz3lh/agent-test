CREATE     PROCEDURE [synapse_fo].[usp_Update_PURCHTABLE_W]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:50
	Description: Update stored procedure for PURCHTABLE_W from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[CUSTOMSIMPORTORDER_IN] = stg.[CUSTOMSIMPORTORDER_IN],
		tgt.[CUSTOMSINVOICEREGISTERED_IN] = stg.[CUSTOMSINVOICEREGISTERED_IN],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[EMPLACCOUNT_RU] = stg.[EMPLACCOUNT_RU],
		tgt.[FileName] = stg.[FileName],
		tgt.[GSTAPPROVALNUMBER_MY] = stg.[GSTAPPROVALNUMBER_MY],
		tgt.[INVOICEPOSTALADDRESS_TH] = stg.[INVOICEPOSTALADDRESS_TH],
		tgt.[INVOICETYPE_MY] = stg.[INVOICETYPE_MY],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[NATUREOFASSESSEE_IN] = stg.[NATUREOFASSESSEE_IN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PURCHTABLE] = stg.[PURCHTABLE],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TAXBRANCH] = stg.[TAXBRANCH],
		tgt.[TAXGSTIMPORTDECLARATIONNO_MY] = stg.[TAXGSTIMPORTDECLARATIONNO_MY],
		tgt.[TCSGROUP_IN] = stg.[TCSGROUP_IN],
		tgt.[TDSGROUP_IN] = stg.[TDSGROUP_IN],
		tgt.[WITHIGSTPAYMENT_IN] = stg.[WITHIGSTPAYMENT_IN]
	 FROM [synapse_fo].[PURCHTABLE_W] tgt
		INNER JOIN [staging_fo].[PURCHTABLE_W] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

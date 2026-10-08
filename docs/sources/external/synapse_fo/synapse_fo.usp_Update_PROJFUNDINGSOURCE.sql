CREATE     PROCEDURE [synapse_fo].[usp_Update_PROJFUNDINGSOURCE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:49
	Description: Update stored procedure for PROJFUNDINGSOURCE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CASHDISCOUNTID] = stg.[CASHDISCOUNTID],
		tgt.[CONTACTPERSONID] = stg.[CONTACTPERSONID],
		tgt.[CONTRACTID] = stg.[CONTRACTID],
		tgt.[CUSTACCOUNT] = stg.[CUSTACCOUNT],
		tgt.[CUSTPURCHASEORDER] = stg.[CUSTPURCHASEORDER],
		tgt.[CUSTREF] = stg.[CUSTREF],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DEFAULTDIMENSION] = stg.[DEFAULTDIMENSION],
		tgt.[EINVOICEACCOUNTCODE] = stg.[EINVOICEACCOUNTCODE],
		tgt.[EINVOICELINESPEC] = stg.[EINVOICELINESPEC],
		--tgt.[FileName] = stg.[FileName],
		tgt.[FUNDINGSOURCEID] = stg.[FUNDINGSOURCEID],
		tgt.[FUNDINGTYPE] = stg.[FUNDINGTYPE],
		tgt.[GIROTYPE] = stg.[GIROTYPE],
		tgt.[INDIVIDUALBUFFER] = stg.[INDIVIDUALBUFFER],
		tgt.[INVOICELOCATION] = stg.[INVOICELOCATION],
		tgt.[INVOICENAME] = stg.[INVOICENAME],
		tgt.[LANGUAGEID] = stg.[LANGUAGEID],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[NUMBERSEQUENCEGROUPID] = stg.[NUMBERSEQUENCEGROUPID],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PARTY] = stg.[PARTY],
		tgt.[PAYMENTSCHEDULEID] = stg.[PAYMENTSCHEDULEID],
		tgt.[PAYMENTTERMSID] = stg.[PAYMENTTERMSID],
		tgt.[POSTINGPROFILE] = stg.[POSTINGPROFILE],
		tgt.[PROJECTMANAGER] = stg.[PROJECTMANAGER],
		tgt.[PROJGRANT] = stg.[PROJGRANT],
		tgt.[PSACUSTRETENTIONTERMID] = stg.[PSACUSTRETENTIONTERMID],
		tgt.[PSAINVOICEFORMATS] = stg.[PSAINVOICEFORMATS],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TAXPERIODPAYMENTCODE_PL] = stg.[TAXPERIODPAYMENTCODE_PL]
	 FROM [synapse_fo].[PROJFUNDINGSOURCE] tgt
		INNER JOIN [staging_fo].[PROJFUNDINGSOURCE] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

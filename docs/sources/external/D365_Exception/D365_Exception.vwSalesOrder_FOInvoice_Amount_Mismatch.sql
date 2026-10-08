CREATE    VIEW [D365_Exception].[vwSalesOrder_FOInvoice_Amount_Mismatch]
AS

/*
WITH cte AS
(
	SELECT 
		SALESID
		,SUM(LineAmount) LineAmount
		,SUM(LINEAMOUNTMST) AS LINEAMOUNTMST
		,SUM(LINEAMOUNTTAX) AS LINEAMOUNTTAX
		,SUM(LINEAMOUNTTAXMST) AS LINEAMOUNTTAXMST
		,SUM(TAXAMOUNT) AS TAXAMOUNT
		,SUM(TAXAMOUNTMST) AS TAXAMOUNTMST
		
	FROM FO.vwCustInvoiceTrans
	GROUP BY SALESID
	
)
*/
WITH InvoiceJour AS
(
	SELECT 
		SALESID,
		SUM(INVOICEAMOUNT) AS INVOICEAMOUNT, 
		SUM(INVOICEAMOUNTMST) AS INVOICEAMOUNTMST, 
		SUM(SUMTAX) AS SUMTAX, 
		SUM(SUMTAXMST) AS SUMTAXMST, 
		SUM(SALESBALANCE) AS SALESBALANCE, 
		SUM(SALESBALANCEMST) AS SALESBALANCEMST, 
		SUM(SUMMARKUP) AS SUMMARKUP, 
		SUM(SUMMARKUPMST) AS SUMMARKUPMST		
	FROM synapse_fo.CUSTINVOICEJOUR
	GROUP BY 
		SALESID
)
,ceInvoice AS
(
	SELECT
		inv.[salesorderid]
		,SUM(inv.[totallineitemamount]) AS [totallineitemamount]
		,SUM(inv.[totallineitemamount_base]) AS [totallineitemamount_base]
		,SUM(inv.[totaltax]) AS [totaltax]
		,SUM(inv.[totaltax_base]) AS [totaltax_base]
		,SUM(inv.[freightamount]) AS [freightamount]
		,SUM(inv.[freightamount_base]) AS [freightamount_base]
	FROM synapse_ce.invoice inv
	GROUP BY
		inv.[salesorderid]
)
SELECT 
	REPLACE(q.[quotenumber], 'rcs', '') AS [QuoteNumber],
	q.[name],
	ownid.[FullName] AS [Owner],
	q.[createdon] AS [Quote_CreatedOn],
	q.[statuscode],
	q.[StatusCode_Description],
	q.[statecode],
	q.[StateCode_Description],
	cnt.[FullName] AS [CustomerIdName],
	cntbillto.[fullname] AS [BillTo_ContactName],
	q.[apuk_paymentmethod],
	q.[apuk_paymentmethod_description],
	q.[msdyn_isocurrencycode] AS [Currency],
	q.[totalamount] + ISNULL(so.[apuk_lionheartdonation], 0) AS [totalamount],
	q.[totalamount_base] + ISNULL(so.[apuk_lionheartdonation_base], 0) AS totalamount_base,
	q.[totalamountlessfreight],
	q.[totalamountlessfreight_base],
	q.[totaltax],
	q.[totaltax_base],
	q.[apuk_lionheartdonation],
	q.[apuk_lionheartdonation_base],
	so.msdyn_salesordernumber AS OrderNumber, 
	so.StateCode_Description AS Order_State, 
	so.[CreatedOn] AS [SO_CreatedOn],
	so.TransactionCurrencyIdName AS Order_Currency,
	so.TotalAmount AS SO_TotalAmount, 
	so.TotalAmount_Base AS SO_TotalAmount_Base, 
	so.TotalLineItemAmount AS SO_TotalLineAmount,
	so.TotalLineItemAmount_Base AS SO_TotalLineAmount_Base,
	so.TotalTax AS SO_TotalTax, 
	so.TotalTax_Base AS SO_TotalTax_Base, 
	so.apuk_lionheartdonation AS SO_LHL_Donation, 
	so.apuk_lionheartdonation_base AS SO_LHL_Donation_Base, 
	so.TotalAmountLessFreight AS SO_TotalAmountLessFreight, 
	so.TotalAmountLessFreight_Base AS SO_TotalAmountLessFreight_Base, 
	cij.INVOICEAMOUNT AS FO_JournalHeader_Invoiceamount, 
	cij.INVOICEAMOUNTMST AS FO_JournalHeader_InvoiceamountMST, 
	cij.SUMTAX AS FO_JournalHeader_Tax, 
	cij.SUMTAXMST AS FO_JournalHeader_TaxMST,
--	cid.LINEAMOUNT AS FO_JournalLine_LineAmount,
--	cid.LINEAMOUNTMST AS FO_JournalLine_LineAmountMST,
--	cid.LINEAMOUNTTAX AS FO_JournalLine_LineAmountTax,
--	cid.LINEAMOUNTTAXMST AS FO_JournalLine_LineAmountTaxMST,
--	cid.TAXAMOUNT AS FO_JournalLine_TaxAmount,
--	cid.TAXAMOUNTMST AS FO_JournalLine_TaxAmountMST,
/*
	CASE
		WHEN q.[totalamount] + ISNULL(so.[apuk_lionheartdonation], 0) <> cij.[INVOICEAMOUNT] THEN 'Amount Mismatch'
		WHEN so.[TotalTax] <> cij.[SUMTAX] THEN 'Tax Mismatch'
	END AS [Exception_Reason]
*/


	CASE
		WHEN 
			(
				((so.[TotalLineItemAmount] + ISNULL(so.[apuk_lionheartdonation], 0)) <> (cij.[salesbalance] + cij.[summarkup]))
				AND 
				((inv.[totallineitemamount] + ISNULL(inv.[freightamount], 0)) = (cij.[salesbalance] + cij.[summarkup]))
			)
			THEN 'Amounts Mismatch between Sales Order and FO INvoice but CE Invoice Amount and FO Invoice Amounts match'
		WHEN 
			(
				((so.[TotalLineItemAmount] + ISNULL(so.[apuk_lionheartdonation], 0)) <> (cij.[salesbalance] + cij.[summarkup]))
				AND 
				((inv.[totallineitemamount] + ISNULL(inv.[freightamount], 0)) <> (cij.[salesbalance] + cij.[summarkup]))
			)
			THEN 'Amounts Mismatch'
		WHEN 
			(
				((so.[TotalLineItemAmount] + ISNULL(so.[apuk_lionheartdonation], 0)) = (cij.[salesbalance] + cij.[summarkup]))
				AND 
				((inv.[totallineitemamount] + ISNULL(inv.[freightamount], 0)) <> (cij.[salesbalance] + cij.[summarkup]))
			)
			THEN 'Amounts Mismatch between CE Invoice and FO Invoice'

		WHEN 
			so.[TotalLineItemAmount] + ISNULL(so.[apuk_lionheartdonation], 0) <> (cij.[salesbalance] + cij.[summarkup]) THEN 'Amount Mismatch'
		
		WHEN 
			((so.[TotalTax] <> cij.[SUMTAX]) AND (inv.[TotalTax] = cij.[SUMTAX])) THEN 'Tax Mismatch between SalesOrder and FO Invoice But Invoice Tax matches'
		WHEN 
			((so.[TotalTax] <> cij.[SUMTAX]) AND (inv.[TotalTax] <> cij.[SUMTAX])) THEN 'Tax Mismatch between SalesOrder and FO Invoice AND CE Invoice and FO Invoice'
		WHEN	
			inv.[TotalTax] <> cij.[SUMTAX] THEN 'Tax Mismatch between CE Invoice and FO Invoice'
	END AS [Exception_Reason]

	,inv.totallineitemamount, inv.freightamount

FROM synapse_ce.vwQuote q
	INNER JOIN synapse_ce.vwSalesOrder so
		ON q.quoteid = so.quoteid
	INNER JOIN ceInvoice inv
		ON so.SalesOrderId = inv.salesorderid
	INNER JOIN InvoiceJour cij
		ON so.msdyn_salesordernumber = cij.SALESID
--	INNER JOIN cte cid
--		ON cij.SALESID = cid.SALESID
	LEFT JOIN [synapse_ce].[tblContact_BI] cnt
		ON q.[customerid] = cnt.[ContactId]
	LEFT JOIN [synapse_ce].[tblContact_BI] cntbillto
		ON q.[apuk_billto] = cntbillto.[ContactId]
	LEFT JOIN synapse_ce.SystemUser ownid
		ON q.[ownerid] = ownid.[SystemUserId]
WHERE so.StateCode_Description = 'Invoiced'

	AND 
		(
		inv.[totallineitemamount] + ISNULL(inv.[freightamount], 0) <> (cij.[salesbalance] + cij.[summarkup])
		OR
		--so.[TotalTax] <> cij.[SUMTAX]
		--OR 
		inv.[totaltax] <> cij.[SUMTAX]
		)

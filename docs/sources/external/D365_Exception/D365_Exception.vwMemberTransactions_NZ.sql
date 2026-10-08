CREATE   VIEW [D365_Exception].[vwMemberTransactions_NZ]
AS


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
	REPLACE(so.OrderNumber, 'rcs', '') AS OrderNumber, 
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
	so.[apuk_firmreinbursessubs]
FROM synapse_ce.vwQuote q
	INNER JOIN synapse_ce.vwSalesOrder so
		ON q.quoteid = so.quoteid
	INNER JOIN FO.vwCustInvoiceJour cij
		ON REPLACE(so.OrderNumber, 'rcs', '') = cij.SALESID
	LEFT JOIN [synapse_ce].[tblContact_BI] cnt
		ON q.[customerid] = cnt.[ContactId]
	LEFT JOIN [synapse_ce].[tblContact_BI] cntbillto
		ON q.[apuk_billto] = cntbillto.[ContactId]
	LEFT JOIN synapse_ce.SystemUser ownid
		ON q.[ownerid] = ownid.[SystemUserId]
WHERE so.StateCode_Description = 'Invoiced'
	AND cij.[INVOICEID] NOT LIKE 'CRE%'
	AND cnt.[rics_localgroupidName] = 'New Zealand'

CREATE   VIEW [D365_Exception].[vwSalesorder_Status_Mismatch]
AS
SELECT 
		cij.INVOICEID,
		cij.INVOICEACCOUNT,
		cij.SALESID,
		cij.[INVOICEDATE],
		--cij.CONTACTPERSONID,
		so.PaymentMethod_Description AS Payment_Method,
		so.StatusCode_Description AS [Status],
		acc.name AS [AccountIdName],
		so.apuk_eventcode,
		so.CreatedOn,
		cnt.fullname AS CustomerIdName,
		--so.OrderNumber,
		so.[Name] AS [SalesOrder_Name],
		so.OwnerIdName,
		so.[TransactionCurrencyIdName] AS [Currency],
		so.TotalAmount,
		so.TotalAmount_Base,
		so.TotalTax,
		so.TotalTax_Base,
		so.TotalLineItemAmount,
		so.TotalLineItemAmount_Base,
		so.TotalLineItemDiscountAmount,
		so.TotalLineItemDiscountAmount_Base,
		so.apuk_lionheartdonation,
		so.apuk_lionheartdonation_base
 FROM synapse_ce.vwSalesOrder so
       LEFT JOIN FO.vwCustInvoiceJour cij
			ON REPLACE(so.OrderNumber, 'rcs', '') = cij.SALESID
		LEFT JOIN synapse_ce.tblContact_BI cnt
			ON so.[customerid] = cnt.[ContactId]
		LEFT JOIN synapse_ce.Account acc
			ON cnt.[ParentCustomerId] = acc.[AccountId]
WHERE so.[StatusCode_Description] <> 'Invoiced'
	AND so.[CreatedOn] > '2021-08-24'
--	AND so.[OrderNumber] = 'rcsORD-000000-R2J7D9'

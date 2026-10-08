CREATE    VIEW [D365_Exception].[vwSalesOrder_NoVatGroup]
AS
/*
WITH cte AS
(
	SELECT 
		cij.SALESID,
		cij.INVOICEID
	FROM FO.vwCustInvoiceJour_Detailed cij
	GROUP BY 
)
*/
SELECT 
	st.[SALESID] AS [Order Number],
	--st.SALESTYPE AS [Order Type],
	CASE
		WHEN st.[SALESTYPE] = 0 THEN 'Journal'
		WHEN st.[SALESTYPE] = 1 THEN 'DEL_Quotation'
		WHEN st.[SALESTYPE] = 2 THEN 'Subscription'
		WHEN st.[SALESTYPE] = 3 THEN 'Sales Order'
		WHEN st.[SALESTYPE] = 4 THEN 'Return Item'
		WHEN st.[SALESTYPE] = 5 THEN 'DEL_Blanket'
		WHEN st.[SALESTYPE] = 6 THEN 'ItemReq'
	END AS [Order Type],
	st.[CUSTACCOUNT],
	st.[INVOICEACCOUNT],
	--st.[SALESSTATUS],
	CASE
		WHEN st.[SALESSTATUS] = 0 THEN 'None'
		WHEN st.[SALESSTATUS] = 1 THEN 'Open Order'
		WHEN st.[SALESSTATUS] = 2 THEN 'Delivered'
		WHEN st.[SALESSTATUS] = 3 THEN 'Invoiced'
		WHEN st.[SALESSTATUS] = 4 THEN 'Cancelled'
	END [Sales Status],

	st.[CURRENCYCODE] AS [Currency],
	st.[DELIVERYDATE] AS [Delivery Date],
	st.[PURCHORDERFORMNUM] AS [Customer Requisition],
	--NULL AS [Direct Debit Fee],
	so.apuk_lionheartdonation_base AS [Lion Heart Donation Fee],
	sl.LINENUM AS [Line Number],
	sl.ITEMID AS [Product Id],
	sl.NAME AS [Product Name],
	sl.TAXITEMGROUP AS [VAT Item Group],
	sl.TAXGROUP AS [VAT Group],
	--st.TAXGROUP AS [Tax Group],
	ct.TaxGroup AS [Customer VAT Group],

	sl.LINEAMOUNT AS [Line Amount],
	st.PAYMMODE AS [Method Of Payment],
	st.[PAYMENTSCHED] AS [Payment Schedule],
	st.SALESNAME AS [Customer Name],
	--st.custgroup,
	CASE
		WHEN st.[CUSTGROUP] = 10 THEN 'Members'
		WHEN st.[CUSTGROUP] = 20 THEN 'Non-Members'
		WHEN st.[CUSTGROUP] = 30 THEN 'Firms'
		WHEN st.[CUSTGROUP] = 40 THEN 'Intercompany'
	END AS [Cust Group],
	CASE
		WHEN sl.[TAXGROUP] = '' THEN 'Missing VAT Group'
		WHEN sl.[TAXITEMGROUP] = '' THEN 'Missing VAT Item Group'
	END AS [Exception Type]

FROM synapse_fo.SalesTable st
	INNER JOIN synapse_fo.SalesLine sl
		ON st.SALESID = sl.SALESID
	INNER JOIN synapse_ce.SalesOrder so
		ON so.OrderNumber = 'rcs'+st.SALESID
	LEFT JOIN synapse_fo.CustTable ct
		ON st.CUSTACCOUNT = ct.AccountNum

WHERE (sl.[TAXGROUP] = '' OR sl.[TAXITEMGROUP] = '')

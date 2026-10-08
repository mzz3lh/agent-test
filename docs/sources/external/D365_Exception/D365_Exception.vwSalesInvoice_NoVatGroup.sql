CREATE    VIEW [D365_Exception].[vwSalesInvoice_NoVatGroup]
AS
SELECT 
	cj.[SALESID] AS [Order Number],
	cj.[INVOICEID],
	cj.[INVOICEDATE],
	CASE
		WHEN st.[SALESTYPE] = 0 THEN 'Journal'
		WHEN st.[SALESTYPE] = 1 THEN 'DEL_Quotation'
		WHEN st.[SALESTYPE] = 2 THEN 'Subscription'
		WHEN st.[SALESTYPE] = 3 THEN 'Sales Order'
		WHEN st.[SALESTYPE] = 4 THEN 'Return Item'
		WHEN st.[SALESTYPE] = 5 THEN 'DEL_Blanket'
		WHEN st.[SALESTYPE] = 6 THEN 'ItemReq'
	END AS [Order Type],
	st.[CUSTACCOUNT] AS [Order Account],
	st.[INVOICEACCOUNT] AS [Invoice Account],

	CASE
		WHEN st.[SALESSTATUS] = 0 THEN 'None'
		WHEN st.[SALESSTATUS] = 1 THEN 'Open Order'
		WHEN st.[SALESSTATUS] = 2 THEN 'Delivered'
		WHEN st.[SALESSTATUS] = 3 THEN 'Invoiced'
		WHEN st.[SALESSTATUS] = 4 THEN 'Cancelled'
	END [Sales Status],

	cj.[CURRENCYCODE] AS [Currency],
	st.[DELIVERYDATE] AS [Delivery Date],
	st.[PURCHORDERFORMNUM] AS [Customer Requisition],
	cj.ITEMID AS [Product Id],
	cj.NAME AS [Product Name],
	cj.LINENUM AS [Line Number],
	cj.TAXITEMGROUP AS [VAT Item Group],
	cj.TAXGROUP AS [VAT Group],
	ct.TaxGroup AS [Customer VAT Group],

	cj.LINEAMOUNT AS [Line Amount],
	cj.LINEAMOUNTTAX,
	cj.SALESMARKUP,
	cj.TAXAMOUNT,
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
		WHEN cj.[TAXGROUP] = '' THEN 'Missing VAT Group'
		WHEN cj.[TAXITEMGROUP] = '' THEN 'Missing VAT Item Group'
	END AS [Exception Type]

FROM FO.vwCustInvoiceTrans cj
	INNER JOIN synapse_fo.SalesTable st
		ON cj.SALESID = st.SALESID
	LEFT JOIN synapse_fo.CustTable ct
		ON st.CUSTACCOUNT = ct.AccountNum

WHERE (cj.[TAXGROUP] = '' OR cj.[TAXITEMGROUP] = '')

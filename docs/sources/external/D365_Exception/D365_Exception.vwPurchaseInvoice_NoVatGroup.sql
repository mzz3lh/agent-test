CREATE    VIEW [D365_Exception].[vwPurchaseInvoice_NoVatGroup]
AS
WITH cteVendTrans AS
(
	SELECT 
		PURCHID,
		MAX(TAXITEMGROUP) AS TAXITEMGROUP
	FROM synapse_fo.VENDINVOICETRANS --FO.tblVendInvoiceTrans
	GROUP BY 
		PURCHID
)
SELECT 
	vit.[PURCHID] AS [Purchase Order Number],
	ph.[PURCHNAME] AS [Supplier Name],
	ph.ORDERACCOUNT AS [Supplier Account],
	ph.INVOICEACCOUNT AS [Invoice Account],

	vit.[INVOICEID] AS [Invoice Id],
	vit.[INVOICEDATE] AS [Invoice Date],
	vit.[INVOICEAMOUNT] AS [Invoice Amount],
	vit.[SUMTAX] AS [Tax Amount],
	vit.[SALESBALANCE]	 AS [Amount Excl Tax],


	vit.CURRENCYCODE AS Currency,
	ph.DELIVERYDATE AS [Delivery Date],
	vit.TAXGROUP AS [VAT Group],
	trans.[TAXITEMGROUP] AS [VAT Item Group],
	vt.TAXGROUP AS [Supplier VAT Group],
	--ph.[PURCHASETYPE] AS [Purchase Type],
	CASE
		WHEN ph.[PURCHASETYPE] =1 THEN 'Journal'
		WHEN ph.[PURCHASETYPE] =3 THEN 'Purchase Order'
		WHEN ph.[PURCHASETYPE] =2 THEN 'Returned Order'
	END AS [Purchase Type],
	ph.[VENDGROUP] AS [Supplier Group],
	--ph.[PURCHSTATUS] AS PurchaseStatus,
	CASE
		WHEN ph.[PURCHSTATUS] = 0 THEN 'None'
		WHEN ph.[PURCHSTATUS] = 1 THEN 'Open Order'
		WHEN ph.[PURCHSTATUS] = 2 THEN 'Received'
		WHEN ph.[PURCHSTATUS] = 3 THEN 'Invoiced'
		WHEN ph.[PURCHSTATUS] = 4 THEN 'Canceled'
	END AS [Purchase Status],
	--ph.[DOCUMENTSTATE] AS ApprovalState,
	CASE
		WHEN ph.[DOCUMENTSTATE] = 0 THEN 'Draft'
		WHEN ph.[DOCUMENTSTATE] = 10 THEN 'InReview'
		WHEN ph.[DOCUMENTSTATE] = 20 THEN 'Rejected'
		WHEN ph.[DOCUMENTSTATE] = 30 THEN 'Approved'
		WHEN ph.[DOCUMENTSTATE] = 35 THEN 'InExternalReview'
		WHEN ph.[DOCUMENTSTATE] = 40 THEN 'Confirmed'
		WHEN ph.[DOCUMENTSTATE] = 50 THEN 'Finalized'
	END AS [Approval State],
	ph.[ACCOUNTINGDATE] AS [Accounting Date],
	ph.PAYMENT AS Payment,
	ph.PAYMMODE AS [Payment Mode],
	ph.PAYMSPEC AS [Payment Spec],
	CASE
		WHEN vit.[TAXGROUP] = '' THEN 'Missing VAT Group'
		WHEN trans.[TAXITEMGROUP] = '' THEN 'Missing VAT Item Group'
	END AS [Exception Type]
FROM synapse_fo.VENDINVOICEJOUR vit
	INNER JOIN synapse_fo.PURCHTABLE ph
		ON vit.PURCHID = ph.PURCHID
	INNER JOIN cteVendTrans trans
		ON vit.PURCHID = trans.PURCHID
	INNER JOIN synapse_fo.VENDTABLE vt
		ON ph.ORDERACCOUNT = vt.ACCOUNTNUM
WHERE (vit.TAXGROUP = '' OR trans.TAXITEMGROUP = '')

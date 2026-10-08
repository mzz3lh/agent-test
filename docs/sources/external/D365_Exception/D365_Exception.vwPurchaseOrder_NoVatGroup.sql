CREATE    VIEW [D365_Exception].[vwPurchaseOrder_NoVatGroup]
AS
SELECT 
	ph.[PURCHID] AS [Purchase Order Number],
	ph.[PURCHNAME] AS [Supplier Name],
	ph.ORDERACCOUNT AS [Supplier Account],
	ph.INVOICEACCOUNT AS [Invoice Account],
	ph.CURRENCYCODE AS Currency,
	ph.DELIVERYDATE AS [Delivery Date],
	ph.TAXGROUP AS [VAT Group],
	pl.[TAXITEMGROUP] AS [VAT Item Group],
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
		WHEN ph.[TAXGROUP] = '' THEN 'Missing VAT Group'
		WHEN pl.[TAXITEMGROUP] = '' THEN 'Missing VAT Item Group'
	END AS [Exception Type]
FROM synapse_fo.PurchTable ph
	INNER JOIN synapse_fo.PurchLine pl
		ON ph.PURCHID = pl.PURCHID
	INNER JOIN synapse_fo.VendTable vt
		ON ph.ORDERACCOUNT = vt.ACCOUNTNUM
WHERE (ph.TAXGROUP = '' OR pl.TAXITEMGROUP = '')

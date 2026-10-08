CREATE   VIEW [PurchaseOrder].[vwAcrualReport_FO]
AS
WITH ctePurchInvoiceJournals AS
(
	SELECT 
		[PURCHID],
		[DATAAREAID],
		SUM([INVOICEAMOUNT]) AS [Invoice_Amount],
		SUM([SUMTAX]) AS [Total_Tax],
		SUM([SALESBALANCE]) AS [Sales_Balance],
		COUNT(*) AS [Num_Invoices]
	FROM [FO].[tblVendInvoiceJour]
	--WHERE PURCHID = 'RCS-000000'
	GROUP BY 
			[PURCHID],
			[DATAAREAID]
)

SELECT 
	pl.[PURCHID] AS [PurchaseOrder Number], 
	pl.[VENDACCOUNT] AS [Supplier Account],
	pl.VENDACCOUNT AS [Invoice Account],
	vt.[COUNTRYREGIONID] AS [Vendor Country],
	pt.[VENDGROUP] AS [Vend Group],
	pt.[PURCHNAME] AS [Supplier Name],
	ptype.[Description] AS [Purchase Type],
	postatus.[Description] AS [Purchase Order Status],
	appst.[Description] AS [Approval State],
	pl.[NAME] AS [Line Description],
	pl.[CURRENCYCODE] AS [Currency],
	pl.[DELIVERYDATE] AS [Delivery Date],
	pt.[ACCOUNTINGDATE] AS [Accounting Date],
	invproc.[MainAccount] AS [Main Account],
	lt.[NAME] AS [Main Account Name],
	pl.[DEFAULTDIMENSIONDISPLAYVALUE] AS [Dimension Display Value],
	SUBSTRING(pl.DEFAULTDIMENSIONDISPLAYVALUE, CHARINDEX('-', pl.DEFAULTDIMENSIONDISPLAYVALUE)+1, 4) AS CostCentre,
	cc.[CostCentre_Name] AS [CostCentre_Description],
	pl.[PROCUREMENTPRODUCTCATEGORYNAME] AS [Procurement Category],
	pl.[LINENUMBER] AS [Line Number],
	pl.[PURCHQTY] AS [Qunatity],
	pl.[PURCHPRICE] AS [Unit Price],
	pl.[LINEAMOUNT] AS [Line Amount],
	vij.[Num_Invoices] AS [No Invoices],
	vij.[Invoice_Amount] AS [Gross Invoice Amount],
	vij.[Total_Tax] AS [Total Tax],
	vij.[Invoice_Amount] - vij.[Total_Tax] AS [Net Amount],

	vij.[Sales_Balance] AS [Balance],
	pl.[TAXGROUP],
	pt.[REQUESTERPERSONNELNUMBER] AS [Requester Number],
	party.[NAME] AS [Requested By],
	pl.[PURCHREQID] AS [Requisition Number]
FROM [FO].[tblPurchTable] pt
	LEFT JOIN [FO].[tblPurchLine] pl
		ON pt.[PURCHID] = pl.[PURCHID]
		AND pt.[DATAAREAID] = pl.[DATAAREAID]
	LEFT JOIN FO.vwVendTable vt
		ON pl.[VENDACCOUNT] = vt.[ACCOUNTNUM]
	LEFT JOIN [FO].[vwPurchaseOrderStatus] postatus
		ON pt.[PURCHSTATUS] = postatus.[PurchStatus]
	LEFT JOIN [FO].[vwPurchType] ptype
		ON pt.[PURCHASETYPE] = ptype.[PurchType]
	LEFT JOIN [FO].[vwPurchApprovalState] appst
		ON pt.[DOCUMENTSTATE] = appst.[ApprovalState]
	LEFT JOIN [FO].[vwInventProcurementLedgerPostingDefinition] invproc
		ON pl.[PROCUREMENTPRODUCTCATEGORYNAME] = invproc.[ProductCategoryName]
		AND pl.[DATAAREAID] = invproc.[DataAreaId] 
		AND invproc.[INVENTORYACCOUNTTYPE] = 63  --Only expenses. 
	LEFT JOIN ctePurchInvoiceJournals vij
		ON pt.[PURCHID] = vij.[PURCHID]
		AND pt.[DATAAREAID] = vij.[DATAAREAID]
		AND pl.[LINENUMBER] = 1
	LEFT JOIN [FO].[vwLedgerTable] lt
		ON invproc.[MainAccount] = lt.[MAINACCOUNTID]
	LEFT JOIN [FO].[vwCostCentre] cc
		ON SUBSTRING(pl.DEFAULTDIMENSIONDISPLAYVALUE, CHARINDEX('-', pl.DEFAULTDIMENSIONDISPLAYVALUE)+1, 4) = cc.CostCentre_Code
	LEFT JOIN [FO].[vwHcmWorker] worker
		ON pt.[REQUESTERPERSONNELNUMBER] = worker.[PERSONNELNUMBER]
	LEFT JOIN [FO].[vwDirPartyTable] party
		ON worker.[PERSON] = party.[RECID]
--WHERE pl.purchid = 'RCS-000000'--'RCS-000000'

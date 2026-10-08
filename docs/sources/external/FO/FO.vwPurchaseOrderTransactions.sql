CREATE         VIEW [FO].[vwPurchaseOrderTransactions]
AS
/*
WITH cteInvoices AS
(
	SELECT 
		vij.[PURCHID]
		,vit.[INVENTTRANSID]
		,COUNT(vit.[Invoiceid]) AS [Invoice Count]
		,SUM(vij.[INVOICEAMOUNT]) AS [Invoice Amount]
		,SUM(vij.[INVOICEAMOUNTMST]) AS [Invoice Amount MST]
		,SUM(vij.[SUMTAX]) AS [Tax Amount]
		,SUM(vij.[SALESBALANCE]) AS [Sales Balance]
	FROM [synapse_fo].[VENDINVOICEJOUR] vij
		LEFT JOIN [synapse_fo].[VENDINVOICETRANS] vit
			ON vij.[PURCHID] = vit.[PURCHID]
			AND vij.[INVOICEID] = vit.[INVOICEID]
			--AND vij.[NUMBERSEQUENCEGROUP] = vit.[NUMBERSEQUENCEGROUP]
			AND vij.[INTERNALINVOICEID] = vit.[INTERNALINVOICEID]
			AND vij.[INVOICEDATE] = vit.[INVOICEDATE]
	GROUP BY
		vij.[PURCHID]
		,vit.[INVENTTRANSID]
)
*/
WITH cte1 AS
(
	SELECT
		ISNULL(PURCHID, '') AS PURCHID,
		COUNT(INVOICEID) AS [Invoice Count],
		SUM(INVOICEAMOUNT) AS INVOICEAMOUNT,
		SUM(INVOICEAMOUNTMST) AS INVOICEAMOUNTMST,
		SUM(SUMTAX) AS SUMTAX,
		SUM(SALESBALANCE) AS SALESBALANCE
	FROM synapse_fo.VENDINVOICEJOUR
	GROUP BY 
		ISNULL(PURCHID, '')
),
cte2 AS
(
	SELECT
		ISNULL(PURCHID, '') AS PURCHID,
		INVENTTRANSID,
		SUM(LINEAMOUNT) AS [Line Amount],
		SUM(LINEAMOUNTMST) AS [Line Amount MST]
	FROM synapse_fo.VENDINVOICETRANS
	GROUP BY 
		ISNULL(PURCHID, ''),
		INVENTTRANSID
)
/*,
cteInvoices AS
(
	SELECT 
		t1.PURCHID,
		t1.INVOICEID,
		t1.INVOICEAMOUNT AS [Invoice Amount],
		t1.INVOICEAMOUNTMST AS [Invoice Amount MST],
		t1.SUMTAX AS [Tax Amount],
		t1.SALESBALANCE AS [Sales Balance],
		t2.[Num Invoices] AS [Invoice Count],
		t2.[Num Lines],
		t2.[Line Amount],
		t2.[Line Amount MST]
	FROM cte1 t1
		LEFT JOIN cte2 t2
			ON t1.PURCHID = t2.PURCHID
			AND t1.INVOICEID = t2.INVOICEID
)
*/
SELECT 
	pt.[PURCHID] AS [Purchase Order No]
	,pt.[INVOICEACCOUNT] AS [Invoice Account]
	,pt.[WORKERPURCHPLACER] AS [Purchaser Code]
	,pt.[DOCUMENTSTATE] AS [Approval State]
	,CAST(pt.[ACCOUNTINGDATE] AS date) AS [Accounting Date]
	,CAST(pt.CREATEDDATETIME AS date)  AS [Created Date]
	,pl.[DataAreaId]
	,pl.[InventTransId]
	,pl.[ItemId]
	,pl.[VendAccount] AS [Vendor Account]
	,pl.[REMAINPURCHPHYSICAL]
	,pl.[REMAINPURCHFINANCIAL]
	,pl.[QTYORDERED]
	,pl.[PURCHSTATUS]
	,pl.[PURCHUNIT]
	,ISNULL((pl.[REMAINPURCHPHYSICAL]+pl.[REMAINPURCHFINANCIAL]), 0.0) AS [Outstanding Quantity]
	,pl.[LINEAMOUNT] AS [Line Amount]
	,pl.[INVENTDIMID]
	,ISNULL((pl.[LINEAMOUNT]/exr.[ExchangeRate]), 0.0) AS [Line Amount MST]

	,exr.ExchangeRate
	,exr.RateTypeName
	,exr.FromCurrency
	,exr.ToCurrency
	,exr.FromDate
	,exr.ToDate

	,pl.[PURCHASETYPE]
	,pl.[CURRENCYCODE] AS [Currency Code]
	,CAST(pl.[DELIVERYDATE] AS date) AS [Delivery Date]
--	,((ISNULL((pl.[REMAINPURCHPHYSICAL]+pl.[REMAINPURCHFINANCIAL]), 0.0)/ISNULL(pl.[QTYORDERED], 1.0))*(ISNULL((pl.[LINEAMOUNT]/100 * exr.[ExchangeRate]), 1.0))) AS [Outstanding Lime Amt MST]
	,pl.[NAME] AS [Line Description]
	,pl.[DEFAULTDIMENSIONDISPLAYVALUE]
	,pl.[COSTCENTER] AS [Cost Center Code]
	,pl.[LINENUMBER] AS [Line Number]
	,pl.[PURCHQTY] AS [Quantity]
	,pl.[PURCHPRICE] AS [Unit Price]
	,pl.[TAXGROUP] 
	,pl.[PURCHREQID] AS [Requisition Number]
	--,pl.[TAXITEMGROUP]
	,pl.[TAXITEMGROUP] AS [VAT Status]
	,lpd.[MAINACCOUNT] AS [Main Account No] 

	,pl.[PARTITION]
	,CAST(pl.[REQUESTER] AS nvarchar(10)) + '_' + CAST(pl.[PARTITION] AS NVARCHAR(10)) AS [HcmWorker Key]
	,rescat.[NAME] AS [Procurement Product Category Name]
	,pl.[PROCUREMENTCATEGORY] AS [SupplierCategoryId]
	,pl.[INVENTTRANSID] + '_' + pl.[DATAAREAID] AS [Invent Trans Key]
	,pl.[DATAAREAID] + '_' + CAST(pl.[PARTITION] AS NVARCHAR(200)) AS [Vend Invoice Jour Key]
	,pl.[COUNTRY]
	,pl.[PRODUCTCODE]
	,pl.[PRODUCTGROUP]
	,pl.[PROJECT]
	,pl.[MAINACCOUNT] AS [Ledger Account]
	,IIF(pl.[ISINVOICEMATCHED] = 1, 'Yes', 'No') AS IsInvoiceMatched
	/*
	,ISNULL(inv.[Invoice Count], 0) AS [Invoice Count]
	,ISNULL(inv.[Invoice Amount], 0) AS [Invoice Amount]
	,ISNULL(inv.[Invoice Amount MST], 0) AS [Invoice Amount MST]
	,ISNULL(inv.[Tax Amount], 0) AS [Invoice Tax]
	,ISNULL(inv.[Sales Balance], 0) AS [Invoice Sales Balance]
	*/
	,CASE WHEN pl.LINENUMBER=1 THEN ISNULL(T1.[Invoice Count], 0) ELSE 0 END AS [Invoice Count]
	,CASE WHEN pl.LINENUMBER=1 THEN ISNULL(T1.INVOICEAMOUNT, 0)  ELSE 0 END AS [Invoice Amount]
	,CASE WHEN pl.LINENUMBER=1 THEN ISNULL(T1.INVOICEAMOUNTMST, 0)  ELSE 0 END AS [Invoice Amount MST]
	,CASE WHEN pl.LINENUMBER=1 THEN ISNULL(T1.SUMTAX, 0)  ELSE 0 END AS [Invoice Tax]
	,CASE WHEN pl.LINENUMBER=1 THEN ISNULL(T1.SALESBALANCE, 0)  ELSE 0 END AS [Invoice Sales Balance]
FROM [synapse_fo].[PURCHTABLE] pt
	LEFT JOIN [synapse_fo].[vwPURCHLINE] pl
		ON pt.[PURCHID] = pl.[PURCHID]
		AND pt.[DATAAREAID] = pl.[DATAAREAID]
		AND pt.[PARTITION] = pl.[PARTITION]
	LEFT JOIN [FO].[vwExchangeRates] exr
		ON pl.[CURRENCYCODE] = exr.[ToCurrency]
		AND 'GBP' = exr.[FromCurrency]
		AND pl.[DATAAREAID] = exr.[DataareaId]
		AND exr.[RateTypeName] = 'Default'
		AND pt.ACCOUNTINGDATE BETWEEN exr.[FromDate] AND exr.[ToDate]
		--AND exr.[ToDate] = '2154-12-31 00:00:00.000'
	LEFT JOIN [synapse_fo].[ECORESCATEGORY] rescat
		ON pl.[PROCUREMENTCATEGORY] = rescat.[RECID]
		AND pl.[PARTITION] = rescat.[PARTITION]
	LEFT JOIN [synapse_fo].[vwINVENTPROCUREMENTLEDGERPOSTINGDEFINITION] lpd
		ON pl.[DATAAREAID] = lpd.[DATAAREAID]
		AND rescat.[NAME] = lpd.[PRODUCTCATEGORYNAME]
		AND lpd.[INVENTORYACCOUNTTYPE] = 54

	LEFT JOIN cte1 T1
		ON pt.PURCHID = T1.PURCHID

	LEFT JOIN cte2 T2
		ON pt.PURCHID = T2.PURCHID
		AND pl.INVENTTRANSID = T2.INVENTTRANSID
WHERE pl.ISDELETED <> 1
/*
	LEFT JOIN cteinvoices inv
		ON ISNULL(pl.[PURCHID], '') = ISNULL(inv.[PURCHID], '')
		--AND pl.[INVENTTRANSID] = inv.[INVENTTRANSID]
*/

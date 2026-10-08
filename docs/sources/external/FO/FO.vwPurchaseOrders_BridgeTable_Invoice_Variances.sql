CREATE     VIEW [FO].[vwPurchaseOrders_BridgeTable_Invoice_Variances]
AS

	WITH ctePostedPurchaseOrdes as
	(
		SELECT --vij.PURCHID, vit.PURCHID, vit.ORIGPURCHID, pl.PURCHID, vit.INVOICEID, vit.LINEAMOUNT, pl.LINEAMOUNT
	
			--vit.[ORIGPURCHID] AS [Purchase Order No]
			vij.[INVOICEID]
			,SUM(vit.[LINEAMOUNT]) AS [Invoice Amount]
			,SUM(vit.[LINEAMOUNTMST]) AS [Invoice Amount MST]
			,SUM(vit.[TAXAMOUNT]) AS [Invoice Line Tax]
			,MAX(vij.[SUMTAX]) AS [Invoice Tax]
			,SUM(vit.[LINEAMOUNT]) AS [Invoice Gross]
			--,SUM(vit.[LINEAMOUNT] - vit.[TAXAMOUNT]) AS [Invoice Gross]
			,SUM(pl.LINEAMOUNT) AS LineAmt
	
		FROM synapse_fo.VENDINVOICEJOUR vij
			INNER JOIN [synapse_fo].[VENDINVOICETRANS] vit
				ON vij.[PURCHID] = vit.[PURCHID]
				AND vij.[INVOICEID] = vit.[INVOICEID]
				--AND vij.[NUMBERSEQUENCEGROUP] = vit.[NUMBERSEQUENCEGROUP]
				AND vij.[INTERNALINVOICEID] = vit.[INTERNALINVOICEID]
				AND vij.[INVOICEDATE] = vit.[INVOICEDATE]
			INNER JOIN synapse_fo.PURCHLINE pl
				ON vit.ORIGPURCHID = pl.PURCHID
				AND vit.INVENTTRANSID = pl.INVENTTRANSID

		WHERE vij.[PURCHID] IS NOT NULL
	--		AND vit.[INVOICEID] IN ('000000', '000000', '004', '0000000', '0000000', '0000000', '0000000', '0000000') 
			AND vij.[PURCHID] NOT IN ('RCS-000000', 'RCS-000000', 'RCS-000000')
			--AND vij.[INVOICEID] = '00000'
		GROUP BY 		
			--vit.[ORIGPURCHID]
			vij.[INVOICEID]
	)

	SELECT 
		po.[INVOICEID] AS [INVOICEID]

		--po.[Purchase Order No]
		,po.[Invoice Amount] AS [Invoice Amount]
		,po.[Invoice Amount MST] AS [Invoice Amount MST]
		--,po.[Total Lines] AS [Total Purchase Order Lines]
		,po.[Invoice Tax] AS [Invoice Tax]
		,po.[Invoice Gross] + po.[Invoice Tax] AS [Invoice Gross]
		--,po.[Invoice Gross] AS [Invoice Gross]
		,po.[LineAmt] AS [Purchase Order Amount]
		--,postedpo.[Total Invoices] AS [Total Invoice Lines]
		,po.[Invoice Gross] - po.[LineAmt] AS [Invoice Variance]
		--,pl.[Total Invoices]
		,po.[Invoice Line Tax]
		,IIF(po.[Invoice Gross] - po.[LineAmt] <> 0, 'Y', 'N') AS [Has Variance]
		,IIF(po.[Invoice Gross] - po.[LineAmt] > 0, 'Positive Variance', 'Negative Variance') AS [Variance Type]
		,((po.[Invoice Gross] - po.[LineAmt])/(po.[Invoice Gross]*1.0)) AS [Percent Variance]
	FROM ctePostedPurchaseOrdes po
	--WHERE postedpo.[INVOICEID] = '000000'
	--GROUP BY 
	--	po.[INVOICEID]

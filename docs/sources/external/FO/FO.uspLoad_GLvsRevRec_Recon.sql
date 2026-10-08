CREATE    PROCEDURE [FO].[uspLoad_GLvsRevRec_Recon]
AS
BEGIN
	-- Get SubsDeferralSchedule
	DROP TABLE IF EXISTS #ActiveDeferralBilling

	SELECT *
	INTO #ActiveDeferralBilling
	FROM FO.tblSubsBillingScheduleReport --FO.vwSubsBillingDeferralSchedule 
	WHERE [schedule status] NOT IN ('Completed', 'Cancelled')
		AND [Deferral End Date] >= GETDATE()
		AND [invoice date] < DATETIME2FROMPARTS(YEAR(getdate()), month(getdate()),1,0,0,0,0,0)
		AND productgroup IN ('S1', 'S2', 'S4')

	--Get SalesOrder# by Invoice#
	DROP TABLE IF EXISTS #InvoiceOrderNos

	SELECT INVOICE, MCRPAYMORDERID
	INTO #InvoiceOrderNos
	FROM synapse_fo.CUSTTRANS
	WHERE 
		(INVOICE like 'INV-%' OR INVOICE like 'CRE-%')
		AND MCRPAYMORDERID IS NOT NULL
	GROUP BY INVOICE, MCRPAYMORDERID


	--Get GLTransactions with SalesOrder#
	DROP TABLE IF EXISTS #GLTrans

	SELECT 
		lt.[Journal No.]
		,lt.[Voucher]
		,lt.[Accounting Date]
		,lt.[DDD]
		,lt.[Main Account Code]
		,ma.[Main Account Name] AS [Account Name]
		,lt.[Description]
		,lt.[Currency]
		,lt.[Trans. Amount]
		,lt.[Acc. Amount]
		,lt.[Rep. Amount]
		--,lt.[Posting Type]
		,pt.[Description] AS [Posting Type]
		,NULL AS PostingLayer
		,lt.[Account No.]
		,lt.[Document No.]
		,lt.[Created By]
		,lt.[Created Datetime]
		,lt.[Product Code]
		,lt.[Product Group]
		,lt.[Project Code]
		,lt.[Cost Center Code]
		,lt.[Country Code]

		,CASE
			WHEN lt.Voucher LIKE '%-RR%' AND CHARINDEX('INV-', lt.[Description]) > 0 THEN SUBSTRING(lt.[description], CHARINDEX('INV-', lt.[Description]), 12)
			WHEN lt.Voucher NOT LIKE '%-RR%'  AND lt.[Document No.] LIKE 'INV-%' THEN lt.[Document No.]
		END AS Invoice
		,CASE
			WHEN lt.Voucher LIKE '%-RR%' AND CHARINDEX('INV-', lt.[Description]) > 0 THEN CHARINDEX('INV-', lt.[Description])
		END AS Invoice_Pos

		,CASE
			WHEN lt.Voucher LIKE '%-RR%' AND CHARINDEX('CRE-', lt.[Description]) > 0 THEN SUBSTRING(lt.[Description], CHARINDEX('CRE-', lt.[Description]), 12)
			WHEN lt.Voucher NOT LIKE '%-RR%' AND lt.[Document No.] LIKE 'CRE-%' THEN lt.[Document No.]
		END  AS CreditNote
		,CASE
			WHEN lt.Voucher LIKE '%-RR%' AND CHARINDEX('CRE-', lt.[Description]) > 0 THEN CHARINDEX('CRE-', lt.[Description])
		END  AS CreditNote_Pos
		,CAST(NULL AS NVARCHAR(25)) AS [Sales Order]
		
	INTO #GLTrans
	FROM FO.vwLedgerTrans_Aliased lt
		INNER JOIN [FO].[vwMainAccount] ma
			ON lt.[Main Account Code] = ma.[Main Account]
		INNER JOIN [FO].[vwLedgerPostingType] pt
			ON lt.[Posting Type] = pt.[PostingType]
	WHERE [Main Account Code] = '000000'


	-- Update Sales Order into GLTrans
	UPDATE tgt SET tgt.[Sales Order] = inv.[MCRPAYMORDERID]
	FROM #GLTrans tgt
		INNER JOIN #InvoiceOrderNos inv
			ON ISNULL(tgt.invoice, tgt.creditnote) = inv.INVOICE


	-- Retrieve only the GL trans for the SalesOrders identified in Subs billing
	DROP TABLE IF EXISTS #FinalGLTrans

	SELECT *
	INTO #FinalGLTrans
	FROM #GLTrans lt
	WHERE EXISTS(SELECT [sales order] FROM #ActiveDeferralBilling rr WHERE lt.[Sales Order] = rr.[sales order])

	-- Get Balances from Subs billing
	DROP TABLE IF EXISTS #SubsBillingBalance

	SELECT [sales order], SUM([total recognisable amount]) TotBalance
	INTO #SubsBillingBalance
	FROM #ActiveDeferralBilling
	GROUP BY [sales order]


	-- Get balances from GL
	DROP TABLE IF EXISTS #GLBalance

	SELECT [Sales Order], SUM([Acc. Amount]) [Acc. Amount], SUM([Rep. Amount]) [Rep. Amount], SUM([Trans. Amount]) [Trans. Amount]
	INTO #GLBalance
	FROM #FinalGLTrans
	GROUP BY [Sales Order]


	--Truncate the target table before loading the new balances
	TRUNCATE TABLE [FO].[tblGLvsRevRec_Recon]

	INSERT INTO [FO].[tblGLvsRevRec_Recon]
	(
		[SalesOrder]
		,[GLBalance]
		,[SubsBillingBalance]
	)
	SELECT lt.[Sales Order], lt.[Rep. Amount] AS GLBalance, sb.TotBalance AS SubsBillingBalance
	FROM #GLBalance lt
		LEFT JOIN #SubsBillingBalance sb
			ON lt.[Sales Order] = sb.[sales order]
	WHERE lt.[Rep. Amount] + sb.TotBalance <> 0


	--Truncate the Target GL table before the load
	TRUNCATE TABLE [FO].[tblLedgerTrans_RevRec_Recon]

	INSERT INTO [FO].[tblLedgerTrans_RevRec_Recon]
	(
		[Journal No.],
		[Voucher],
		[Accounting Date],
		[DDD],
		[Main Account],
		[Account Name],
		[Description],
		[Currency],
		[Trans. Amount],
		[Acc. Amount],
		[Rep. Amount],
		[Posting Type],
		[PostingLayer],
		[Account No.],
		[Document No.],
		[Created By],
		[Created Datetime],
		[Product Code],
		[Product Group],
		[Project Code],
		[Cost Center Code],
		[Country Code],
		[Invoice],
		[Invoice_Pos],
		[CreditNote],
		[CreditNote_Pos],
		[Sales Order]
	)
	SELECT
		lt.[Journal No.],
		lt.[Voucher],
		lt.[Accounting Date],
		lt.[DDD],
		lt.[Main Account Code],
		lt.[Account Name],
		lt.[Description],
		lt.[Currency],
		lt.[Trans. Amount],
		lt.[Acc. Amount],
		lt.[Rep. Amount],
		lt.[Posting Type],
		lt.[PostingLayer],
		lt.[Account No.],
		lt.[Document No.],
		lt.[Created By],
		lt.[Created Datetime],
		lt.[Product Code],
		lt.[Product Group],
		lt.[Project Code],
		lt.[Cost Center Code],
		lt.[Country Code],
		lt.[Invoice],
		lt.[Invoice_Pos],
		lt.[CreditNote],
		lt.[CreditNote_Pos],
		lt.[Sales Order]
	FROM #FinalGLTrans lt
	WHERE EXISTS(SELECT SalesOrder FROM FO.tblGLvsRevRec_Recon rec WHERE lt.[Sales Order] = rec.[SalesOrder])
	--WHERE [Sales Order] = 'ORD-0000000-Q9L3Q9'

END

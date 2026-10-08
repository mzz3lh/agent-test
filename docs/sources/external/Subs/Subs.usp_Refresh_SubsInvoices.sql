CREATE    PROCEDURE [Subs].[usp_Refresh_SubsInvoices]
AS 
BEGIN

	DROP TABLE IF EXISTS #SalesQuotes 
		SELECT 
		 SUBSTRING(SO.ordernumber,4,200) AS OrderNumber
		,COALESCE(q.[apuk_campaignyear], IIF(MONTH(q.[createdon]) >= 10, YEAR(q.[createdon]) + 1, YEAR(q.[createdon]))) AS 'apuk_campaignyear'
		INTO #SalesQuotes
		FROM [synapse_ce].[SalesOrder] so
		INNER JOIN [synapse_ce].[Quote] q
			ON so.[quoteid] = q.[quoteid]

	DROP TABLE IF EXISTS #CONC
		SELECT 
		SUBSTRING(Product_Number,4,50) AS Product_Number
		,apuk_discount
		,MAX(apuk_concessiontypeid_Name) AS apuk_concessiontypeid_Name
		INTO #CONC
		FROM CE.vwConcession
		GROUP BY Product_Number, apuk_discount

	DROP TABLE IF EXISTS #CONCGRP
		SELECT
		 ACCOUNTNUM
		,INVOICE
		,apuk_discount
		,apuk_concessiontypeid_Name
		,ROW_NUMBER() OVER(PARTITION BY ACCOUNTNUM, INVOICE ORDER BY apuk_discount DESC) AS Discount_Rank
		INTO #CONCGRP
		FROM [synapse_fo].[CUSTTRANS_RICS]
		LEFT JOIN #CONC CONC
			ON CONC.Product_Number = productcode
		WHERE 
			RICINVOICETYPE = 'SUB'
			AND TRANSTYPE <> 24
			AND (INVOICE NOT LIKE '%CRE%' OR (INVOICE LIKE '%CRE%' AND CustTrans_AmountCur = 0 AND TRANSTYPE = 2)) --No CNs --Some SO Invoices with a 0 Value have CRE Prefix instead of INV due to a bug
			AND INVOICE NOT LIKE '%FTCN%' --No FTCNs
			AND productcode LIKE 'CON%' --No Concessions
		GROUP BY ACCOUNTNUM, INVOICE, apuk_discount, apuk_concessiontypeid_Name

	DROP TABLE IF EXISTS #CONCMAX
		SELECT *
		INTO #CONCMAX
		FROM #CONCGRP
		WHERE Discount_Rank = 1

	DROP TABLE IF EXISTS #NONSUBINV
		SELECT
		 [ACCOUNTNUM]
		,SUM(CASE WHEN RICINVOICETYPE <> 'SUB' THEN AmountCur ELSE 0 END) AS NonSubs_AmountCur
		,CASE
			WHEN SUM(CASE WHEN RICINVOICETYPE <> 'SUB' THEN AmountCur ELSE 0 END) < 0 THEN 0 
			ELSE SUM(CASE WHEN RICINVOICETYPE <> 'SUB' THEN AmountCur ELSE 0 END) 
			END AS NonSubs_AmountCurFlat
		,SUM(CASE WHEN RICINVOICETYPE <> 'SUB' THEN AMOUNTMST ELSE 0 END) AS NonSubs_AmountMst
		,CASE
			WHEN SUM(CASE WHEN RICINVOICETYPE <> 'SUB' THEN AMOUNTMST ELSE 0 END) < 0 THEN 0
			ELSE SUM(CASE WHEN RICINVOICETYPE <> 'SUB' THEN AMOUNTMST ELSE 0 END)
			END AS NonSubs_AmountMstFlat
		,SUM(CASE WHEN RICINVOICETYPE = 'APP' THEN AmountCur ELSE 0 END) AS NonSubs_APP_AmountCur
		,[INVOICE]
		,[VOUCHER]
		INTO #NONSUBINV
		FROM [synapse_fo].[CUSTTRANS_RICS] CT
		WHERE TRANSTYPE IN (2, 36)
		AND (INVOICE NOT LIKE '%CRE%' OR (INVOICE LIKE '%CRE%' AND CustTrans_AmountCur = 0 AND TRANSTYPE = 2))
		AND INVOICE NOT LIKE '%FTCN%'
		GROUP BY [ACCOUNTNUM], [INVOICE], [VOUCHER]

	DROP TABLE IF EXISTS #Inv_Subs_Credit
		SELECT
		 ACCOUNTNUM
		,LASTSETTLEVOUCHER
		,SUM(AMOUNTCUR) AS AMOUNTCUR
		,SUM(AMOUNTMST) AS AMOUNTMST
		INTO #Inv_Subs_Credit
		FROM [synapse_fo].[CUSTTRANS_RICS]
		WHERE TRANSTYPE = 2
		AND INVOICE LIKE '%CRE%' 
		AND CustTrans_AmountCur <> 0
		AND RICINVOICETYPE = 'SUB'
		GROUP BY ACCOUNTNUM, LASTSETTLEVOUCHER, RICINVOICETYPE

	DROP TABLE IF EXISTS #FTCN_Subs_Credit
		SELECT
		 ACCOUNTNUM
		,LASTSETTLEVOUCHER
		,SUM(AMOUNTCUR) AS AMOUNTCUR
		,SUM(AMOUNTMST) AS AMOUNTMST
		INTO #FTCN_Subs_Credit
		FROM [synapse_fo].[CUSTTRANS_RICS]
		WHERE TRANSTYPE = 8
		AND INVOICE LIKE '%FTCN%'
		AND RICINVOICETYPE = 'SUB'
		GROUP BY ACCOUNTNUM, LASTSETTLEVOUCHER, RICINVOICETYPE

	DROP TABLE IF EXISTS #CORE
		SELECT
		 CT.[ACCOUNTNUM] AS 'Account_Num'
		,CASE
			WHEN CT.ORDERNUM = 'Subs0000' THEN 'Subs0000' 
			ELSE ISNULL('Subs' + CAST(sq.[apuk_campaignyear] AS nvarchar(4)), sc.[SubsCampaign]) END AS [SubsCampaign]
		,CASE
			WHEN CT.ORDERNUM = 'Subs0000' THEN '2021' 
			ELSE [apuk_campaignyear] END AS 'Campaign_Year'
		,CT.[CustTrans_AmountCur] AS 'Full_Invoice_Amount_CUR'
		,CT.[CustTrans_AmountMst] AS 'Full_Invoice_Amount_GBP'
		,CASE WHEN SUM(CT.[AMOUNTCUR]) < 0 THEN 0 ELSE SUM(CT.[AMOUNTCUR]) 
			+ CASE WHEN NONSUBINV.NonSubs_AmountCur < 0 THEN NONSUBINV.NonSubs_AmountCur ELSE 0 END
			END AS 'Invoice_Amount_CUR'
		,CASE WHEN SUM(CT.[AMOUNTMST]) < 0 THEN 0 ELSE SUM(CT.[AMOUNTMST]) 
			+ CASE WHEN NONSUBINV.NonSubs_AmountMst < 0 THEN NONSUBINV.NonSubs_AmountMst ELSE 0 END
			END AS 'Invoice_Amount_GBP'
		,CT.SETTLEAMOUNTCUR AS 'Settle_Amount_CUR'
		,CT.SETTLEAMOUNTMST_Adj AS 'Settle_Amount_GBP'
		,CT.[ORDERNUM] AS 'Order_Num.'
		,CT.[INVOICE] AS 'Invoice'
		,CT.[VOUCHER] AS 'Voucher'
		,CAST(CT.[TRANSDATE] AS DATE) AS 'Trans_Date'
		,CT.[CURRENCYCODE] AS 'Inv_Currency'
		,CT.[EXCHRATE] AS 'Exchange_Rate'
		,CT.[EXCHADJUSTMENT] AS 'Exchange_Adjustment'
		,CT.[PAYMMODE] AS 'Inv_Payment_Method'
		,ISNULL(CT.[LASTSETTLEVOUCHER], '') AS 'Last_Settle_Voucher'
		,CT.LASTSETTLEDATE AS 'Last_Settle_Date'
		,CT.[TRANSTYPE] AS 'Trans_Type_Code'
		,CT.[TransType_Description] AS 'Trans_Type'
		,CT.Country AS 'Country_Code'
		,CT.RECID AS 'Rec_ID'
		,CASE WHEN MAX(CONC.apuk_discount) IS NOT NULL THEN 'Y' ELSE 'N' END AS 'Has_Concession'
		,MAX(CONC.apuk_discount) AS 'Discount_(Max)'
		,CASE 
			WHEN MAX(CONC.apuk_discount) IS NULL THEN 'No Conc.'
			WHEN MAX(CASE WHEN CT.productcode IN ('CONPWRQ2','CONPWRQ3','CONRETIREDSPECIAL','CONPWRQ1','CONRETIREDFL','CONRETIRED') 
			THEN '1' ELSE '0' END) = '1' THEN 'Retired Conc.' ELSE 'Non-Retired Conc.'
			END AS 'Retired_Concession'
		INTO #CORE
		FROM [synapse_fo].[CUSTTRANS_RICS] CT
		LEFT JOIN #SalesQuotes SQ
			ON CT.[ORDERNUM] = SQ.[OrderNumber]
		LEFT JOIN #CONC CONC
			ON CT.productcode = CONC.Product_Number --------------Join is causing duplicate rows due to finding more than one name on Nonpracticsing and AIBS concessions, raised with Amanda Smith
		LEFT JOIN FO.vwSubsCampaignDates sc 
			ON CONVERT(DATE, ct.TRANSDATE) BETWEEN sc.CampaignStart AND sc.CampaignEnd
		LEFT JOIN #NONSUBINV NONSUBINV
			ON CT.ACCOUNTNUM = NONSUBINV.ACCOUNTNUM
			AND CT.Voucher = NONSUBINV.VOUCHER

		WHERE CT.RICINVOICETYPE = 'SUB'
		AND (productcode IS NULL OR productcode NOT IN ('RAFEE_ACAND', 'RAFEE_APCC', 'RAFEE_MRICS', 'RAFEE_PMU2', 'RAFEE_ASSOC', 'RAFEE_FRICS'))
		AND CT.TRANSTYPE <> 24 --Settlement
		AND CT.TRANSTYPE <> 8 --Customer
		AND (CT.INVOICE NOT LIKE '%CRE%' OR (CT.INVOICE LIKE '%CRE%' AND CustTrans_AmountCur = 0 AND TRANSTYPE = 2))
		AND CT.INVOICE NOT LIKE '%FTCN%' 

		GROUP BY
		 CT.[ACCOUNTNUM]
		,ISNULL('Subs' + CAST(sq.[apuk_campaignyear] AS nvarchar(4)), sc.[SubsCampaign])
		,[apuk_campaignyear]
		,CT.[CustTrans_AmountCur]
		,CT.[CustTrans_AmountMst]
		,CT.SETTLEAMOUNTCUR
		,CT.SETTLEAMOUNTMST_Adj
		,CT.[ORDERNUM]
		,CT.[INVOICE]
		,CT.[VOUCHER]
		,CT.[TRANSDATE]
		,CT.[CURRENCYCODE]
		,CT.[EXCHRATE]
		,CT.[EXCHADJUSTMENT]
		,CT.[PAYMMODE]
		,CT.[LASTSETTLEVOUCHER]
		,CT.LASTSETTLEDATE
		,CT.[TRANSTYPE]
		,CT.[TransType_Description]
		,CT.Country
		,CT.RECID
		,NonSubs_AmountCur
		,NonSubs_AmountMst


	-- Raj M, 2029-09-09   Retrieve invoices with Bad Debt Write off

	DROP TABLE IF EXISTS #BADDEBT

	SELECT inv.msdyn_invoicenumber AS [Invoice]
	INTO #BADDEBT
	FROM CE.vwTask T
		INNER JOIN synapse_ce.invoice inv
			ON T.regardingobjectid = inv.invoiceid
	WHERE [Subject] LIKE '%Bad Debt%Subscription%'
	GROUP BY inv.msdyn_invoicenumber



	DROP TABLE IF EXISTS #FINAL
		SELECT 
		 CORE.*
		,CASE
			WHEN CORE.Has_Concession = 'Y' AND CORE.[Discount_(Max)] = 100 THEN 'Y' 
			WHEN CORE.Has_Concession = 'Y' THEN 'N' 
			END AS '100%_Concession'
		,NonSubs_AmountCur AS 'Non_Subs_Amount_CUR'
		,NonSubs_AmountMst AS 'Non_Subs_Amount_GBP'
		,(COALESCE(INVSUBCRE.AMOUNTCUR, 0) + COALESCE(FTCNSUBCRE.AMOUNTCUR, 0)) *-1 
			+ CASE WHEN NonSubs_AmountCur < 0 THEN NonSubs_AmountCur ELSE 0 
			END AS 'Inv_Credit_Amount_CUR'
		,(COALESCE(INVSUBCRE.AMOUNTMST, 0) + COALESCE(FTCNSUBCRE.AMOUNTMST, 0)) *-1
			+ CASE WHEN NonSubs_AmountMst < 0 THEN NonSubs_AmountMst ELSE 0 END
			AS 'Inv_Credit_Amount_GBP'
		,CASE 
			WHEN (COALESCE(INVSUBCRE.AMOUNTCUR, 0) + COALESCE(FTCNSUBCRE.AMOUNTCUR, 0)) = 0 THEN 'N/A'
			WHEN (COALESCE(INVSUBCRE.AMOUNTCUR, 0) + COALESCE(FTCNSUBCRE.AMOUNTCUR, 0)) *-1 
			 + CASE WHEN NonSubs_AmountCur < 0 THEN NonSubs_AmountCur ELSE 0 END	
			= CORE.Invoice_Amount_CUR THEN 'Y'
			ELSE 'N' END AS 'Fully_Credited'
		,CASE
			WHEN (COALESCE(INVSUBCRE.AMOUNTCUR, 0) + COALESCE(FTCNSUBCRE.AMOUNTCUR, 0)) <> 0 THEN
			(COALESCE(INVSUBCRE.AMOUNTCUR, 0) + COALESCE(FTCNSUBCRE.AMOUNTCUR, 0)) *-1 
			- CORE.Invoice_Amount_CUR 
			+ CASE WHEN NonSubs_AmountCur < 0 THEN NonSubs_AmountCur ELSE 0 END	
			END AS 'Credit_Diff'
		,IIF([Settle_Amount_CUR] - NonSubs_AmountCur < 0, 0, [Settle_Amount_CUR] - NonSubs_AmountCurFlat) AS 'Paid_Amount_CUR'
		,IIF([Settle_Amount_GBP] - NonSubs_AmountMst < 0, 0, [Settle_Amount_GBP] - NonSubs_AmountMstFlat) AS 'Paid_Amount_GBP'
		,CORE.[Invoice_Amount_CUR] - IIF([Settle_Amount_CUR] - NonSubs_AmountCur < 0, 0, [Settle_Amount_CUR] - NonSubs_AmountCurFlat) AS 'Balance_CUR'
		,CORE.[Invoice_Amount_GBP] - IIF([Settle_Amount_GBP] - NonSubs_AmountMst < 0, 0, [Settle_Amount_GBP] - NonSubs_AmountMstFlat) AS 'Balance_GBP'
		,CASE WHEN NonSubs_APP_AmountCur > 0 THEN 'Y' ELSE 'N' END AS 'APP_Invoice_Flag'
		,CAST('' AS nvarchar(100)) AS 'Payment_Status'

		,CASE WHEN bdt.[Invoice] IS NOT NULL THEN 1 ELSE 0 END AS [Has_BadDebt_Writeoff]

		INTO #FINAL
		FROM #CORE CORE
		LEFT JOIN #NONSUBINV NONSUBINV
			ON CORE.[Account_Num] = NONSUBINV.ACCOUNTNUM
			AND CORE.Voucher = NONSUBINV.VOUCHER
		LEFT JOIN #Inv_Subs_Credit INVSUBCRE
			ON CORE.VOUCHER = INVSUBCRE.LASTSETTLEVOUCHER
		LEFT JOIN #FTCN_Subs_Credit FTCNSUBCRE
			ON CORE.VOUCHER = FTCNSUBCRE.LASTSETTLEVOUCHER
		LEFT JOIN #CONCMAX CONCMAX
			ON CORE.Account_Num = CONCMAX.ACCOUNTNUM
			AND CORE.Invoice = CONCMAX.INVOICE
		LEFT JOIN #BADDEBT bdt
			ON CORE.[Invoice] = bdt.[Invoice]
		WHERE Campaign_Year >= 2022



	--DROP TABLE Subs.tblSubsInvoices SELECT * INTO Subs.tblSubsInvoices FROM #FINAL
	TRUNCATE TABLE Subs.tblSubsInvoices

	INSERT INTO Subs.tblSubsInvoices (
		 [Account_Num]
		,[SubsCampaign]
		,[Campaign_Year]
		,[Full_Invoice_Amount_CUR]
		,[Full_Invoice_Amount_GBP]
		,[Invoice_Amount_CUR]
		,[Invoice_Amount_GBP]
		,[Settle_Amount_CUR]
		,[Settle_Amount_GBP]
		,[Order_Num.]
		,[Invoice]
		,[Voucher]
		,[Trans_Date]
		,[Inv_Currency]
		,[Exchange_Rate]
		,[Exchange_Adjustment]
		,[Inv_Payment_Method]
		,[Last_Settle_Voucher]
		,[Last_Settle_Date]
		,[Trans_Type_Code]
		,[Trans_Type]
		,[Country_Code]
		,[Rec_ID]
		,[Discount_(Max)]
		,[Has_Concession]
		,[100%_Concession]
		,[Retired_Concession]
		,[Non_Subs_Amount_CUR]
		,[Non_Subs_Amount_GBP]
		,[Inv_Credit_Amount_CUR]
		,[Inv_Credit_Amount_GBP]
		,[Fully_Credited]
		,[Credit_Diff]
		,[Paid_Amount_CUR]
		,[Paid_Amount_GBP]
		,[Balance_CUR]
		,[Balance_GBP]
		,[APP_Invoice_Flag]
		,[Payment_Status]
		)

	SELECT
		 [Account_Num]
		,[SubsCampaign]
		,[Campaign_Year]
		,[Full_Invoice_Amount_CUR]
		,[Full_Invoice_Amount_GBP]
		,[Invoice_Amount_CUR]
		,[Invoice_Amount_GBP]
		,[Settle_Amount_CUR]
		,[Settle_Amount_GBP]
		,[Order_Num.]
		,[Invoice]
		,[Voucher]
		,[Trans_Date]
		,[Inv_Currency]
		,[Exchange_Rate]
		,[Exchange_Adjustment]
		,[Inv_Payment_Method]
		,[Last_Settle_Voucher]
		,[Last_Settle_Date]
		,[Trans_Type_Code]
		,[Trans_Type]
		,[Country_Code]
		,[Rec_ID]
		,[Discount_(Max)]
		,[Has_Concession]
		,[100%_Concession]
		,[Retired_Concession]
		,[Non_Subs_Amount_CUR]
		,[Non_Subs_Amount_GBP]
		,[Inv_Credit_Amount_CUR]
		,[Inv_Credit_Amount_GBP]
		,[Fully_Credited]
		,[Credit_Diff]
		,[Paid_Amount_CUR]
		,[Paid_Amount_GBP]
		,[Balance_CUR]
		,[Balance_GBP]
		,[APP_Invoice_Flag]
		,CASE 
			WHEN [Has_BadDebt_Writeoff] =1 THEN 'Bad Debt Write Off'
			WHEN [100%_Concession] = 'Y' THEN 'Full Concession'
			WHEN [100%_Concession] = 'N' AND [Has_Concession] = 'Y' AND [Invoice_Amount_CUR] = 0 THEN 'Full Concession'
			WHEN [Invoice_Amount_CUR] = 0 THEN 'Zero Value Invoice'
			WHEN [Fully_Credited] = 'Y' THEN 'Fully Credited'
			WHEN [Balance_CUR] = 0 THEN 'Fully Paid'
			WHEN [Paid_Amount_CUR] = 0 AND Settle_Amount_CUR > 0 THEN 'Pre-Subs Payment'
			WHEN [Paid_Amount_CUR] = 0 THEN 'No Payment'
			WHEN [Balance_CUR] > 0 THEN 'Partially Paid'
			WHEN [Full_Invoice_Amount_CUR] - [Settle_Amount_Cur] = 0 THEN 'Fully Paid' -- RM 2026-08-25, Payment Status deriving as Unknown even though fully paid. This is due to duplicate concession rows causing the invoice amount wrong.
			WHEN [Full_Invoice_Amount_CUR] - [Settle_Amount_Cur] <> 0 THEN 'Partially Paid' -- RM 2026-08-25, Payment Status deriving as Unknown even though fully paid. This is due to duplicate concession rows causing the invoice amount wrong.			
			ELSE 'Unknown'
			END AS 'Payment_Status'
		FROM #FINAL

END

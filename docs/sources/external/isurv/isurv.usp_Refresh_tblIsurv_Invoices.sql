CREATE PROCEDURE [isurv].[usp_Refresh_tblIsurv_Invoices]
AS 
BEGIN

	DROP TABLE IF EXISTS #Inv_Subs_Credit
	SELECT
	ACCOUNTNUM
	,LASTSETTLEVOUCHER
	,SUM(AMOUNTCUR) AS AMOUNTCUR
	,SUM(AMOUNTMST) AS AMOUNTMST
	,RICINVOICETYPE
	,productcode
	INTO #Inv_Subs_Credit
	FROM [synapse_fo].[CUSTTRANS_RICS]
	WHERE TRANSTYPE = 2
	AND INVOICE LIKE '%CRE%'
	GROUP BY ACCOUNTNUM, LASTSETTLEVOUCHER, RICINVOICETYPE, productcode

	DROP TABLE IF EXISTS #FTCN_Subs_Credit
	SELECT
	ACCOUNTNUM
	,LASTSETTLEVOUCHER
	,SUM(AMOUNTCUR) AS AMOUNTCUR
	,SUM(AMOUNTMST) AS AMOUNTMST
	,RICINVOICETYPE
	,productcode
	INTO #FTCN_Subs_Credit
	FROM [synapse_fo].[CUSTTRANS_RICS]
	WHERE TRANSTYPE = 8
	AND INVOICE LIKE '%FTCN%'
	GROUP BY ACCOUNTNUM, LASTSETTLEVOUCHER, RICINVOICETYPE, productcode
	
	DROP TABLE IF EXISTS #NONSUBINV
	SELECT
	[ACCOUNTNUM]
	,SUM(CASE WHEN ProductGroup <> 'I1' THEN AmountCur ELSE 0 END) AS NonSubs_AmountCur
	,CASE
		WHEN SUM(CASE WHEN ProductGroup <> 'I1' THEN AmountCur ELSE 0 END) < 0 THEN 0 
		ELSE SUM(CASE WHEN ProductGroup <> 'I1' THEN AmountCur ELSE 0 END) 
		END AS NonSubs_AmountCurFlat
	,SUM(CASE WHEN ProductGroup <> 'I1' THEN AMOUNTMST ELSE 0 END) AS NonSubs_AmountMst
	,CASE
		WHEN SUM(CASE WHEN ProductGroup <> 'I1' THEN AMOUNTMST ELSE 0 END) < 0 THEN 0
		ELSE SUM(CASE WHEN ProductGroup <> 'I1' THEN AMOUNTMST ELSE 0 END)
		END AS NonSubs_AmountMstFlat
	,[INVOICE]
	,[VOUCHER]
	INTO #NONSUBINV
	FROM [synapse_fo].[CUSTTRANS_RICS] CT
	INNER JOIN isurv.vwIsurv_Sales_Order SO
		ON SO.[Order Number] = CT.ORDERNUM
	WHERE TRANSTYPE IN (2, 36)
	AND INVOICE NOT LIKE '%CRE%'
	AND INVOICE NOT LIKE '%FTCN%'
	GROUP BY [ACCOUNTNUM], [INVOICE], [VOUCHER]
		
	DROP TABLE IF EXISTS #CORE
	SELECT
	CT.[ACCOUNTNUM] AS 'Account_Num'
	,CT.[CustTrans_AmountCur] AS 'Full_Invoice_Amount_CUR'
	,CT.[CustTrans_AmountMst] AS 'Full_Invoice_Amount_GBP'
	,SUM(CASE WHEN CT.productgroup = 'I1' THEN CT.[AMOUNTCUR] END) AS 'Invoice_Amount_CUR'
	,SUM(CASE WHEN CT.productgroup = 'I1' THEN CT.[AMOUNTMST] END) AS 'Invoice_Amount_GBP'
	,CT.SETTLEAMOUNTCUR AS 'Settle_Amount_CUR'
	,CT.SETTLEAMOUNTMST_Adj AS 'Settle_Amount_GBP'
	,SUM((COALESCE(INVSUBCRE.AMOUNTCUR, 0) + COALESCE(FTCNSUBCRE.AMOUNTCUR, 0))) *-1 AS 'Inv_Full_Credit_Amount_CUR'
	,SUM((COALESCE(INVSUBCRE.AMOUNTMST, 0) + COALESCE(FTCNSUBCRE.AMOUNTMST, 0))) *-1 AS 'Inv_Full_Credit_Amount_GBP'
	,SUM(CASE WHEN CT.productgroup = 'I1' THEN (COALESCE(INVSUBCRE.AMOUNTCUR, 0) + COALESCE(FTCNSUBCRE.AMOUNTCUR, 0)) *-1 END) AS 'Inv_Credit_Amount_CUR'
	,SUM(CASE WHEN CT.productgroup = 'I1' THEN (COALESCE(INVSUBCRE.AMOUNTMST, 0) + COALESCE(FTCNSUBCRE.AMOUNTMST, 0)) *-1 END) AS 'Inv_Credit_Amount_GBP'
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
	INTO #CORE
	FROM [synapse_fo].[CUSTTRANS_RICS] CT
	INNER JOIN isurv.vwIsurv_Sales_Order SO --Relevant Invoices only
		ON SO.[Order Number] = CT.ORDERNUM
	LEFT JOIN #Inv_Subs_Credit INVSUBCRE
		ON CT.ACCOUNTNUM = INVSUBCRE.ACCOUNTNUM
		AND CT.VOUCHER = INVSUBCRE.LASTSETTLEVOUCHER
		AND CT.RICINVOICETYPE = INVSUBCRE.RICINVOICETYPE
		AND COALESCE(CT.productcode,'NULL') = COALESCE(INVSUBCRE.productcode, 'NULL')
	LEFT JOIN #FTCN_Subs_Credit FTCNSUBCRE
		ON CT.ACCOUNTNUM = FTCNSUBCRE.ACCOUNTNUM
		AND CT.VOUCHER = FTCNSUBCRE.LASTSETTLEVOUCHER
		AND CT.RICINVOICETYPE = FTCNSUBCRE.RICINVOICETYPE
		AND COALESCE(CT.productcode,'NULL') = COALESCE(FTCNSUBCRE.productcode, 'NULL')
	WHERE CT.TRANSTYPE <> 24 --Settlement
	AND CT.TRANSTYPE <> 8 --Customer
	AND CT.INVOICE NOT LIKE '%CRE%'
	AND CT.INVOICE NOT LIKE '%FTCN%' 
	GROUP BY
	 CT.[ACCOUNTNUM]
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
		
	DROP TABLE IF EXISTS #FINAL
	SELECT 
	CORE.*
	,NonSubs_AmountCur AS 'Non_Subs_Amount_CUR'
	,NonSubs_AmountMst AS 'Non_Subs_Amount_GBP'
	,CASE 
		WHEN Inv_Credit_Amount_CUR = 0 THEN 'N/A'
		WHEN Inv_Credit_Amount_CUR = CORE.Invoice_Amount_CUR THEN 'Y'
		ELSE 'N' END AS 'Fully_Credited'
	,IIF([Settle_Amount_CUR] - NonSubs_AmountCur - Inv_Credit_Amount_CUR < 0, 0, [Settle_Amount_CUR] - NonSubs_AmountCurFlat - Inv_Credit_Amount_CUR) AS 'Paid_Amount_CUR'
	,IIF([Settle_Amount_GBP] - NonSubs_AmountMst - Inv_Credit_Amount_GBP < 0, 0, [Settle_Amount_GBP] - NonSubs_AmountMstFlat - Inv_Credit_Amount_GBP) AS 'Paid_Amount_GBP'
	,CORE.[Invoice_Amount_CUR] - Inv_Credit_Amount_CUR - IIF([Settle_Amount_CUR] - NonSubs_AmountCur - Inv_Credit_Amount_CUR < 0, 0, [Settle_Amount_CUR] - NonSubs_AmountCurFlat - Inv_Credit_Amount_CUR) AS 'Balance_CUR'
	,CORE.[Invoice_Amount_GBP] - Inv_Credit_Amount_GBP - IIF([Settle_Amount_GBP] - NonSubs_AmountMst - Inv_Credit_Amount_GBP < 0, 0, [Settle_Amount_GBP] - NonSubs_AmountMstFlat - Inv_Credit_Amount_GBP) AS 'Balance_GBP'
	--,CAST('' AS nvarchar(100)) AS 'Payment_Status'
	INTO #FINAL
	FROM #CORE CORE
	LEFT JOIN #NONSUBINV NONSUBINV
		ON CORE.[Account_Num] = NONSUBINV.ACCOUNTNUM
		AND CORE.Voucher = NONSUBINV.VOUCHER

	--DROP TABLE isurv.tblIsurv_Invoices SELECT * INTO isurv.tblIsurv_Invoices FROM #FINAL
	TRUNCATE TABLE isurv.tblIsurv_Invoices

	INSERT INTO isurv.tblIsurv_Invoices (
	 [Account_Num]
    ,[Full_Invoice_Amount_CUR]
    ,[Full_Invoice_Amount_GBP]
    ,[Invoice_Amount_CUR]
    ,[Invoice_Amount_GBP]
    ,[Settle_Amount_CUR]
    ,[Settle_Amount_GBP]
    ,[Inv_Full_Credit_Amount_CUR]
    ,[Inv_Full_Credit_Amount_GBP]
    ,[Inv_Credit_Amount_CUR]
    ,[Inv_Credit_Amount_GBP]
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
    ,[Non_Subs_Amount_CUR]
    ,[Non_Subs_Amount_GBP]
    ,[Fully_Credited]
    ,[Paid_Amount_CUR]
    ,[Paid_Amount_GBP]
    ,[Balance_CUR]
    ,[Balance_GBP]
    ,[Payment_Status]
    ,[Payment_Status_Rank]
	)
	SELECT
	 [Account_Num]
    ,[Full_Invoice_Amount_CUR]
    ,[Full_Invoice_Amount_GBP]
    ,[Invoice_Amount_CUR]
    ,[Invoice_Amount_GBP]
    ,[Settle_Amount_CUR]
    ,[Settle_Amount_GBP]
    ,[Inv_Full_Credit_Amount_CUR]
    ,[Inv_Full_Credit_Amount_GBP]
    ,[Inv_Credit_Amount_CUR]
    ,[Inv_Credit_Amount_GBP]
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
    ,[Non_Subs_Amount_CUR]
    ,[Non_Subs_Amount_GBP]
    ,[Fully_Credited]
    ,[Paid_Amount_CUR]
    ,[Paid_Amount_GBP]
    ,[Balance_CUR]
    ,[Balance_GBP]
	,CASE 
		--WHEN [100%_Concession] = 'Y' THEN 'Full Concession'
		WHEN [Invoice_Amount_CUR] = 0 THEN 'Zero Value Invoice'
		WHEN [Fully_Credited] = 'Y' THEN 'Fully Credited'
		WHEN [Balance_CUR] = 0 THEN 'Fully Paid'
		WHEN [Paid_Amount_CUR] = 0 THEN 'No Payment'
		WHEN [Balance_CUR] > 0 THEN 'Partially Paid'
		ELSE 'Unknown'
		END AS 'Payment_Status'
	,CASE 
		--WHEN [100%_Concession] = 'Y' THEN 'Full Concession'
		WHEN [Invoice_Amount_CUR] = 0 THEN 1
		WHEN [Fully_Credited] = 'Y' THEN 5
		WHEN [Balance_CUR] = 0 THEN 2
		WHEN [Paid_Amount_CUR] = 0 THEN 4
		WHEN [Balance_CUR] > 0 THEN 3
		ELSE 6
		END AS 'Payment_Status_Rank'
	FROM #FINAL

	END

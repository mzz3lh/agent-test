CREATE    VIEW [Subs].[vwCorpInvoices] AS	

WITH CorpQuote AS (
	SELECT
		 [Quote ID]
		,[Quote Campaign Year]
	FROM Subs.vwCorpQuotes
	GROUP BY 
		[Quote ID], 
		[Quote Campaign Year]
),
SO_Credit AS (
	SELECT
		 ACCOUNTNUM
		,LASTSETTLEVOUCHER
		,CustTrans_AmountCur
		,CustTrans_AmountMst
	FROM [synapse_fo].[CUSTTRANS_RICS]
	WHERE TRANSTYPE = 2
		AND INVOICE LIKE '%CRE%'
	GROUP BY 
		ACCOUNTNUM, 
		LASTSETTLEVOUCHER, 
		CustTrans_AmountCur, 
		CustTrans_AmountMst
),
FTCN_Credit AS (
	SELECT
		 ACCOUNTNUM
		,LASTSETTLEVOUCHER
		,CustTrans_AmountCur
		,CustTrans_AmountMst
	FROM [synapse_fo].[CUSTTRANS_RICS]
	WHERE TRANSTYPE = 8
		AND INVOICE LIKE '%FTCN%'
	GROUP BY 
		ACCOUNTNUM, 
		LASTSETTLEVOUCHER, 
		CustTrans_AmountCur, 
		CustTrans_AmountMst
)
,CONC AS (
		SELECT 
		SUBSTRING(Product_Number,4,50) AS Product_Number
		,apuk_discount
		,MAX(apuk_concessiontypeid_Name) AS apuk_concessiontypeid_Name
		FROM CE.vwConcession
		GROUP BY Product_Number, apuk_discount
)
,CONCGRP AS (
		SELECT
		 ACCOUNTNUM
		,INVOICE
		,apuk_discount
		,apuk_concessiontypeid_Name
		,ROW_NUMBER() OVER(PARTITION BY ACCOUNTNUM, INVOICE ORDER BY apuk_discount DESC) AS Discount_Rank
		FROM [synapse_fo].[CUSTTRANS_RICS]
		LEFT JOIN CONC CONC
			ON CONC.Product_Number = productcode
		WHERE 
			RICINVOICETYPE = 'SUB'
			AND TRANSTYPE <> 24
			AND INVOICE NOT LIKE '%CRE%' --No CNs
			AND INVOICE NOT LIKE '%FTCN%' --No FTCNs
			AND productcode LIKE 'CON%' --No Concessions
		GROUP BY ACCOUNTNUM, INVOICE, apuk_discount, apuk_concessiontypeid_Name
)
,CONCMAX AS (
		SELECT *
		FROM CONCGRP
		WHERE Discount_Rank = 1
)
	SELECT
		 CT.ACCOUNTNUM AS 'Contact No'
		,CQ.[Quote Campaign Year] AS 'Campaign Year'
		,CT.ORDERNUM AS 'Order Number'
		,CT.INVOICE AS 'Invoice'
		,CT.VOUCHER AS 'Voucher'
		,SO.quoteid AS 'Quote ID'
		,CT.CURRENCYCODE AS 'Inv Currency'
		,PAYMMODE AS 'Payment Method'
		,CAST(CT.TRANSDATE AS DATE) AS 'Trans Date'
		,CT.CustTrans_AmountCur AS 'Inv Full Amount CUR'
		,CT.CustTrans_AmountMst AS 'Inv Full Amount GBP'
		--,CT.AMOUNTCUR AS 'Inv Line Amount CUR'
		--,CT.AMOUNTMST AS 'Inv Line Amount GBP'
		,CT.SETTLEAMOUNTCUR AS 'Settle Amount CUR'
		,CT.SETTLEAMOUNTMST_Adj AS 'Settle Amount GBP'
		,CT.SETTLEAMOUNTCUR - ((COALESCE(INVSUBCRE.CustTrans_AmountCur, 0) + COALESCE(FTCNSUBCRE.CustTrans_AmountCur, 0))) *-1 AS 'Paid Amount CUR'
		,CT.SETTLEAMOUNTMST_Adj - ((COALESCE(INVSUBCRE.CustTrans_AmountMst, 0) + COALESCE(FTCNSUBCRE.CustTrans_AmountMst, 0))) *-1 AS 'Paid Amount GBP'
		,CT.CustTrans_AmountCur - CT.SETTLEAMOUNTCUR AS 'Balance CUR'
		,CT.CustTrans_AmountMst - CT.SETTLEAMOUNTMST_Adj AS 'Balance GBP'
		,CASE WHEN CT.CustTrans_AmountCur - CT.SETTLEAMOUNTCUR > 0 THEN 'Y' ELSE 'N' END AS 'Open Balance'
		,CASE WHEN CT.CustTrans_AmountMst - CT.SETTLEAMOUNTMST_Adj > 0 THEN 'Y' ELSE 'N' END AS 'Open Balance GBP'

		,(COALESCE(INVSUBCRE.CustTrans_AmountCur, 0) + COALESCE(FTCNSUBCRE.CustTrans_AmountCur, 0)) *-1 AS 'Credit Amount CUR'
		,(COALESCE(INVSUBCRE.CustTrans_AmountMst, 0) + COALESCE(FTCNSUBCRE.CustTrans_AmountMst, 0)) *-1 AS 'Credit Amount GBP'
		,CASE 
		WHEN CT.CustTrans_AmountCur = 0 THEN 'N'
		WHEN ((COALESCE(INVSUBCRE.CustTrans_AmountCur, 0) + COALESCE(FTCNSUBCRE.CustTrans_AmountCur, 0)) *-1) = CT.CustTrans_AmountCur 
		 THEN 'Y' ELSE 'N' END AS 'Fully Credited'
		,CASE 
			WHEN CONCMAX.apuk_discount = 100 THEN 'Full Concession'
			WHEN CT.CustTrans_AmountCur = 0 THEN 'Zero Value Invoice'
			WHEN ((COALESCE(INVSUBCRE.CustTrans_AmountCur, 0) + COALESCE(FTCNSUBCRE.CustTrans_AmountCur, 0)) *-1) = CT.CustTrans_AmountCur THEN 'Fully Credited'
			WHEN CT.CustTrans_AmountCur - CT.SETTLEAMOUNTCUR = 0 THEN 'Fully Paid'
			WHEN CT.SETTLEAMOUNTCUR - ((COALESCE(INVSUBCRE.CustTrans_AmountCur, 0) + COALESCE(FTCNSUBCRE.CustTrans_AmountCur, 0))) *-1 = 0 THEN 'No Payment'
			WHEN CT.CustTrans_AmountCur - CT.SETTLEAMOUNTCUR > 0 THEN 'Partially Paid'
			ELSE 'Unknown'
			END AS 'Payment Status'
	FROM [synapse_fo].[CUSTTRANS_RICS] CT
	INNER JOIN synapse_ce.salesorder SO
		ON CT.ORDERNUM = REPLACE(SO.OrderNumber, 'rcs', '')
	LEFT JOIN CorpQuote CQ
		ON SO.quoteid = CQ.[Quote ID]
	LEFT JOIN SO_Credit INVSUBCRE
		ON CT.VOUCHER = INVSUBCRE.LASTSETTLEVOUCHER
	LEFT JOIN FTCN_Credit FTCNSUBCRE
		ON CT.VOUCHER = FTCNSUBCRE.LASTSETTLEVOUCHER
	LEFT JOIN CONCMAX CONCMAX
		ON CONCMAX.INVOICE = CT.INVOICE
	WHERE TRANSTYPE IN (2, 36)
		AND CT.INVOICE NOT LIKE '%CRE%'
		AND CT.INVOICE NOT LIKE '%FTCN%'
		AND CT.RICINVOICETYPE <> 'FPF'
		AND EXISTS (
			SELECT CVC.[Contact No]
			FROM Subs.tblCorpValidContacts CVC
			WHERE CVC.[Contact No] = CT.ACCOUNTNUM
		) --Appears in Corp Process
	GROUP BY
		 CT.ACCOUNTNUM
		,CQ.[Quote Campaign Year]
		,CT.ORDERNUM
		,CT.INVOICE
		,CT.VOUCHER
		,SO.quoteid
		,CT.CURRENCYCODE
		,PAYMMODE
		,CT.TRANSDATE
		,CT.CustTrans_AmountCur
		,CT.CustTrans_AmountMst
		,CT.SETTLEAMOUNTCUR
		,CT.SETTLEAMOUNTMST_Adj
		,INVSUBCRE.CustTrans_AmountCur
		,INVSUBCRE.CustTrans_AmountMst
		,FTCNSUBCRE.CustTrans_AmountCur
		,FTCNSUBCRE.CustTrans_AmountMst
		,CONCMAX.apuk_discount

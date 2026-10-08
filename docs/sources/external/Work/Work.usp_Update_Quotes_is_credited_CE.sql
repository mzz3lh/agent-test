CREATE PROCEDURE [Work].[usp_Update_Quotes_is_credited_CE]
AS
/*
	Created by: Arthur Bond
	Created on: 2022-05-31 17:30
	Description: Updates the [is_credited] column in CE.tblQuote to indicate whether a quote has been fully refunded via Credit Sales Order(s)
*/
BEGIN

DROP TABLE IF EXISTS #QUO
DROP TABLE IF EXISTS #CustTrans
DROP TABLE IF EXISTS #BEST
DROP TABLE IF EXISTS #CustTransFirst
DROP TABLE IF EXISTS #CustTransCredit
DROP TABLE IF EXISTS #TT

SELECT 
 Rics_contactno
,q.[CustomerId]
,q.quoteid
,msdyn_quotenumber
,q.StateCode_Description
,q.apuk_totalprofessionalfees
,ISNULL(q.totalamount, 0.0) + ISNULL(q.apuk_lionheartdonation, 0.0) + ISNULL(q.apuk_directdebitfees, 0.0) AS [Total_Incl_Charges]
,SOR.OrderNumber
INTO #QUO
FROM CE.tblQuote q
LEFT JOIN [CE].[vwContact] cnt 
	ON q.[CustomerId] = cnt.[ContactId]
LEFT JOIN [CE].[tblSalesOrder] SOR 
	ON SOR.quoteid = Q.quoteid
WHERE q.StateCode_Description = 'Won'
AND q.apuk_campaignyear IS NOT NULL

SELECT 
 ACCOUNTNUM
,CustTrans_AmountCur AS 'CustTrans_AmountCur'
,CustTrans_AmountMst AS 'CustTrans_AmountMst'
,ORDERNUM
,INVOICE
,VOUCHER
,LASTSETTLEVOUCHER
,ROW_NUMBER() OVER (PARTITION BY ACCOUNTNUM, ORDERNUM, VOUCHER ORDER BY ACCOUNTNUM, ORDERNUM, VOUCHER) AS ROWNUM
INTO #CustTransFirst
FROM [FO].[tblCustTrans]
WHERE TRANSTYPE = 2

SELECT
 ACCOUNTNUM
,INVOICE
,VOUCHER
,SUM(CustTrans_AmountCur) AS 'CustTrans_AmountCur'
,SUM(CustTrans_AmountMst) AS 'CustTrans_AmountMst'
,ORDERNUM
,LASTSETTLEVOUCHER
INTO #CustTrans
FROM #CustTransFirst
WHERE ROWNUM = 1
AND INVOICE NOT LIKE '%CRE%'
GROUP BY ACCOUNTNUM, ORDERNUM, VOUCHER, INVOICE, LASTSETTLEVOUCHER

SELECT
 ACCOUNTNUM
,INVOICE
,VOUCHER
,LASTSETTLEVOUCHER
,SUM(AMOUNTCUR) AS AMOUNTCUR
,SUM(AMOUNTMST) AS AMOUNTMST
INTO #CustTransCredit
FROM [FO].[tblCustTrans]
WHERE TRANSTYPE = 2
AND INVOICE LIKE '%CRE%'
GROUP BY ACCOUNTNUM, INVOICE, VOUCHER, LASTSETTLEVOUCHER

SELECT 
 QUO.Rics_contactno
,QUO.[CustomerId]
,QUO.quoteid
,QUO.StateCode_Description
,SUM(Total_Incl_Charges) AS Quote_Amount
,SUM(apuk_totalprofessionalfees) AS AltAmount
,SUM(CTRC.AMOUNTCUR) AS Credit_Amount_CUR
,SUM(CTRC.AMOUNTMST) AS Credit_Amount_MST
,SUM(Total_Incl_Charges) + SUM(CTRC.AMOUNTCUR) AS Credit_Balance
,1 AS 'is_credited'
INTO #TT
FROM #QUO AS QUO
LEFT JOIN #CustTrans CTR ON QUO.OrderNumber = 'rcs' + CTR.ORDERNUM
LEFT JOIN #CustTransCredit CTRC ON CTRC.VOUCHER = CTR.LASTSETTLEVOUCHER
GROUP BY QUO.Rics_contactno, QUO.[CustomerId], QUO.quoteid, QUO.StateCode_Description
HAVING SUM(Total_Incl_Charges) + SUM(CTRC.AMOUNTCUR) = 0.00

UPDATE CE.tblQuote
SET CE.tblQuote.is_credited = COALESCE(TT.is_credited, 0)
FROM CE.tblQuote SRC
LEFT JOIN #TT TT
ON SRC.quoteid = TT.quoteid

--EXEC [Work].[usp_Update_Quotes_is_credited_CE]

END

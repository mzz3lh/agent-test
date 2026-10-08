CREATE VIEW [dbo].[vwD365MemberTransactionsAccountBalanceWIP]
 AS



WITH cteBal AS
(
SELECT
ACCOUNTNUM, SUM(CustTrans_AmountCur) - SUM(SETTLEAMOUNTCUR) AS AccountBalance
FROM FO.vwCustTrans
--WHERE ACCOUNTNUM = '0000000'
GROUP BY ACCOUNTNUM
),

cteInvBal AS
(

SELECT DISTINCT ContactNumber, ISNULL(SUM(InvoiceBalance),0.00) AS InvBal
 FROM dbo.vwD365MemberTransactionsWIP
 --WHERE ContactNumber = '0000000'
 GROUP BY ContactNumber
 )

 SELECT ContactNumber,AccountBalance,InvBal,
 CASE WHEN AccountBalance <> InvBal
 THEN 'No' ELSE 'Yes' 
 END AS AccountSettled
 FROM cteBal B
 INNER JOIN cteInvbal IB
 ON IB.ContactNumber = B.ACCOUNTNUM
 --WHERE Balance <> InvBal

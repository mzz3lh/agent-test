CREATE VIEW [dbo].[vwD365MemberTransactionsAccountBalance]
 AS
 -- Account balances
 WITH
 cteItems
 AS
 (
 SELECT DISTINCT ContactNumber,Invoice,InvoiceBalance--SUM(InvoiceBalance) AS AccountBalance
 FROM dbo.vwD365MemberTransactionsWIP
 --WHERE ContactNumber = '0000000'
)
SELECT ContactNumber,SUM(ISNULL(InvoiceBalance,0.00)) AS AccountBalance
FROM cteItems
GROUP BY ContactNumber

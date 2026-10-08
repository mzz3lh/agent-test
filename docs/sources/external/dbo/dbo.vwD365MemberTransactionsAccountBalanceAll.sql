CREATE VIEW [dbo].[vwD365MemberTransactionsAccountBalanceAll]
 AS



SELECT ACCOUNTNUM AS ContactNumber, SUM(AmountGBP) AS AccountBalance
FROM [dbo].[vwD365AllMemberTransactions]
--WHERE ACCOUNTNUM = '0000000'
GROUP BY ACCOUNTNUM

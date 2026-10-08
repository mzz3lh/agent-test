CREATE VIEW [dbo].[vwD365MultiCurrencyBalances]
AS
SELECT ACCOUNTNUM, CURRENCY,ROUND(SUM([Amount in Currency]),2) AS BalCur,
CASE 
WHEN ROUND(SUM([Amount in Currency]),2) >0 THEN 'Red'
WHEN ROUND(SUM([Amount in Currency]),2) = 0 THEN 'Green'
WHEN ROUND(SUM([Amount in Currency]),2) <0 THEN 'Amber'
END AS Colour
FROM [dbo].[vwD365AllMemberTransactions]
--WHERE ACCOUNTNUM = '0000000'
GROUP BY ACCOUNTNUM,CURRENCY

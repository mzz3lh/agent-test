CREATE   VIEW [FO].[vwYTDActuals]
AS
SELECT 
	FORMAT(lt.ACCOUNTINGDATE, 'MMM-yy') TransPeriod
	, lt.MAINACCOUNT GLAccount
	, lt.CostCenter CostCentre
	, UPPER(lt.dataareaid) 'Entity'
	,lt.productcode
	,lt.productgroup
	,lt.Country
	, SUM(lt.TRANSACTIONCURRENCYAMOUNT) SumAmountCur
	, lt.TRANSACTIONCURRENCYCODE
	--, cast(sum(case 
	--	when l.DEFAULTCURRENCY = 'GBP' then lt.ACCOUNTINGCURRENCYAMOUNT
 --   --when l.DEFAULTCURRENCY = 'GBP' then lt.AMOUNTMSTSECOND 
	--end) as money) [SumAmountGBP]
	,SUM(lt.ACCOUNTINGCURRENCYAMOUNT) SumAmountMST 
FROM [FO].[vwLedgerTrans] lt 
	JOIN [FO].[vwLedgerTable] l on l.MAINACCOUNTID = lt.MAINACCOUNT

WHERE --l.AccountType = 0
  lt.dataareaid <> 'ISL'
  AND ACCOUNTINGDATE BETWEEN CASE WHEN MONTH(GETDATE())> 8 
                                        THEN CAST(YEAR(GETDATE())-1 AS VARCHAR(4))
                                        ELSE CAST(YEAR(GETDATE())-2 AS VARCHAR(4)) END + '-08-01' --gets start of current fiscal
                           AND DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1) -- gets last day of prev month

GROUP BY
	FORMAT(lt.ACCOUNTINGDATE, 'MMM-yy')
	, lt.MAINACCOUNT
	, lt.CostCenter
	, lt.dataareaid
	,lt.TRANSACTIONCURRENCYCODE
	,lt.productcode
	,lt.productgroup
	,lt.Country

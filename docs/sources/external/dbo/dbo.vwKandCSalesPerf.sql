CREATE VIEW [dbo].[vwKandCSalesPerf]
AS

SELECT COUNT(DISTINCT KC1.SalesOrderID) AS [Total Orders], 
       SUM(KC1.NoOfPackages) AS [No of Subscribers], 
       COUNT(DISTINCT KC2.SalesOrderID) AS [Total Orders LW], 
       SUM(KC2.NoOfPackages) AS [No of Subscribers LW], 
       COUNT(DISTINCT KC1.SalesOrderID) - COUNT(DISTINCT KC2.SalesOrderID) AS [Orders WoW], 
	   COUNT(DISTINCT KC1.SalesOrderID) / COUNT(DISTINCT KC2.SalesOrderID) AS [Orders WoW PCT],  --TODO - why is it only returning 1
       SUM(KC1.NoOfPackages) - SUM(KC2.NoOfPackages) AS [Subscribers WoW], 
       COUNT(DISTINCT KC1.Rics_ReportingSubWorldRegion) AS [Total Markets], 
       SUM(KC3.IsFirstTimeMarket) AS [New Markets WoW], 
       SUM(KC1.LineTotal) AS [Total Sales], 
       CAST(SUM(KC1.LineTotal) / COUNT(DISTINCT KC1.SalesOrderID) AS DECIMAL(18, 2)) AS [Average Order Value],
	   SUM(KC4.NoOfPackages) AS [Candidate Package Subscribers],
	   SUM(KC5.NoOfPackages) AS [Professional Package Subscribers]

FROM vwKandCStats KC1
   LEFT JOIN vwKandCStats KC2 ON KC1.ricsv2_SubscriptionNo = KC2.ricsv2_SubscriptionNo
                            AND KC2.DateSOFulfilled <= DATEADD(ww, -1, GETDATE())
  LEFT JOIN vwKandCStats KC3 ON KC1.ricsv2_SubscriptionNo = KC3.ricsv2_SubscriptionNo
                            AND KC3.DateSOFulfilled > DATEADD(ww, -1, GETDATE())
   LEFT JOIN vwKandCStats KC4 ON KC1.ricsv2_SubscriptionNo = KC4.ricsv2_SubscriptionNo
                            AND KC4.ProductName = 'RICS Professional Development Package'
   LEFT JOIN vwKandCStats KC5 ON KC1.ricsv2_SubscriptionNo = KC5.ricsv2_SubscriptionNo
                            AND KC5.ProductName = 'RICS Professional Qualification Support Package'

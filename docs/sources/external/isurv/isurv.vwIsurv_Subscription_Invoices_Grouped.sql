CREATE   VIEW [isurv].[vwIsurv_Subscription_Invoices_Grouped] AS

WITH CTE AS (
	SELECT 
	 SQ.apuk_subscriptionid AS 'Subscription ID'
	,INV.Invoice
	,INV.[Invoice Amount CUR]
	,INV.[Invoice Amount GBP]
	,[Paid Amount CUR]
	,[Paid Amount GBP]
	,INV.[Payment Status]
	,INV.[Payment Status Rank]
	,RANK() OVER (PARTITION BY SQ.apuk_subscriptionid ORDER BY INV.[Payment Status Rank] ASC) AS Rankx
	FROM isurv.vwIsurv_Subscription_Quote SQ
	LEFT JOIN isurv.vwIsurv_Quote Q 
		ON SQ.quoteid = Q.[Quote ID]
	LEFT JOIN isurv.vwIsurv_Sales_Order SO
		ON Q.[Quote ID] = SO.quoteid
	LEFT JOIN isurv.vwIsurv_Invoices INV
		ON SO.[Order Number] = INV.[Order No.]
	)

	SELECT
	 [Subscription ID]
	,COUNT(Invoice) AS 'Invoice Count'
	,SUM([Invoice Amount CUR]) AS 'Invoice Amount CUR'
	,SUM([Invoice Amount GBP])  AS 'Invoice Amount GBP'
	,SUM([Paid Amount CUR]) AS 'Paid Amount CUR'
	,SUM([Paid Amount GBP]) AS 'Paid Amount GBP'
	,[Payment Status] AS 'Payment Status'
	FROM CTE
	WHERE Rankx = 1
	GROUP BY 
	 [Subscription ID]
	,[Payment Status]

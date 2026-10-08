CREATE   VIEW [isurv].[vwIsurv_Sales_Order_Detail] AS

	SELECT 
	[SalesOrderId]
	FROM [synapse_ce].[vwSalesOrderDetail]
	WHERE productnumber LIKE '%isurv%'
	GROUP BY [SalesOrderId]

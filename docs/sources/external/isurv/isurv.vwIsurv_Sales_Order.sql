CREATE   VIEW [isurv].[vwIsurv_Sales_Order] AS

	SELECT
	 SO.[SalesOrderId]
	,SUBSTRING(SO.OrderNumber, 4, 20) AS 'Order Number'
	,SO.[ContactId]
	,SO.[quoteid]
	FROM [synapse_ce].[vwSalesOrder] SO
	INNER JOIN Isurv.vwIsurv_Sales_Order_Detail SOD
		ON SOD.SalesOrderId = SO.SalesOrderId

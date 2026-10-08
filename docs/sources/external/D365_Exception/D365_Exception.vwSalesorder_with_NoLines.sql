CREATE   VIEW [D365_Exception].[vwSalesorder_with_NoLines]
AS
SELECT 		
		SO.CreatedOn,
		SO.OrderNumber,
		SO.apuk_eventcode AS EventCode,
		SO.AccountId,
		SO.SalesOrderId,
		SO.CustomerIdName,
		SO.Name,
		SO.OwnerIdName as Owner,
		SO.quoteid AS Quoteid,
		SO.StateCode_Description,
		SO.StatusCode_Description,
		SO.TransactionCurrencyIdName AS Currency,
		SO.PaymentMethod_Description AS PaymentMethod,
		SO.apuk_lionheartdonation,
		SO.apuk_lionheartdonation_base,
		SO.TotalAmount,
		SO.TotalAmount_Base,
		SO.TotalAmountLessFreight,
		SO.TotalAmountLessFreight_Base,
		SO.TotalDiscountAmount,
		SO.TotalDiscountAmount_Base,
		SO.TotalLineItemAmount,
		SO.TotalLineItemAmount_Base,
		SO.TotalLineItemDiscountAmount,
		SO.TotalLineItemDiscountAmount_Base,
		SO.TotalTax,
		SO.TotalTax_Base,
		SOD.ricsv1_StartDate,
		SOD.ricsv1_EndDate
FROM 	synapse_ce.vwSalesOrder SO
	LEFT JOIN synapse_ce.vwSalesOrderDetail SOD
		On SO.SalesOrderId = SOD.SalesOrderId

WHERE
	SOD.SalesOrderDetailId IS NULL
	AND so.[CreatedOn] > '2021-08-24'

CREATE VIEW [Product_Portfolio].[vw_Omni_OLA_Order] AS

	SELECT
	 CO.order_number AS 'Order No.'
	,CO.order_id AS 'Order ID'
	,CO.[status] AS 'Order Status'
	,CO.created AS 'Order Created Datetime'
	,CAST(CO.created AS DATE) AS 'Order Created Date'
	,CO.[uid] AS 'User ID'
	,U.[name] AS 'User Name' --is it though?
	,U.mail AS 'User Email'
	,U.[status] AS 'User Status'
	,LI.line_item_id AS 'Line Item ID'
	,LI.quantity AS 'Quantity'
	,LI.line_item_label AS 'Product ID'
	,CT.commerce_total_currency_code AS 'Currency Code'
	,(CT.commerce_total_amount / 100.0)  AS 'Sales Amount CUR'
    ,(CT.commerce_total_amount / 100.0) 
		*
		CASE 
			WHEN CT.commerce_total_currency_code = 'GBP' THEN 1.0
			ELSE 1.0 / EXC.ExchangeRate
		END
	AS 'Sales Amount MST'
	,CASE
		WHEN LI.line_item_label IN ('EL-DRS-012', 'EL-DRS-FCADR') THEN 'DRS'
		WHEN LEFT(LI.line_item_label, 3) = 'MEE' THEN 'Markets'
		ELSE 'PD&L'
		END AS 'Business Group'
	FROM Drupal.commerce_order CO
	INNER JOIN Drupal.commerce_line_item LI
		ON CO.order_id = LI.order_id
	LEFT JOIN Drupal.field_data_commerce_total CT
		ON CT.[entity_id] = LI.line_item_id
	LEFT JOIN [Sharedstore].[users] U
		ON U.[uid] = CO.[uid]
	LEFT JOIN FO.vwExchangeRates EXC
		ON EXC.ToCurrency = CT.commerce_total_currency_code
		AND CAST(CO.created AS DATE) BETWEEN EXC.FromDate AND EXC.ToDate
		AND RateTypeName = 'Default'
	WHERE CO.created >= '2022-01-01'
	AND CO.[status] = 'invoiced'

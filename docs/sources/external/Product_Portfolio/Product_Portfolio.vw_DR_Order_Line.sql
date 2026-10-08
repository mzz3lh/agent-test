CREATE VIEW [Product_Portfolio].[vw_DR_Order_Line] AS

	SELECT
	 LI.line_item_id AS 'Line Item ID'
	,LI.order_id AS 'Order ID'
	,LI.[type] AS 'Type'
	,LI.line_item_label AS 'Line Item SKU'
	,LI.quantity AS 'Quantity'
	,LI.created AS 'Created Datetime'
	,LI.changed AS 'Modified Datetime'
	,CT.commerce_total_amount / 100 AS 'Order Amount'
	,CT.commerce_total_currency_code AS 'Currency'
	,CASE
		WHEN LI.line_item_label IN ('EL-DRS-012', 'EL-DRS-FCADR') THEN 'DRS'
		WHEN LEFT(LI.line_item_label, 3) = 'MEE' THEN 'Markets'
		ELSE 'PD&L'
		END AS 'Business Group'
	FROM Drupal.commerce_line_item LI
	LEFT JOIN Drupal.field_data_commerce_total CT
		ON CT.[entity_id] = LI.line_item_id

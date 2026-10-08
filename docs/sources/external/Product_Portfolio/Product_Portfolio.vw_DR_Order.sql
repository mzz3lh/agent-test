CREATE VIEW [Product_Portfolio].[vw_DR_Order] AS
	
	SELECT
	 CO.order_id AS 'Order ID'
	,CO.order_number AS 'Order No.'
	--,CO.revision_id
	--,CO.[type] --single value
	,CO.[uid] AS 'User ID'
	--,CO.mail --Purpose?
	,CO.[status] AS 'Status'
	,CO.created AS 'Created Datetime'
	,CAST(CO.created AS DATE) AS 'Created Date'
	,CO.changed AS 'Modified Datetime'
	--,CO.hostname --Purpose?
	--,CO.placed --Purpose? Created handles this?
	FROM Drupal.commerce_order CO

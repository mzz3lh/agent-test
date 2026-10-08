CREATE VIEW [Product_Portfolio].[vw_DR_Product] AS

WITH Stock AS (
	SELECT 
	 crs.shortname
	,fdata.[value] AS 'Stock'
	FROM [Moodle].mdl_customfield_data fdata 
	LEFT JOIN [Moodle].mdl_course crs 
		ON crs.id = fdata.instanceid
	LEFT JOIN [Moodle].mdl_customfield_field field 
		ON field.id = fdata.fieldid
	WHERE field.shortname = 'inventory'
	)

	SELECT 
	 PRD.product_id AS 'Product ID'
	--,revision_id
	,PRD.sku AS 'SKU'
	,PRD.title AS 'Product'
	,PRD.[type] AS 'Product Type Code'
	,PRD.[uid]
	,PRD.[status] AS 'Status'
	,PRD.created AS 'Created Datetime'
	,PRD.changed AS 'Modified Datetime'
	,STK.Stock
	FROM Drupal.commerce_product PRD
	LEFT JOIN Drupal.field_data_field_shortname DSN
		ON PRD.product_id = DSN.entity_id
		AND DSN.entity_type = 'commerce_product'
	LEFT JOIN Moodle.mdl_course CRS
		ON DSN.field_shortname_value = CRS.shortname
	LEFT JOIN Stock STK
		ON STK.shortname = CRS.shortname
	WHERE product_id <> 3558 --Temp fix to duplicated WC-PDS-000000 record 22-10-2025

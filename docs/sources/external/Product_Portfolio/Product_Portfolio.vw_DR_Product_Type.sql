CREATE VIEW Product_Portfolio.vw_DR_Product_Type AS

	SELECT 
	 [type] AS 'Product Type Code'
	,[name] AS 'Product Type'
	FROM Drupal.commerce_product_type

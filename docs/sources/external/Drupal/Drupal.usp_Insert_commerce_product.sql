CREATE   PROCEDURE [Drupal].[usp_Insert_commerce_product]
As
BEGIN

	INSERT INTO [Drupal].[commerce_product]
	(
		[product_id],
		[revision_id],
		[sku],
		[title],
		[type],
		[uid],
		[status],
		[created],
		[changed]
	)
	SELECT
		src.[product_id],
		src.[revision_id],
		src.[sku],
		src.[title],
		src.[type],
		src.[uid],
		src.[status],
		src.[created],
		src.[changed]
	FROM [Work].[commerce_product] src
		LEFT JOIN [Drupal].[commerce_product] tgt
			ON src.[product_id] = tgt.[product_id]
	WHERE tgt.[product_id] IS NULL


END

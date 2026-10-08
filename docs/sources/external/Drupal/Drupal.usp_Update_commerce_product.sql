CREATE   PROCEDURE [Drupal].[usp_Update_commerce_product]
As

BEGIN

	UPDATE tgt SET 
		tgt.[revision_id] = src.[revision_id],
		tgt.[sku] = src.[sku],
		tgt.[title] = src.[title],
		tgt.[type] = src.[type],
		tgt.[uid] = src.[uid],
		tgt.[status] = src.[status],
		tgt.[created] = src.[created],
		tgt.[changed] = src.[changed]
	FROM [Drupal].[commerce_product] tgt
		INNER JOIN [Work].[commerce_product] src
			ON tgt.[product_id] = src.[product_id]

END

CREATE   PROCEDURE [Drupal].[usp_Update_commerce_product_type]
As

BEGIN

	UPDATE tgt SET 
		tgt.[name] = src.[name],
		tgt.[description] = src.[description],
		tgt.[revision] = src.[revision]
	FROM [Drupal].[commerce_product_type] tgt
		INNER JOIN [Work].[commerce_product_type] src
			ON src.[type] = tgt.[type]

END

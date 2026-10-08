CREATE   PROCEDURE [Drupal].[usp_Insert_commerce_product_type]
AS
BEGIN

	INSERT INTO [Drupal].[commerce_product_type]
	(
		[type],
		[name],
		[description],
		[revision]
	)
	SELECT
		src.[type],
		src.[name],
		src.[description],
		src.[revision]
	FROM [Work].[commerce_product_type] src
		LEFT JOIN [Drupal].[commerce_product_type] tgt
			ON src.[type] = tgt.[type]
	WHERE tgt.[type] IS NULL


END

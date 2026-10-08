CREATE   PROCEDURE [Drupal].[usp_Insert_field_data_commerce_product]
As
BEGIN

	INSERT INTO [Drupal].[field_data_commerce_product]
	(
		[entity_type],
		[bundle],
		[deleted],
		[entity_id],
		[revision_id],
		[language],
		[delta],
		[commerce_product_product_id]
	)
	SELECT
		src.[entity_type],
		src.[bundle],
		src.[deleted],
		src.[entity_id],
		src.[revision_id],
		src.[language],
		src.[delta],
		src.[commerce_product_product_id]
	FROM [Work].[field_data_commerce_product] src
		LEFT JOIN [Drupal].[field_data_commerce_product] tgt
			ON src.[entity_type] = tgt.[entity_type]
			AND src.[deleted] = tgt.[deleted]
			AND src.[entity_id] = tgt.[entity_id]
			AND src.[language] = tgt.[language]
			AND src.[delta] = tgt.[delta]
	WHERE tgt.[entity_id] IS NULL


END

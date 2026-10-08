CREATE   PROCEDURE [Drupal].[usp_Insert_field_data_field_commerce_billy_i_date]
As
BEGIN

	INSERT INTO [Drupal].[field_data_field_commerce_billy_i_date]
	(
		[entity_type],
		[bundle],
		[deleted],
		[entity_id],
		[revision_id],
		[language],
		[delta],
		[field_commerce_billy_i_date_value]
	)
	SELECT
		src.[entity_type],
		src.[bundle],
		src.[deleted],
		src.[entity_id],
		src.[revision_id],
		src.[language],
		src.[delta],
		src.[field_commerce_billy_i_date_value]
	FROM [Work].[field_data_field_commerce_billy_i_date] src
		LEFT JOIN [Drupal].[field_data_field_commerce_billy_i_date] tgt
			ON src.[entity_type] = tgt.[entity_type]
			AND src.[deleted] = tgt.[deleted]
			AND src.[entity_id] = tgt.[entity_id]
			AND src.[language] = tgt.[language]
			AND src.[delta] = tgt.[delta]
	WHERE tgt.[entity_id] IS NULL


END

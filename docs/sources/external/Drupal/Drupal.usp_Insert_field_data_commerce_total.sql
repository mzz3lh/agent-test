CREATE   PROCEDURE [Drupal].[usp_Insert_field_data_commerce_total]
AS
BEGIN

	INSERT INTO [Drupal].[field_data_commerce_total]
	(
		[entity_type],
		[bundle],
		[deleted],
		[entity_id],
		[revision_id],
		[language],
		[delta],
		[commerce_total_amount],
		[commerce_total_currency_code]
	)
	SELECT
		src.[entity_type],
		src.[bundle],
		src.[deleted],
		src.[entity_id],
		src.[revision_id],
		src.[language],
		src.[delta],
		src.[commerce_total_amount],
		src.[commerce_total_currency_code]
	FROM [work].[field_data_commerce_total] src
		LEFT JOIN [Drupal].[field_data_commerce_total] tgt
			ON	tgt.[entity_type] = src.[entity_type]
				AND tgt.[deleted] = src.[deleted]
				AND tgt.[entity_id] = src.[entity_id]
				AND tgt.[delta] = src.[delta]
	WHERE tgt.[entity_id] IS NULL

END

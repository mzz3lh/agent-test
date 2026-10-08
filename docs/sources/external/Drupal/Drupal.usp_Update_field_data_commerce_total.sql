CREATE   PROCEDURE [Drupal].[usp_Update_field_data_commerce_total]
AS
BEGIN

	UPDATE tgt SET
		tgt.[bundle] = src.[bundle],
		tgt.[revision_id] = src.[revision_id],
		tgt.[language] = src.[language],
		tgt.[commerce_total_amount] = src.[commerce_total_amount],
		tgt.[commerce_total_currency_code] = src.[commerce_total_currency_code]
	FROM [Drupal].[field_data_commerce_total] tgt
		INNER JOIN [work].[field_data_commerce_total] src
			ON	tgt.[entity_type] = src.[entity_type]
				AND tgt.[deleted] = src.[deleted]
				AND tgt.[entity_id] = src.[entity_id]
				AND tgt.[delta] = src.[delta]

END

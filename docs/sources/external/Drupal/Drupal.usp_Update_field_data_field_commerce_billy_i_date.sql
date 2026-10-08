CREATE   PROCEDURE [Drupal].[usp_Update_field_data_field_commerce_billy_i_date]
As

BEGIN

	UPDATE tgt SET 
		tgt.[bundle] = src.[bundle],
		tgt.[revision_id] = src.[revision_id],
		tgt.[field_commerce_billy_i_date_value] = src.[field_commerce_billy_i_date_value]
	FROM [Drupal].[field_data_field_commerce_billy_i_date] tgt
		INNER JOIN [Work].[field_data_field_commerce_billy_i_date] src
			ON src.[entity_type] = tgt.[entity_type]
			AND src.[deleted] = tgt.[deleted]
			AND src.[entity_id] = tgt.[entity_id]
			AND src.[language] = tgt.[language]
			AND src.[delta] = tgt.[delta]

END

CREATE   PROCEDURE [Drupal].[usp_Update_field_data_field_shortname]
As

BEGIN

	UPDATE tgt SET 
		tgt.[bundle] = src.[bundle],
		tgt.[revision_id] = src.[revision_id],
		tgt.[field_shortname_value] = src.[field_shortname_value],
		tgt.[field_shortname_format] = src.[field_shortname_format]
	FROM [Drupal].[field_data_field_shortname] tgt
		INNER JOIN [Work].[field_data_field_shortname] src
			ON src.[entity_type] = tgt.[entity_type]
			AND src.[deleted] = tgt.[deleted]
			AND src.[entity_id] = tgt.[entity_id]
			AND src.[language] = tgt.[language]
			AND src.[delta] = tgt.[delta]

END

CREATE   PROCEDURE [Sharedstore].[usp_Update_field_data_field_country]
AS
BEGIN

	UPDATE tgt SET 
		tgt.[bundle] = src.[bundle],
		tgt.[revision_id] = src.[revision_id],
		tgt.[field_country_iso2] = src.[field_country_iso2]
	FROM [Sharedstore].[field_data_field_country] tgt
		INNER JOIN [work].[field_data_field_country] src
			ON src.[entity_type] = tgt.[entity_type]
			AND src.[deleted] = tgt.[deleted]
			AND src.[entity_id] = tgt.[entity_id]
			AND src.[language] = tgt.[language]
			AND src.[delta] = tgt.[delta]
END

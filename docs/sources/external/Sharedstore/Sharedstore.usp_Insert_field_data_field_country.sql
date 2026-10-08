/****************** STAR Sharedstore procedures **************/

CREATE   PROCEDURE [Sharedstore].[usp_Insert_field_data_field_country]
AS
BEGIN

	INSERT INTO [Sharedstore].[field_data_field_country]
	(
		[entity_type],
		[bundle],
		[deleted],
		[entity_id],
		[revision_id],
		[language],
		[delta],
		[field_country_iso2]
	)
	SELECT
		src.[entity_type],
		src.[bundle],
		src.[deleted],
		src.[entity_id],
		src.[revision_id],
		src.[language],
		src.[delta],
		src.[field_country_iso2]
	FROM [work].[field_data_field_country] src
		LEFT JOIN [Sharedstore].[field_data_field_country] tgt
			ON src.[entity_type] = tgt.[entity_type]
			AND src.[deleted] = tgt.[deleted]
			AND src.[entity_id] = tgt.[entity_id]
			AND src.[language] = tgt.[language]
			AND src.[delta] = tgt.[delta]
	WHERE tgt.[entity_id]  IS NULL
END

--Need to work on
CREATE   PROCEDURE [synapse_ce].[usp_Insert_OptionsetMetadata]
AS
BEGIN
	--truncate target table
	TRUNCATE TABLE synapse_ce.OptionSetMetadata


	INSERT INTO synapse_ce.OptionSetMetadata
	(
		EntityName,
		OptionSetName,
		[Option],
		--IsUserLocalizedLabel,
		--LocalizedLabelLanguageCode,
		LocalizedLabel
	)
	SELECT
		EntityName,
		OptionSetName,
		[Option],
		--IsUserLocalizedLabel,
		--LocalizedLabelLanguageCode,
		LocalizedLabel
	FROM staging_ce.OptionSetMetadata
END

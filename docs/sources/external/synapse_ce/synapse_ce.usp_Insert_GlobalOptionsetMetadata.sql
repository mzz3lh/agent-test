CREATE   PROCEDURE [synapse_ce].[usp_Insert_GlobalOptionsetMetadata]
AS
BEGIN
	--truncate target table
	TRUNCATE TABLE synapse_ce.GlobalOptionSetMetadata


	INSERT INTO synapse_ce.GlobalOptionSetMetadata
	(
		OptionSetName,
		[Option],
--		IsUserLocalizedLabel,
--		LocalizedLabelLanguageCode,
		LocalizedLabel,
		GlobalOptionSetName,
		EntityName
	)
	SELECT
		OptionSetName,
		[Option],
--		IsUserLocalizedLabel,
--		LocalizedLabelLanguageCode,
		LocalizedLabel,
		GlobalOptionSetName,
		EntityName
	FROM staging_ce.GlobalOptionSetMetadata
END

CREATE   PROCEDURE [synapse_ce].[usp_Insert_statemetadata]
AS
BEGIN

	--truncate target table
	TRUNCATE TABLE synapse_ce.StateMetadata


	INSERT INTO synapse_ce.StateMetadata
	(
		EntityName,
		[State],
--		IsUserLocalizedLabel,
--		LocalizedLabelLanguageCode,
		LocalizedLabel
	)
	SELECT
		EntityName,
		[State],
--		IsUserLocalizedLabel,
--		LocalizedLabelLanguageCode,
		LocalizedLabel
	FROM staging_ce.statemetadata
END

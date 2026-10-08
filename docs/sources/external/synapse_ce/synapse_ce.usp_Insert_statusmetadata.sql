CREATE   PROCEDURE [synapse_ce].[usp_Insert_statusmetadata]
AS
BEGIN

	--truncate target table
	TRUNCATE TABLE synapse_ce.StatusMetadata

	INSERT INTO synapse_ce.StatusMetadata
	(
		EntityName,
		[State],
		[Status],
--		IsUserLocalizedLabel,
--		LocalizedLabelLanguageCode,
		LocalizedLabel
	)
	SELECT
		EntityName,
		[State],
		[Status],
--		IsUserLocalizedLabel,
--		LocalizedLabelLanguageCode,
		LocalizedLabel
	FROM staging_ce.statusmetadata
END

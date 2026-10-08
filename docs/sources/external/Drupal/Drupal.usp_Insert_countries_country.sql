CREATE   PROCEDURE [Drupal].[usp_Insert_countries_country]
As
BEGIN

	INSERT INTO [Drupal].[countries_country]
	(
		[cid],
		[iso2],
		[iso3],
		[name],
		[official_name],
		[numcode],
		[continent],
		[enabled]
	)
	SELECT
		src.[cid],
		src.[iso2],
		src.[iso3],
		src.[name],
		src.[official_name],
		src.[numcode],
		src.[continent],
		src.[enabled]
	FROM [Work].[countries_country] src
		LEFT JOIN [Drupal].[countries_country] tgt
			ON src.[cid] = tgt.[cid]
	WHERE tgt.[cid] IS NULL


END

CREATE   PROCEDURE [Drupal].[usp_Update_countries_country]
As

BEGIN

	UPDATE tgt SET 
		tgt.[iso2] = src.[iso2],
		tgt.[iso3] = src.[iso3],
		tgt.[name] = src.[name],
		tgt.[official_name] = src.[official_name],
		tgt.[numcode] = src.[numcode],
		tgt.[continent] = src.[continent],
		tgt.[enabled] = src.[enabled]
	FROM [Drupal].[countries_country] tgt
		INNER JOIN [Work].[countries_country] src
			ON tgt.[cid] = src.[cid]

END

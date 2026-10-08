/****** Object:  View [dbo].[vwPreferences]    Script Date: 26/08/2022 10:50:32 ******/
CREATE   VIEW [FAM].[vwPreferences]
AS

	WITH cteDAta
	AS
	(
		SELECT 
			ROW_NUMBER() OVER(PARTITION BY apuk_contactid ORDER BY apuk_contactid DESC) AS RowNumber, 
			apuk_contactid AS ContactID, 
			[value],  --Do not change 'value' name. Leave it as it is.
			[modifiedon]
		FROM [synapse_ce].[apuk_ricsrecord] 
			CROSS APPLY STRING_SPLIT(ISNULL(apuk_memberdirectorydisplayoptions,''), ';')
	)

	SELECT 
		ContactID,
		LocalizedLabel AS Preference,
		modifiedon
	FROM cteData CTE
		LEFT JOIN [synapse_ce].[GlobalOptionSetMetadata] MD
			ON MD.[option] = CTE.[value]
			AND MD.OptionSetName = 'apuk_memberdirectorydisplayoptions'
			AND MD.EntityName = 'apuk_ricsrecord'
	WHERE LocalizedLabel IS NOT NULL

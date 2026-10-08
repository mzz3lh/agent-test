CREATE   VIEW [Subs].[vwLocalGroup_Grouped] AS

	SELECT 
		 [apuk_countryid]
		,[country_two_char_code]
		,[country_three_char_code]
		,[apuk_countryid_name] AS 'Country'
		,[apuk_reportingsubworldregion_name] AS 'Sub Region'
		,[apuk_worldregionid_name] AS 'World Region'
		,[statecode]
		,[StateCode_Description]
		,[statuscode]
		,[StatusCode_Description]
	FROM [CE].[vwLocalGroup]
	GROUP BY 
		 [apuk_countryid]
		,[country_two_char_code]
		,[country_three_char_code]
		,[apuk_countryid_name]
		,[apuk_reportingsubworldregion_name]
		,[apuk_worldregionid_name]
		,[statecode]
		,[StateCode_Description]
		,[statuscode]
		,[StatusCode_Description]

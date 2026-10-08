CREATE   VIEW [Subs].[vwLocalGroup] AS

	SELECT 
	 [apuk_localgroupid]
	,[country_two_char_code]
	,[country_three_char_code]
	,[apuk_countryid_name] AS 'Country'
	,Fin_Market AS 'Market'
	,Fin_Region AS 'Region'
	,Fin_World_Region AS 'World Region'
	FROM [CE].[vwLocalGroup]

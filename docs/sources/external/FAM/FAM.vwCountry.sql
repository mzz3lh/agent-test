/****** Object:  View [FAM].[vwCountry]    Script Date: 25/10/2022 13:03:38 ******/
CREATE   VIEW [FAM].[vwCountry]
AS
Select 
	apuk_countryid, 
	apuk_name, 
	apuk_code 
from [synapse_ce].[apuk_country]

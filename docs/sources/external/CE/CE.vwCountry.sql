CREATE   VIEW [CE].[vwCountry]
AS
SELECT
	[apuk_countryid],
	[apuk_name],
	[apuk_code],
	[transactioncurrencyid],
	[currencyname],
	[currencysymbol],
	[isocurrencycode],
	[apuk_worldregionid],
	[apuk_worldregionid_name],
	[createdon],
	[modifiedon],
	[apuk_membershipsubslionheartamount],
	[apuk_membershipsubslionheartamount_base],
	[exchangerate],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description],
	[apuk_isocode]
FROM [synapse_ce].[vwCountry]

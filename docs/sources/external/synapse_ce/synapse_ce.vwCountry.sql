CREATE   VIEW [synapse_ce].[vwCountry]
AS
SELECT 
	cnt.[apuk_countryid],
	cnt.[apuk_name],
	cnt.[apuk_code],
	cnt.[transactioncurrencyid],
	cur.[currencyname],
	cur.[currencysymbol],
	cur.[isocurrencycode],
	cnt.[apuk_worldregionid],
	wrg.[apuk_name] AS [apuk_worldregionid_name],
	cnt.[createdon],
	cnt.[modifiedon],
	cnt.[apuk_membershipsubslionheartamount],
	cnt.[apuk_membershipsubslionheartamount_base],
	cnt.[exchangerate],
	cnt.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	cnt.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	[apuk_isocode]
FROM synapse_ce.apuk_country cnt
	LEFT JOIN synapse_ce.transactioncurrency cur
		ON cnt.[transactioncurrencyid] = cur.[transactioncurrencyid]
	LEFT JOIN synapse_ce.apuk_worldregion wrg
		ON cnt.[apuk_worldregionid] = wrg.[apuk_worldregionid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON cnt.[StateCode] = stStateCode.[State]
		AND stStateCode.EntityName = 'apuk_country'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON cnt.[statuscode] = stStatusCode.[Status]
		AND stStatusCode.EntityName = 'apuk_country'

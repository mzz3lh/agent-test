CREATE   VIEW [CE].[vwapuk_alert]
AS
SELECT 
	T1.[apuk_alertid]
	,T1.[apuk_name]
	,T1.[statecode]
	,stStateCode.[LocalizedLabel] AS [StateCode_Description]
	,T1.[statuscode]
	,stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
	,T1.[apuk_type]
	,sttype.[LocalizedLabel] AS [apuk_type_description]
	,T1.[owneridname]
	,T1.[apuk_accountid]
	,T1.[apuk_accountidname]
	,T1.[apuk_contactid]
	,T1.[apuk_contactidname]
	,T1.[createdon]
	,T1.[createdbyname]
	,T1.[modifiedon]
	,T1.[modifiedbyname]
	,T1.[createdonbehalfbyname]
	,T1.[modifiedonbehalfbyname]
	,T1.[apuk_expirydate]

FROM [synapse_ce].[apuk_alert] T1
	LEFT JOIN [synapse_ce].[StateMetadata] stStateCode
		ON T1.[statecode] = stStateCode.[State]
		AND stStateCode.[EntityName] = 'apuk_alert'
	LEFT JOIN [synapse_ce].[StatusMetadata] stStatusCode
		ON T1.[statuscode] = stStatusCode.[Status]
		AND stStatusCode.[EntityName] = 'apuk_alert'
	LEFT JOIN [synapse_ce].[OptionSetMetadata] sttype
		ON T1.[apuk_type] = sttype.[Option]
		AND sttype.[OptionSetName] = 'apuk_type'
		AND sttype.[EntityName] = 'apuk_alert'

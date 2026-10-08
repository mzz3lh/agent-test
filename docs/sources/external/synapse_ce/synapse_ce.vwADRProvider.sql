CREATE   VIEW [synapse_ce].[vwADRProvider]
AS
SELECT 
	adr.[apuk_adrproviderid],
	adr.[apuk_name],
	adr.[createdon],
	adr.[createdby],
	usrcreatedby.[fullname] AS [CreatedByName],
	adr.[modifiedon],
	adr.[modifiedby],
	usrmodifiedby.[fullname] AS [ModifiedByName],	
	adr.[apuk_showforvrlist],
	adr.[apuk_showforfirmregulation],
	adr.[apuk_hasmessage],
	adr.[organizationid],
	adr.[apuk_validfrom],
	adr.[apuk_validto],
	adr.[apuk_messagetext],
	adr.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	adr.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.apuk_adrprovider adr
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON adr.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON adr.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON adr.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_adrprovider'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON adr.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_adrprovider'

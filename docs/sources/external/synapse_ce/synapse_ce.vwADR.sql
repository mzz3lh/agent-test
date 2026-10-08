CREATE   VIEW [synapse_ce].[vwADR]
AS
SELECT 
	adr.[apuk_adrid],
	adr.[apuk_name],
	adr.[createdon],
	adr.[createdby],
	usrcreatedby.[fullname] AS [CreatedByName],
	adr.[modifiedon],
	adr.[modifiedby],
	usrmodifiedby.[fullname] AS [ModifiedByName],	
	adr.[ownerid],
	ownid.[fullname] AS [OwnerIdName],
	adr.[owningbusinessunit],
	bunit.[name] AS [OwningBusinessUnitName],
	adr.[apuk_regulatedschemeid],
	adr.[overriddencreatedon],
	adr.[apuk_adrproviderid],
	adr.[apuk_countryid],
	adr.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	adr.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.apuk_adr adr
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON adr.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON adr.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON adr.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON adr.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_adr'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON adr.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_adr'
	LEFT JOIN synapse_ce.businessunit bunit
		ON adr.[owningbusinessunit] = bunit.[businessunitid]

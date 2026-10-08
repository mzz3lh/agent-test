CREATE   VIEW [CE].[vwapuk_memberbenefitactivation]
AS
SELECT 
	mem.[apuk_memberbenefitactivationid],
	mem.[apuk_name],
	mem.[createdon],
	mem.[createdby],
	usrcreatedby.[FullName] AS [createdbyName],
	mem.[modifiedon],
	mem.[modifiedby],
	usrmodifiedby.[FullName] AS [modifiedbyName],
	mem.[ownerid],
	ownid.[FullName] AS [owneridName],
	mem.[owningteam],
	mem.[owninguser],
	ownuser.[FullName] AS [owninguserName],
	mem.[apuk_ricsrecordid],
	mem.[owningbusinessunit],
	bunit.[name] AS [owningbusinessunitName],
	mem.[apuk_suspendedby],
	suspby.[FullName] AS [apuk_suspendedbyName],
	mem.[createdonbehalfby],
	usrcreatedonbehalfby.[FullName] AS [createdonbehalfbyName],
	mem.[modifiedonbehalfby],
	usrmodifiedonbehalfby.[FullName] AS [modifiedonbehalfofbyName],
	mem.[apuk_suspensionreason],
	mem.[apuk_campaignyear],
	mem.[statecode],
	stStateCode.[LocalizedLabel] AS [statecode_description],
	mem.[statuscode],
	stStatusCode.[LocalizedLabel] AS [statuscode_description]
FROM synapse_ce.apuk_memberbenefitactivation mem
	LEFT JOIN synapse_ce.SystemUser usrcreatedby
		ON mem.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.SystemUser usrmodifiedby
		ON mem.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.SystemUser ownid
		ON mem.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.SystemUser ownuser
		ON mem.[owninguser] = ownuser.[systemuserid]
	LEFT JOIN synapse_ce.SystemUser usrcreatedonbehalfby
		ON mem.[createdonbehalfby] = usrcreatedonbehalfby.[systemuserid]
	LEFT JOIN synapse_ce.SystemUser usrmodifiedonbehalfby
		ON mem.[modifiedonbehalfby] = usrmodifiedonbehalfby.[systemuserid]
	LEFT JOIN synapse_ce.SystemUser suspby
		ON mem.[apuk_suspendedby] = suspby.[systemuserid]
	LEFT JOIN [synapse_ce].[businessunit] bunit
		ON mem.[owningbusinessunit] = bunit.[businessunitid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON mem.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_memberbenefitactivation'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON mem.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_memberbenefitactivation'

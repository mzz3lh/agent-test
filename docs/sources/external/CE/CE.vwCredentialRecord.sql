CREATE    VIEW [CE].[vwCredentialRecord]
AS

SELECT 
	cr.[apuk_credentialrecordid],
	cr.[apuk_name],
	cr.[createdon],
	cr.[createdby],
	usrCreatedBy.[FullName] AS [createdbyName],
	cr.[createdonbehalfby],
	usrCreatedOnBehalfBy.[FullName] AS [createdonbehalfbyName],
	cr.[modifiedon],
	cr.[modifiedby],
	usrModBy.[FirstName] AS [modifiedbyName],
	cr.[modifiedonbehalfby],
	usrModOnBehalfBy.[FullName] AS [modifiedonbehalfbyName],
	cr.[ownerid],
	ownid.[FullName] AS [owneridName],
	cr.[apuk_credential],
	cr.[apuk_credentialName],
	cr.[apuk_contact],
	cnt.[FullName] AS [apuk_contactName],
	cr.[apuk_startdate],
	cr.[apuk_enddate],
	cr.[apuk_qualificationpacksent],
	cr.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	cr.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	cr.[overriddencreatedon],
	cr.[owningbusinessunit],
	cr.[owningbusinessunitName]
FROM [synapse_ce].[vwCredentialRecord] cr
	LEFT JOIN [CE].[vwSystemUser] usrCreatedBy
		ON cr.[createdby] = usrCreatedBy.[SystemUserId]
	LEFT JOIN [CE].[vwSystemUser] usrModBy
		ON cr.[modifiedby] = usrModBy.[SystemUserId]
	LEFT JOIN [CE].[vwSystemUser] ownid
		ON cr.[ownerid] = ownid.[SystemUserId]
	LEFT JOIN [CE].[vwSystemUser] usrCreatedOnBehalfBy
		ON cr.[createdonbehalfby] = usrCreatedOnBehalfBy.[SystemUserId]
	LEFT JOIN [CE].[vwSystemUser] usrModOnBehalfBy
		ON cr.[modifiedonbehalfby] = usrModOnBehalfBy.[SystemUserId]
	LEFT JOIN [synapse_ce].[Contact] cnt
		ON cr.[apuk_contact] = cnt.[ContactId]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON cr.[statecode] = stStateCode.[State]
		AND stStateCode.[EntityName] = 'apuk_credentialrecord'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON cr.[statuscode] = stStatusCode.[Status]
		AND stStatusCode.[EntityName] = 'apuk_credentialrecord'

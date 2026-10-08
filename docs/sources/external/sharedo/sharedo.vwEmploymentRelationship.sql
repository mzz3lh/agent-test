CREATE   VIEW [sharedo].[vwEmploymentRelationship]
AS
SELECT 
	er.apuk_employmentrelationshipid
	,er.apuk_accountid
	,er.apuk_accountidname
	,er.apuk_accountidyominame
	,er.apuk_contactid
	,er.apuk_contactidname
	,er.apuk_contactidyominame
	,er.apuk_enddate
	,er.apuk_primaryemployment
	,optprimaryemp.LocalizedLabel as apuk_primaryemploymentname
	,er.apuk_relationshiptype
	,optempreltype.LocalizedLabel as apuk_relationshiptypename
	,er.apuk_startdate
	,er.statecode
	,statecode.LocalizedLabel as statecodename	
	,er.statuscode
	,statuscode.[LocalizedLabel] as statuscodename
	,er.createdon
	,er.createdby
	,er.createdbyname
	,er.createdonbehalfby
	,er.createdonbehalfbyname
	,er.createdonbehalfbyyominame
	,er.modifiedon
	,er.modifiedby
	,er.modifiedbyname
	,er.modifiedbyyominame
	,er.modifiedonbehalfby
	,er.modifiedonbehalfbyname
	,er.modifiedonbehalfbyyominame
FROM synapse_ce.apuk_employmentrelationship er
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON er.statecode = statecode.[State]
		AND statecode.[EntityName] = 'apuk_employmentrelationship'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON er.statuscode = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_employmentrelationship'
	LEFT JOIN synapse_ce.OptionSetMetadata optprimaryemp
		ON er.apuk_primaryemployment = optprimaryemp.[Option]
		AND optprimaryemp.[OptionSetName] = 'apuk_primaryemployment'
		AND optprimaryemp.[EntityName] = 'apuk_employmentrelationship'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optempreltype
		ON er.apuk_relationshiptype = optempreltype.[Option]
		AND optempreltype.[OptionSetName] = 'apuk_relationshiptype'
		AND optempreltype.[EntityName] = 'apuk_employmentrelationship'
WHERE apuk_AccountID IN (SELECT AccountID FROM sharedo.StagingContactAndAccount
				WHERE AccountID IS NOT NULL
				AND ContactID IS NOT NULL)
AND apuk_enddate IS NULL

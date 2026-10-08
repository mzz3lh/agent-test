CREATE   VIEW [sharedo].[vwCaseDeregistrationORIG]
AS
SELECT
	cd.apuk_casederegistrationid
	,cd.apuk_caseclosuredate
	,cd.apuk_caseclosuredatetime
	,cd.apuk_casedescription
	,cd.apuk_firmid
	,cd.apuk_firmidname
	,cd.apuk_individualid
	,cd.apuk_individualidname
	,cd.apuk_individualidyominame
	,cd.apuk_removalreason
	,optremreason.LocalizedLabel as apuk_removalreasonname
	,cd.apuk_status  --added PS  for Tom Bejan 21/05/2024
	,cd.statecode
	,statecode.LocalizedLabel as statecodename	
	,cd.statuscode
	,statuscode.[LocalizedLabel] as statuscodename
	,cd.createdon
	,cd.createdby
	,cd.createdbyname
	,cd.createdbyyominame
	,cd.createdonbehalfby
	,cd.createdonbehalfbyname
	,cd.createdonbehalfbyyominame
	,cd.modifiedon
	,cd.modifiedby
	,cd.modifiedbyname
	,cd.modifiedbyyominame
	,cd.modifiedonbehalfby
	,cd.modifiedonbehalfbyname
	,cd.modifiedonbehalfbyyominame
	,cd.ownerid
	,cd.owneridname
	,cd.apuk_name  --added DBA/PS as per request Tom Bejan 07/08/2024.
FROM synapse_ce.apuk_casederegistration cd
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON cd.statecode = statecode.[State]
		AND statecode.[EntityName] = 'apuk_casederegistration'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON cd.statuscode = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_casederegistration'
	LEFT JOIN synapse_ce.OptionSetMetadata optremreason
		ON cd.apuk_removalreason = optremreason.[Option]
		AND optremreason.[OptionSetName] = 'apuk_removalreason'
		AND optremreason.[EntityName] = 'apuk_casederegistration'

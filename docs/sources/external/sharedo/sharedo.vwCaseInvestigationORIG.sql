CREATE   VIEW [sharedo].[vwCaseInvestigationORIG]
AS
SELECT
	ci.apuk_caseinvestigationid
	,ci.apuk_areaofbreach
	,ci.apuk_areaofbreach2
	,ci.apuk_areaofbreach2name
	,ci.apuk_areaofbreach3
	,ci.apuk_areaofbreach3name
	,ci.apuk_areaofbreachname
	,ci.apuk_areaofpractice
	,ci.apuk_areaofpracticename
	,ci.apuk_caseclosuredate
	,ci.apuk_caseclosuredatetime
	,ci.apuk_casesummarytitle
	,ci.apuk_description
	,ci.apuk_memberid
	,ci.apuk_memberidname
	,ci.apuk_memberidyominame
	,ci.apuk_name
	,ci.apuk_regardingtype
	,optregtype.LocalizedLabel as apuk_regardingtypename
	,ci.apuk_regulatedfirm
	,ci.apuk_regulatedfirmname
	,ci.apuk_regulatedfirmyominame
	,ci.apuk_regulatedindividual
	,ci.apuk_regulatedindividualname
	,ci.apuk_regulatedindividualyominame
	,ci.apuk_resolution
	,optresolution.LocalizedLabel as apuk_resolutionname
	,ci.apuk_ruleofconduct2
	,ci.apuk_ruleofconduct2name
	,ci.apuk_status
	,optstatus.LocalizedLabel as apuk_statusname
	,ci.apuk_subject
	,ci.apuk_subjectname

	,ci.statecode
	,statecode.LocalizedLabel as statecodename	
	,ci.statuscode
	,statuscode.[LocalizedLabel] as statuscodename
	,ci.createdon
	,ci.createdby
	,ci.createdbyname
	,ci.createdbyyominame
	,ci.createdonbehalfby
	,ci.createdonbehalfbyname
	,ci.createdonbehalfbyyominame
	,ci.modifiedon
	,ci.modifiedby
	,ci.modifiedbyname
	,ci.modifiedbyyominame
	,ci.modifiedonbehalfby
	,ci.modifiedonbehalfbyname
	,ci.modifiedonbehalfbyyominame
	,ci.ownerid
	,ci.owneridname
	,ci.apuk_recordid --added DBA/PS as per request Tom Bejan 07/08/2024.
FROM synapse_ce.apuk_caseinvestigation ci
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON ci.statecode = statecode.[State]
		AND statecode.[EntityName] = 'apuk_caseinvestigation'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON ci.statuscode = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_caseinvestigation'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optregtype
		ON ci.apuk_regardingtype = optregtype.[Option]
		AND optregtype.[OptionSetName] = 'apuk_regardingtype'
		AND optregtype.[EntityName] = 'apuk_caseinvestigation'
	LEFT JOIN synapse_ce.OptionSetMetadata optresolution
		ON ci.apuk_resolution = optresolution.[Option]
		AND optresolution.[OptionSetName] = 'apuk_resolution'
		AND optresolution.[EntityName] = 'apuk_caseinvestigation'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optstatus
		ON ci.apuk_status = optstatus.[Option]
		AND optstatus.[OptionSetName] = 'apuk_status'
		AND optstatus.[EntityName] = 'apuk_caseinvestigation'

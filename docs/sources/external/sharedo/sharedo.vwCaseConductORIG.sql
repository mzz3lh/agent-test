CREATE   VIEW [sharedo].[vwCaseConductORIG]
AS
SELECT
	cc.apuk_caseconductid
	,cc.apuk_areaofbreach
	,cc.apuk_areaofbreachname
	,cc.apuk_areaofbreach2
	,cc.apuk_areaofbreach2name
	,cc.apuk_areaofbreach3
	,cc.apuk_areaofbreach3name
	,cc.apuk_areaofpractice
	,cc.apuk_areaofpracticename
	,cc.apuk_caseclosed
	,optcaseclosed.LocalizedLabel as apuk_caseclosedname
	,cc.apuk_caseclosuredate
	,cc.apuk_caseclosuredatetime
	,cc.apuk_casedescription
	,cc.apuk_casestatus
	,optcasestatus.LocalizedLabel as apuk_casestatusname
	,cc.apuk_memberid
	,cc.apuk_memberidname
	,cc.apuk_regulatedfirmid
	,cc.apuk_regulatedfirmidname
	,cc.apuk_regulatedfirmidyominame
	,cc.apuk_type
	,opttype.LocalizedLabel as apuk_typename
	,cc.apuk_ruleofconduct2
	,cc.apuk_ruleofconduct2name
	,cc.apuk_name
	,cc.statecode
	,statecode.LocalizedLabel as statecodename	
	,cc.statuscode
	,statuscode.[LocalizedLabel] as statuscodename
	,cc.createdon
	,cc.createdby
	,cc.createdbyname
	,cc.createdbyyominame
	,cc.createdonbehalfby
	,cc.createdonbehalfbyname
	,cc.createdonbehalfbyyominame
	,cc.modifiedon
	,cc.modifiedby
	,cc.modifiedbyname
	,cc.modifiedbyyominame
	,cc.modifiedonbehalfby
	,cc.modifiedonbehalfbyname
	,cc.modifiedonbehalfbyyominame
	,cc.ownerid
	,cc.owneridname
	,cc.apuk_casereference  --added DBA/PS as per request Tom Bejan 07/08/2024.
FROM synapse_ce.apuk_caseconduct cc
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON cc.statecode = statecode.[State]
		AND statecode.[EntityName] = 'apuk_caseconduct'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON cc.statuscode = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_caseconduct'
	LEFT JOIN synapse_ce.OptionSetMetadata optcaseclosed
		ON cc.apuk_caseclosed = optcaseclosed.[Option]
		AND optcaseclosed.[OptionSetName] = 'apuk_caseclosed'
		AND optcaseclosed.[EntityName] = 'apuk_caseconduct'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optcasestatus
		ON cc.apuk_casestatus = optcasestatus.[Option]
		AND optcasestatus.[OptionSetName] = 'apuk_casestatus'
		AND optcasestatus.[EntityName] = 'apuk_caseconduct'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata opttype
		ON cc.apuk_type = opttype.[Option]
		AND opttype.[OptionSetName] = 'apuk_type'
		AND opttype.[EntityName] = 'apuk_caseconduct'

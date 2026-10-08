CREATE   VIEW [sharedo].[vwCaseAnnualReturnORIG]
AS
SELECT
	car.apuk_caseannualreturnid
	,car.[apuk_name]
	,car.apuk_areaofbreach
	,car.apuk_areaofbreach2
	,car.apuk_areaofbreach2name
	,car.apuk_areaofbreach3
	,car.apuk_areaofbreach3name
	,car.apuk_areaofbreachname
	,car.apuk_caseclosuredate
	,car.apuk_caseclosuredatetime
	,car.apuk_casedescription
	,car.apuk_casetype
	,optcasetype.LocalizedLabel as apuk_casetypename
	,car.apuk_outcome
	,optoutcome.LocalizedLabel as apuk_outcomename
	,car.apuk_regardingtype
	,optregtype.LocalizedLabel as apuk_regardingtypename
	,car.apuk_regulatedfirmid
	,car.apuk_regulatedfirmidname
	,car.apuk_regulatedfirmidyominame
	,car.apuk_regulatedindividualid
	,car.apuk_regulatedindividualidname
	,car.apuk_regulatedindividualidyominame
	,car.apuk_regulatedschemeid
	,car.apuk_regulatedschemeidname
	,car.apuk_ruleofconduct2
	,car.apuk_ruleofconduct2name
	,car.apuk_areaofpractice
	,car.apuk_areaofpracticename
	,car.apuk_regulatoryreturnid  --ADDED DBA/PS 11/04/2024
	,optcasestatus.LocalizedLabel as apuk_casestatusname  --ADDED DBA/PS 11/04/2024
	,car.statecode
	,statecode.LocalizedLabel as statecodename	
	,car.statuscode
	,statuscode.[LocalizedLabel] as statuscodename
	,car.createdon
	,car.createdby
	,car.createdbyname
	,car.createdbyyominame
	,car.createdonbehalfby
	,car.createdonbehalfbyname
	,car.createdonbehalfbyyominame
	,car.modifiedon
	,car.modifiedby
	,car.modifiedbyname
	,car.modifiedbyyominame
	,car.modifiedonbehalfby
	,car.modifiedonbehalfbyname
	,car.modifiedonbehalfbyyominame
	,car.ownerid
	,car.owneridname
FROM synapse_ce.apuk_caseannualreturn car
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON car.statecode = statecode.[State]
		AND statecode.[EntityName] = 'apuk_caseannualreturn'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON car.statuscode = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_caseannualreturn'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optcasetype
		ON car.apuk_casetype = optcasetype.[Option]
		AND optcasetype.[OptionSetName] = 'apuk_casetype'
		AND optcasetype.[EntityName] = 'apuk_caseannualreturn'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optoutcome
		ON car.apuk_outcome = optoutcome.[Option]
		AND optoutcome.[OptionSetName] = 'apuk_outcome'
		AND optoutcome.[EntityName] = 'apuk_caseannualreturn'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optregtype
		ON car.apuk_regardingtype = optregtype.[Option]
		AND optregtype.[OptionSetName] = 'apuk_regardingtype'
		AND optregtype.[EntityName] = 'apuk_caseannualreturn'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optcasestatus  --ADDED DBA/PS 11/04/2024
		ON car.apuk_casestatus = optcasestatus.[Option] 
		AND optcasestatus.[OptionSetName] = 'apuk_casestatus'
		AND optcasestatus.[EntityName] = 'apuk_caseannualreturn'

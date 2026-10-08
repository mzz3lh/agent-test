CREATE   VIEW [sharedo].[vwCaseComplianceORIG]
AS
SELECT
	cc.apuk_casecomplianceid
	,cc.apuk_areaofbreach
	,cc.apuk_areaofbreach2
	,cc.apuk_areaofbreach2name
	,cc.apuk_areaofbreach3
	,cc.apuk_areaofbreach3name
	,cc.apuk_areaofbreachname
	,cc.apuk_areaofpractice
	,cc.apuk_areaofpracticename
	,cc.apuk_arpdecision
	,optarp.LocalizedLabel as apuk_arpdecisionname
	,cc.apuk_casetype
	,optcasetype.LocalizedLabel as apuk_casetypename
	,cc.apuk_compliancecasereference
	,cc.apuk_dateclosed
	,cc.apuk_dateopened
	,cc.apuk_details
	,cc.apuk_dispensationoutcome
	,optdisp.LocalizedLabel as apuk_dispensationoutcomename
	,cc.apuk_outcome
	,optoutcome.LocalizedLabel as apuk_outcomename
	,cc.apuk_regardingtype
	,optregtype.LocalizedLabel as apuk_regardingtypename
	,cc.apuk_regulatedfirmid
	,cc.apuk_regulatedfirmidname
	,cc.apuk_regulatedfirmidyominame
	,cc.apuk_regulatedindividualid
	,cc.apuk_regulatedindividualidname
	,cc.apuk_regulatedindividualidyominame
	,cc.apuk_regulatorycontactid
	,cc.apuk_regulatorycontactidname
	,cc.apuk_regulatorycontactidyominame
	,cc.apuk_subject
	,cc.apuk_subjectname
	,cc.apuk_ruleofconduct2
	,cc.apuk_ruleofconduct2name

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
	,cc.apuk_name  --added DBA/PS as per request Tom Bejan 07/08/2024.
FROM synapse_ce.apuk_casecompliance cc
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON cc.statecode = statecode.[State]
		AND statecode.[EntityName] = 'apuk_casecompliance'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON cc.statuscode = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_casecompliance'
	LEFT JOIN synapse_ce.OptionSetMetadata optarp
		ON cc.apuk_arpdecision = optarp.[Option]
		AND optarp.[OptionSetName] = 'apuk_arpdecision'
		AND optarp.[EntityName] = 'apuk_casecompliance'
	LEFT JOIN synapse_ce.OptionSetMetadata optdisp
		ON cc.apuk_dispensationoutcome = optdisp.[Option]
		AND optdisp.[OptionSetName] = 'apuk_dispensationoutcome'
		AND optdisp.[EntityName] = 'apuk_casecompliance'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optoutcome
		ON cc.apuk_outcome = optoutcome.[Option]
		AND optoutcome.[OptionSetName] = 'apuk_outcome'
		AND optoutcome.[EntityName] = 'apuk_casecompliance'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optregtype
		ON cc.apuk_regardingtype = optregtype.[Option]
		AND optregtype.[OptionSetName] = 'apuk_regardingtype'
		AND optregtype.[EntityName] = 'apuk_casecompliance'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optcasetype
		ON cc.apuk_casetype = optcasetype.[Option]
		AND optcasetype.[OptionSetName] = 'apuk_casetype'
		AND optcasetype.[EntityName] = 'apuk_casecompliance'

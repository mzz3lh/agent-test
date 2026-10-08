CREATE   VIEW [sharedo].[vwCaseComplaintReportORIG]
AS
SELECT
	ccr.apuk_casecomplaintreportid
	,ccr.[apuk_name]
	,ccr.apuk_areaofbreach
	,ccr.apuk_areaofbreach2
	,ccr.apuk_areaofbreach2name
	,ccr.apuk_areaofbreach3
	,ccr.apuk_areaofbreach3name
	,ccr.apuk_areaofbreachname
	,ccr.apuk_areaofpractice
	,ccr.apuk_areaofpracticename
	,ccr.apuk_caseclosuredate
	,ccr.apuk_caseclosuredatetime
	,ccr.apuk_complainant
	,ccr.apuk_complainantname
	,ccr.apuk_complainantyominame
	,ccr.apuk_complaintcaseid
	,ccr.apuk_complaintid
	,ccr.apuk_detailsofthecomplaint
	,ccr.apuk_outcome
	,optoutcome.LocalizedLabel as apuk_outcomename
	,ccr.apuk_outcomereasontext
	,ccr.apuk_regardingtype
	,optregtype.LocalizedLabel As apuk_regardingtypename
	,ccr.apuk_regulatedfirmid
	,ccr.apuk_regulatedfirmidname
	,ccr.apuk_regulatedfirmidyominame
	,ccr.apuk_regulatedindividualid
	,ccr.apuk_regulatedindividualidname
	,ccr.apuk_regulatedindividualidyominame
	,ccr.apuk_ruleofconduct2
	,ccr.apuk_ruleofconduct2name
	,ccr.apuk_status
	,optstatus.LocalizedLabel as apuk_statusname
	,ccr.apuk_subject
	,ccr.apuk_subjectname

	,ccr.statecode
	,statecode.LocalizedLabel as statecodename	
	,ccr.statuscode
	,statuscode.[LocalizedLabel] as statuscodename
	,ccr.createdon
	,ccr.createdby
	,ccr.createdbyname
	,ccr.createdbyyominame
	,ccr.createdonbehalfby
	,ccr.createdonbehalfbyname
	,ccr.createdonbehalfbyyominame
	,ccr.modifiedon
	,ccr.modifiedby
	,ccr.modifiedbyname
	,ccr.modifiedbyyominame
	,ccr.modifiedonbehalfby
	,ccr.modifiedonbehalfbyname
	,ccr.modifiedonbehalfbyyominame
	,ccr.ownerid
	,ccr.owneridname
FROM synapse_ce.apuk_casecomplaintreport ccr
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON ccr.statecode = statecode.[State]
		AND statecode.[EntityName] = 'apuk_casecomplaintreport'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON ccr.statuscode = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_casecomplaintreport'
	LEFT JOIN synapse_ce.OptionSetMetadata optoutcome
		ON ccr.apuk_outcome = optoutcome.[Option]
		AND optoutcome.[OptionSetName] = 'apuk_outcome'
		AND optoutcome.[EntityName] = 'apuk_casecomplaintreport'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optregtype
		ON ccr.apuk_regardingtype = optregtype.[Option]
		AND optregtype.[OptionSetName] = 'apuk_regardingtype'
		AND optregtype.[EntityName] = 'apuk_casecomplaintreport'
	LEFT JOIN synapse_ce.OptionSetMetadata optstatus
		ON ccr.apuk_status = optstatus.[Option]
		AND optstatus.[OptionSetName] = 'apuk_status'
		AND optstatus.[EntityName] = 'apuk_casecomplaintreport'

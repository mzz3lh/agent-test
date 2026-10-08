CREATE   VIEW [sharedo].[vwCaseRegulatedSchemeRegistrationORIG]
AS
SELECT
	crsr.apuk_caseregulschemeregistrationid
	,crsr.apuk_areaofbreach
	,crsr.apuk_areaofbreach2
	,crsr.apuk_areaofbreach2name
	,crsr.apuk_areaofbreach3
	,crsr.apuk_areaofbreach3name
	,crsr.apuk_areaofbreachname
	,crsr.apuk_areaofpractice
	,crsr.apuk_areaofpracticename
	,crsr.apuk_caseclosuredate
	,crsr.apuk_caseclosuredatetime
	,crsr.apuk_casereference
	,crsr.apuk_casetype
	,optcasetype.LocalizedLabel as apuk_casetypename
	,crsr.apuk_description
	,crsr.apuk_details
	,crsr.apuk_firmid
	,crsr.apuk_firmidname
	,crsr.apuk_firmidyominame
	,crsr.apuk_memberid
	,crsr.apuk_memberidname
	,crsr.apuk_memberidyominame
	,crsr.apuk_regardingtype
	,optregtype.LocalizedLabel as apuk_regardingtypename
	,crsr.apuk_ruleofconduct2
	,crsr.apuk_ruleofconduct2name
	,crsr.apuk_status
	,optstatus.LocalizedLabel as apuk_statusname

	,crsr.statecode
	,statecode.LocalizedLabel as statecodename	
	,crsr.statuscode
	,statuscode.[LocalizedLabel] as statuscodename
	,crsr.createdon
	,crsr.createdby
	,crsr.createdbyname
	,crsr.createdbyyominame
	,crsr.createdonbehalfby
	,crsr.createdonbehalfbyname
	,crsr.createdonbehalfbyyominame
	,crsr.modifiedon
	,crsr.modifiedby
	,crsr.modifiedbyname
	,crsr.modifiedbyyominame
	,crsr.modifiedonbehalfby
	,crsr.modifiedonbehalfbyname
	,crsr.modifiedonbehalfbyyominame
	,crsr.ownerid
	,crsr.owneridname
	,crsr.apuk_name  --added DBA/PS as per request Tom Bejan 07/08/2024.
FROM synapse_ce.apuk_caseregulschemeregistration crsr
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON crsr.statecode = statecode.[State]
		AND statecode.[EntityName] = 'apuk_caseregulschemeregistration'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON crsr.statuscode = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_caseregulschemeregistration'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optcasetype
		ON crsr.apuk_casetype = optcasetype.[Option]
		AND optcasetype.[OptionSetName] = 'apuk_casetype'
		AND optcasetype.[EntityName] = 'apuk_caseregulschemeregistration'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optregtype
		ON crsr.apuk_regardingtype = optregtype.[Option]
		AND optregtype.[OptionSetName] = 'apuk_regardingtype'
		AND optregtype.[EntityName] = 'apuk_caseregulschemeregistration'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optstatus
		ON crsr.apuk_status = optstatus.[Option]
		AND optstatus.[OptionSetName] = 'apuk_status'
		AND optstatus.[EntityName] = 'apuk_caseregulschemeregistration'

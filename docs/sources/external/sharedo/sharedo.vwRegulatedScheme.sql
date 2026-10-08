CREATE   VIEW [sharedo].[vwRegulatedScheme]
AS
SELECT
	sch.apuk_regulatedschemeid
	,sch.apuk_regulatedschemenumber
	,sch.apuk_licensedfirmid
	,sch.apuk_licensedfirmidname
	,sch.apuk_regulatedindividualid
	,sch.apuk_regulatedindividualidname
	,sch.apuk_regulatedschemetypeid
	,sch.apuk_regulatedschemetypeidname
	,sch.apuk_approvaldate
	,sch.apuk_approvalconditions
	,sch.apuk_schemeenddate
	,sch.apuk_licenceendreason
	,optlicenceendreason.LocalizedLabel as apuk_licenceendreasonname
	,sch.apuk_inclusionreason
	,optinclreason.LocalizedLabel as apuk_inclusionreasonname

	,sch.statecode
	,statecode.LocalizedLabel as statecodename	
	,sch.statuscode
	,statuscode.[LocalizedLabel] as statuscodename
	,sch.createdon
	,sch.createdby
	,sch.createdbyname
	,sch.createdbyyominame
	,sch.createdonbehalfby
	,sch.createdonbehalfbyname
	,sch.createdonbehalfbyyominame
	,sch.modifiedon
	,sch.modifiedby
	,sch.modifiedbyname
	,sch.modifiedbyyominame
	,sch.modifiedonbehalfby
	,sch.modifiedonbehalfbyname
	,sch.modifiedonbehalfbyyominame
	,sch.ownerid
	,sch.owneridname
FROM synapse_ce.apuk_regulatedscheme sch
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON sch.statecode = statecode.[State]
		AND statecode.[EntityName] = 'apuk_regulatedscheme'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON sch.statuscode = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_regulatedscheme'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optlicenceendreason
		ON sch.apuk_licenceendreason = optlicenceendreason.[Option]
		AND optlicenceendreason.[OptionSetName] = 'apuk_licenceendreason'
		AND optlicenceendreason.[EntityName] = 'apuk_regulatedscheme'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optinclreason
		ON sch.apuk_inclusionreason = optinclreason.[Option]
		AND optinclreason.[OptionSetName] = 'apuk_inclusionreason'
		AND optinclreason.[EntityName] = 'apuk_regulatedscheme'

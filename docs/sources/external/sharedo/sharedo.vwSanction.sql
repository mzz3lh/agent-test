CREATE   VIEW [sharedo].[vwSanction]
AS
SELECT
	sc.apuk_sanctionid
	,sc.apuk_appealdate
	,sc.apuk_appealed
	,optappealed.LocalizedLabel as apuk_appealedname
	,sc.apuk_appealoutcome
	,optappealoutcome.LocalizedLabel as apuk_appealoutcomename
	,sc.apuk_appealstatus
	,optappealstatus.LocalizedLabel as apuk_appealstatusname
	,sc.apuk_fineamount
	,sc.apuk_fineamount_base
	,sc.apuk_fineincluded
	,optfine.LocalizedLabel as apuk_fineincludedname
	,sc.apuk_name
	,sc.apuk_sanctiondetails
	,sc.apuk_sanctionidnumber
	,sc.apuk_sanctiontype
	,optsanctiontype.LocalizedLabel as apuk_sanctiontypename

	,sc.statecode
	,statecode.LocalizedLabel as statecodename	
	,sc.statuscode
	,statuscode.[LocalizedLabel] as statuscodename
	,sc.createdon
	,sc.createdby
	,sc.createdbyname
	,sc.createdbyyominame
	,sc.createdonbehalfby
	,sc.createdonbehalfbyname
	,sc.createdonbehalfbyyominame
	,sc.modifiedon
	,sc.modifiedby
	,sc.modifiedbyname
	,sc.modifiedbyyominame
	,sc.modifiedonbehalfby
	,sc.modifiedonbehalfbyname
	,sc.modifiedonbehalfbyyominame
	,sc.ownerid
	,sc.owneridname
FROM synapse_ce.apuk_sanction sc
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON sc.statecode = statecode.[State]
		AND statecode.[EntityName] = 'apuk_sanction'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON sc.statuscode = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_sanction'
	LEFT JOIN synapse_ce.OptionSetMetadata optappealed
		ON sc.apuk_appealed = optappealed.[Option]
		AND optappealed.[OptionSetName] = 'apuk_appealed'
		AND optappealed.[EntityName] = 'apuk_sanction'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optappealoutcome
		ON sc.apuk_appealoutcome = optappealoutcome.[Option]
		AND optappealoutcome.[OptionSetName] = 'apuk_appealoutcome'
		AND optappealoutcome.[EntityName] = 'apuk_sanction'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optappealstatus
		ON sc.apuk_appealstatus = optappealstatus.[Option]
		AND optappealstatus.[OptionSetName] = 'apuk_appealstatus'
		AND optappealstatus.[EntityName] = 'apuk_sanction'
	LEFT JOIN synapse_ce.OptionSetMetadata optfine
		ON sc.apuk_fineincluded = optfine.[Option]
		AND optfine.[OptionSetName] = 'apuk_fineincluded'
		AND optfine.[EntityName] = 'apuk_sanction'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optsanctiontype
		ON sc.apuk_sanctiontype = optsanctiontype.[Option]
		AND optsanctiontype.[OptionSetName] = 'apuk_sanctiontype'
		AND optsanctiontype.[EntityName] = 'apuk_sanction'

CREATE   VIEW [sharedo].[vwRegulatoryReturn]
AS
SELECT
	rr.apuk_regulatoryreturnid
	,rr.apuk_caseannualreturnid
	,rr.apuk_caseannualreturnidname
	,rr.apuk_caseregulatedschemeregistrationid
	,rr.apuk_caseregulatedschemeregistrationidname
	,rr.apuk_extendedsubmissiondate
	,rr.apuk_regulatedfirmid
	,rr.apuk_regulatedfirmidname
	,rr.apuk_regulatedfirmidyominame
	,rr.apuk_regulatedmemberid
	,rr.apuk_regulatedmemberidname
	,rr.apuk_regulatedmemberidyominame
	,rr.apuk_regulatedschemeid
	,rr.apuk_regulatedschemeidname
	,rr.apuk_regulationtype
	,optregtype.LocalizedLabel as apuk_regulationtypename
	,rr.apuk_returnduedate
	,rr.apuk_returnstatus
	,optretstatus.LocalizedLabel as apuk_returnstatusname
	,rr.apuk_returntype
	,rr.apuk_returntypename
	,rr.apuk_submitteddate

	,rr.statecode
	,statecode.LocalizedLabel as statecodename	
	,rr.statuscode
	,statuscode.[LocalizedLabel] as statuscodename
	,rr.createdon
	,rr.createdby
	,rr.createdbyname
	,rr.createdbyyominame
	,rr.createdonbehalfby
	,rr.createdonbehalfbyname
	,rr.createdonbehalfbyyominame
	,rr.modifiedon
	,rr.modifiedby
	,rr.modifiedbyname
	,rr.modifiedbyyominame
	,rr.modifiedonbehalfby
	,rr.modifiedonbehalfbyname
	,rr.modifiedonbehalfbyyominame
	,rr.ownerid
	,rr.owneridname
FROM synapse_ce.apuk_regulatoryreturn rr
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON rr.statecode = statecode.[State]
		AND statecode.[EntityName] = 'apuk_regulatoryreturn'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON rr.statuscode = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_regulatoryreturn'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optregtype
		ON rr.apuk_regulationtype = optregtype.[Option]
		AND optregtype.[OptionSetName] = 'apuk_regulationtype'
		AND optregtype.[EntityName] = 'apuk_regulatoryreturn'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optretstatus
		ON rr.apuk_returnstatus = optretstatus.[Option]
		AND optretstatus.[OptionSetName] = 'apuk_returnstatus'
		AND optretstatus.[EntityName] = 'apuk_regulatoryreturn'

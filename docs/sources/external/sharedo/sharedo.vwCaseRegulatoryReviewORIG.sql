CREATE   VIEW [sharedo].[vwCaseRegulatoryReviewORIG]
AS
SELECT
	rr.apuk_caseregulatoryauditid
	,rr.apuk_auditcompletedon
	,rr.apuk_auditreference
	,rr.apuk_auditreportgrade
	,optrepgrade.LocalizedLabel as apuk_auditreportgradename
	,rr.apuk_primarysubject
	,rr.apuk_primarysubjectname 
	,rr.apuk_primarysubjectarea
	,optsubjectarea.LocalizedLabel as apuk_primarysubjectareaname
	,rr.apuk_regulatedfirmid
	,rr.apuk_regulatedfirmidname
	,rr.apuk_regulatedfirmidyominame
	,rr.apuk_regulatedindividualid
	,rr.apuk_regulatedindividualidname
	,rr.apuk_regulatedindividualidyominame
	,rr.apuk_confirmeddate --ADDED DBA/PS 11/04/2024
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
FROM synapse_ce.apuk_caseregulatoryaudit rr
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON rr.statecode = statecode.[State]
		AND statecode.[EntityName] = 'apuk_caseregulatoryaudit'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON rr.statuscode = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_caseregulatoryaudit'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optsubjectarea
		ON rr.apuk_primarysubjectarea = optsubjectarea.[Option]
		AND optsubjectarea.[OptionSetName] = 'apuk_primarysubjectarea'
		AND optsubjectarea.[EntityName] = 'apuk_caseregulatoryaudit'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optrepgrade
		ON rr.apuk_auditreportgrade = optrepgrade.[Option]
		AND optrepgrade.[OptionSetName] = 'apuk_auditreportgrade'
		AND optrepgrade.[EntityName] = 'apuk_caseregulatoryaudit'

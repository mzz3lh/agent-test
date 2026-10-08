CREATE   VIEW [sharedo].[vwCaseFitAndProperORIG]
AS
SELECT
	cfp.apuk_casefitandproperid
	,cfp.apuk_description
	,cfp.apuk_memberid
	,cfp.apuk_memberidname
	,cfp.apuk_memberidyominame
	,cfp.apuk_name
	,cfp.apuk_outcome
	,optoutcome.LocalizedLabel as apuk_outcomename
	,cfp.apuk_subject
	,cfp.apuk_subjectname

	,cfp.statecode
	,statecode.LocalizedLabel as statecodename	
	,cfp.statuscode
	,statuscode.[LocalizedLabel] as statuscodename
	,cfp.createdon
	,cfp.createdby
	,cfp.createdbyname
	,cfp.createdbyyominame
	,cfp.createdonbehalfby
	,cfp.createdonbehalfbyname
	,cfp.createdonbehalfbyyominame
	,cfp.modifiedon
	,cfp.modifiedby
	,cfp.modifiedbyname
	,cfp.modifiedbyyominame
	,cfp.modifiedonbehalfby
	,cfp.modifiedonbehalfbyname
	,cfp.modifiedonbehalfbyyominame
	,cfp.ownerid
	,cfp.owneridname
FROM synapse_ce.apuk_casefitandproper cfp
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON cfp.statecode = statecode.[State]
		AND statecode.[EntityName] = 'apuk_casefitandproper'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON cfp.statuscode = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_casefitandproper'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optoutcome
		ON cfp.apuk_outcome = optoutcome.[Option]
		AND optoutcome.[OptionSetName] = 'apuk_outcome'
		AND optoutcome.[EntityName] = 'apuk_casefitandproper'

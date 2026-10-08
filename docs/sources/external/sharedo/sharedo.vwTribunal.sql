CREATE   VIEW [sharedo].[vwTribunal]
AS
SELECT
	tr.apuk_tribunalid
	,tr.apuk_tribunaltype
	,opttribunaltype.LocalizedLabel as apuk_tribunaltypename
	,tr.apuk_regardingpartyid
	,tr.apuk_regardingpartyidname
	,tr.apuk_regardingfirmid
	,tr.apuk_regardingfirmidname
	,tr.apuk_conductcaseid
	,tr.apuk_conductcaseidname
	,tr.apuk_startdate
	,tr.apuk_enddate
	,tr.apuk_fproutcome
	,optfproutcome.LocalizedLabel as apuk_fproutcomename 
	,tr.apuk_interimmeasuresdecision
	,optintermeasure.LocalizedLabel as apuk_interimmeasuresdecisionname
	,tr.apuk_disciplinarydecision
	,optdiscdecission.LocalizedLabel as apuk_disciplinarydecisionname
	,tr.apuk_registrationdecision
	,optregdecission.LocalizedLabel as apuk_registrationdecisionname
	,tr.apuk_appealdecision
	,optappdecission.LocalizedLabel as apuk_appealdecisionname
	,tr.apuk_sdmdecision
	,optsdmdecission.LocalizedLabel as apuk_sdmdecisionname 
	,tr.apuk_appealed
	,optappealed.LocalizedLabel as apuk_appealedname

	,tr.statecode
	,statecode.LocalizedLabel as statecodename	
	,tr.statuscode
	,statuscode.[LocalizedLabel] as statuscodename
	,tr.createdon
	,tr.createdby
	,tr.createdbyname
	,tr.createdbyyominame
	,tr.createdonbehalfby
	,tr.createdonbehalfbyname
	,tr.createdonbehalfbyyominame
	,tr.modifiedon
	,tr.modifiedby
	,tr.modifiedbyname
	,tr.modifiedbyyominame
	,tr.modifiedonbehalfby
	,tr.modifiedonbehalfbyname
	,tr.modifiedonbehalfbyyominame
	,tr.ownerid
	,tr.owneridname
FROM synapse_ce.apuk_tribunal tr
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON tr.statecode = statecode.[State]
		AND statecode.[EntityName] = 'apuk_tribunal'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON tr.statuscode = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_tribunal'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata opttribunaltype
		ON tr.apuk_tribunaltype = opttribunaltype.[Option]
		AND opttribunaltype.[OptionSetName] = 'apuk_tribunaltype'
		AND opttribunaltype.[EntityName] = 'apuk_tribunal'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optfproutcome
		ON tr.apuk_fproutcome = optfproutcome.[Option]
		AND optfproutcome.[OptionSetName] = 'apuk_fproutcome'
		AND optfproutcome.[EntityName] = 'apuk_tribunal'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optintermeasure
		ON tr.apuk_interimmeasuresdecision = optintermeasure.[Option]
		AND optintermeasure.[OptionSetName] = 'apuk_interimmeasuresdecision'
		AND optintermeasure.[EntityName] = 'apuk_tribunal'
	LEFT JOIN synapse_ce.OptionSetMetadata optdiscdecission
		ON tr.apuk_disciplinarydecision = optdiscdecission.[Option]
		AND optdiscdecission.[OptionSetName] = 'apuk_disciplinarydecision'
		AND optdiscdecission.[EntityName] = 'apuk_tribunal'
	LEFT JOIN synapse_ce.OptionSetMetadata optregdecission
		ON tr.apuk_registrationdecision = optregdecission.[Option]
		AND optregdecission.[OptionSetName] = 'apuk_registrationdecision'
		AND optregdecission.[EntityName] = 'apuk_tribunal'
	LEFT JOIN synapse_ce.OptionSetMetadata optappdecission
		ON tr.apuk_appealdecision = optappdecission.[Option]
		AND optappdecission.[OptionSetName] = 'apuk_appealdecision'
		AND optappdecission.[EntityName] = 'apuk_tribunal'
	LEFT JOIN synapse_ce.OptionSetMetadata optsdmdecission
		ON tr.apuk_sdmdecision = optsdmdecission.[Option]
		AND optsdmdecission.[OptionSetName] = 'apuk_sdmdecision'
		AND optsdmdecission.[EntityName] = 'apuk_tribunal'
	LEFT JOIN synapse_ce.OptionSetMetadata optappealed
		ON tr.apuk_appealed = optappealed.[Option]
		AND optappealed.[OptionSetName] = 'apuk_appealed'
		AND optappealed.[EntityName] = 'apuk_tribunal'

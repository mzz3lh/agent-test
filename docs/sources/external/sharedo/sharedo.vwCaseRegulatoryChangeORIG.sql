CREATE   VIEW [sharedo].[vwCaseRegulatoryChangeORIG]
AS
SELECT
	crc.apuk_caseregulatorychangeid
	,crc.apuk_areaofbreach
	,crc.apuk_areaofbreach2
	,crc.apuk_areaofbreach2name
	,crc.apuk_areaofbreach3
	,crc.apuk_areaofbreach3name
	,crc.apuk_areaofbreachname
	,crc.apuk_caseclosuredate
	,crc.apuk_description
	,crc.apuk_regardingtype
	,optregtype.LocalizedLabel as apuk_regardingtypename
	,crc.apuk_regulatedfirm
	,crc.apuk_regulatedfirmname
	,crc.apuk_regulatedfirmyominame
	,crc.apuk_regulatedindividual
	,crc.apuk_regulatedindividualname
	,crc.apuk_regulatedindividualyominame
	,crc.apuk_ruleofconduct2
	,crc.apuk_ruleofconduct2name
	,crc.apuk_status
	,optstatus.LocalizedLabel as apuk_statusname
	,crc.apuk_subject
	,crc.apuk_subjectname

	,crc.statecode
	,statecode.LocalizedLabel as statecodename	
	,crc.statuscode
	,statuscode.[LocalizedLabel] as statuscodename
	,crc.createdon
	,crc.createdby
	,crc.createdbyname
	,crc.createdbyyominame
	,crc.createdonbehalfby
	,crc.createdonbehalfbyname
	,crc.createdonbehalfbyyominame
	,crc.modifiedon
	,crc.modifiedby
	,crc.modifiedbyname
	,crc.modifiedbyyominame
	,crc.modifiedonbehalfby
	,crc.modifiedonbehalfbyname
	,crc.modifiedonbehalfbyyominame
	,crc.ownerid
	,crc.owneridname
	,crc.apuk_name  --added DBA/PS as per request Tom Bejan 07/08/2024.
FROM synapse_ce.apuk_caseregulatorychange crc
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON crc.statecode = statecode.[State]
		AND statecode.[EntityName] = 'apuk_caseregulatorychange'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON crc.statuscode = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_caseregulatorychange'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optregtype
		ON crc.apuk_regardingtype = optregtype.[Option]
		AND optregtype.[OptionSetName] = 'apuk_regardingtype'
		AND optregtype.[EntityName] = 'apuk_caseregulatorychange'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optstatus
		ON crc.apuk_status = optstatus.[Option]
		AND optstatus.[OptionSetName] = 'apuk_status'
		AND optstatus.[EntityName] = 'apuk_caseregulatorychange'

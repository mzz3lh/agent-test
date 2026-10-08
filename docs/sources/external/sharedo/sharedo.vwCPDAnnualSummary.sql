CREATE   VIEW [sharedo].[vwCPDAnnualSummary]
AS
SELECT
	cas.apuk_cpdannualsummaryid
	,cas.apuk_contactid
	,cas.apuk_contactidname
	,cas.apuk_contactidyominame
	,cas.apuk_cpdcomplete
	,optcpdcomplete.LocalizedLabel as apuk_cpdcompletename
	,cas.apuk_cpdcompletiondate
	,cas.apuk_cpdrecordingoutcome
	,optcpdrecoutcome.LocalizedLabel as apuk_cpdrecordingoutcomename
	,cas.apuk_cpdrecordingstatus
	,optcpdrecstatus.LocalizedLabel as apuk_cpdrecordingstatusname
	,cas.apuk_cpdyear
	,optcpdyear.LocalizedLabel as apuk_cpdyearname
	,cas.statecode
	,statecode.LocalizedLabel as statecodename	
	,cas.statuscode
	,statuscode.[LocalizedLabel] as statuscodename
	,cas.createdon
	,cas.createdby
	,cas.createdbyname
	,cas.createdbyyominame
	,cas.createdonbehalfby
	,cas.createdonbehalfbyname
	,cas.createdonbehalfbyyominame
	,cas.modifiedon
	,cas.modifiedby
	,cas.modifiedbyname
	,cas.modifiedbyyominame
	,cas.modifiedonbehalfby
	,cas.modifiedonbehalfbyname
	,cas.modifiedonbehalfbyyominame
	,cas.ownerid
	,cas.owneridname
FROM synapse_ce.apuk_cpdannualsummary cas
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON cas.statecode = statecode.[State]
		AND statecode.[EntityName] = 'apuk_cpdannualsummary'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON cas.statuscode = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_cpdannualsummary'
	LEFT JOIN synapse_ce.OptionSetMetadata optcpdcomplete
		ON cas.apuk_cpdcomplete = optcpdcomplete.[Option]
		AND optcpdcomplete.[OptionSetName] = 'apuk_cpdcomplete'
		AND optcpdcomplete.[EntityName] = 'apuk_cpdannualsummary'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optcpdrecoutcome
		ON cas.apuk_cpdrecordingoutcome = optcpdrecoutcome.[Option]
		AND optcpdrecoutcome.[OptionSetName] = 'apuk_cpdrecordingoutcome'
		AND optcpdrecoutcome.[EntityName] = 'apuk_cpdannualsummary'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optcpdrecstatus
		ON cas.apuk_cpdrecordingstatus = optcpdrecstatus.[Option]
		AND optcpdrecstatus.[OptionSetName] = 'apuk_cpdrecordingstatus'
		AND optcpdrecstatus.[EntityName] = 'apuk_cpdannualsummary'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optcpdyear
		ON cas.apuk_cpdyear = optcpdyear.[Option]
		AND optcpdyear.[OptionSetName] = 'apuk_cpdyear'
		AND optcpdyear.[EntityName] = 'apuk_cpdannualsummary'

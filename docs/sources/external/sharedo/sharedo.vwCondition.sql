CREATE   VIEW [sharedo].[vwCondition]
AS
SELECT
	c.apuk_conditionid	
	,c.apuk_actualcompliancedate
	,c.apuk_compliancecase
	,c.apuk_compliancecasename
	,c.apuk_compliancerequiredby
	,c.apuk_conditiondetails
	,c.apuk_conditionexpirydate
	,c.apuk_conditiontype
	,optcondtype.LocalizedLabel as apuk_conditiontypename
	,c.apuk_datetermadded
	,c.apuk_failuretocomplyaction
	,optfailuretocomply.LocalizedLabel as apuk_failuretocomplyactionname
	,c.apuk_memberid
	,c.apuk_memberidname
	,c.apuk_memberidyominame
	,c.apuk_name
	,c.apuk_regardingtype
	,optregtype.LocalizedLabel as apuk_regardingtypename
	,c.apuk_regulatedfirm
	,c.apuk_regulatedfirmname
	,c.apuk_regulatedfirmyominame
	,c.apuk_termstatus
	,opttermstatus.LocalizedLabel as apuk_termstatusname

	,c.statecode
	,statecode.LocalizedLabel as statecodename	
	,c.statuscode
	,statuscode.[LocalizedLabel] as statuscodename
	,c.createdon
	,c.createdby
	,c.createdbyname
	,c.createdbyyominame
	,c.createdonbehalfby
	,c.createdonbehalfbyname
	,c.createdonbehalfbyyominame
	,c.modifiedon
	,c.modifiedby
	,c.modifiedbyname
	,c.modifiedbyyominame
	,c.modifiedonbehalfby
	,c.modifiedonbehalfbyname
	,c.modifiedonbehalfbyyominame
	,c.ownerid
	,c.owneridname
FROM synapse_ce.apuk_condition c
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON c.statecode = statecode.[State]
		AND statecode.[EntityName] = 'apuk_condition'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON c.statuscode = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_condition'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optcondtype
		ON c.apuk_conditiontype = optcondtype.[Option]
		AND optcondtype.[OptionSetName] = 'apuk_conditiontype'
		AND optcondtype.[EntityName] = 'apuk_condition'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optfailuretocomply
		ON c.apuk_failuretocomplyaction = optfailuretocomply.[Option]
		AND optfailuretocomply.[OptionSetName] = 'apuk_failuretocomplyaction'
		AND optfailuretocomply.[EntityName] = 'apuk_condition'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optregtype
		ON c.apuk_regardingtype = optregtype.[Option]
		AND optregtype.[OptionSetName] = 'apuk_regardingtype'
		AND optregtype.[EntityName] = 'apuk_condition'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata opttermstatus
		ON c.apuk_termstatus = opttermstatus.[Option]
		AND opttermstatus.[OptionSetName] = 'apuk_termstatus'
		AND opttermstatus.[EntityName] = 'apuk_condition'

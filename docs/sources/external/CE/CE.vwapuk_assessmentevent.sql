CREATE   VIEW [CE].[vwapuk_assessmentevent]
AS
SELECT
	assess.[apuk_assessmenteventid],
	assess.[apuk_name],
	assess.[createdon],
	assess.[createdby],
	usrcreatedby.[FullName] AS [createdbyName],
	assess.[modifiedon],
	assess.[modifiedby],
	usrmodifiedby.[FullName] AS [modifiedbyName],
	assess.[apuk_assessmentvenue],
	assess.[apuk_assessmentvenueName],
	assess.[apuk_assessmentapplicationwindowid],
	assess.[apuk_assessmentapplicationwindowidName],
	assess.[apuk_locationid],
	assess.[apuk_locationidName],
	assess.[apuk_applicationtype],
	appltype.[LocalizedLabel] AS [apuk_applicationtype_description],
	assess.[apuk_applicationtypeid],
	assess.[apuk_applicationtypeidName],
	assess.[apuk_electiondate],
	assess.[apuk_dayonedate],
	assess.[apuk_daytwodate],
	assess.[apuk_daythreedate],
	assess.[apuk_dayfourdate],
	assess.[apuk_dayfivedate],
	assess.[apuk_daysixdate],
	assess.[apuk_firstchoicestartedon],
	assess.[apuk_firstchoicecompletedon],
	assess.[apuk_secondchoicestartedon],
	assess.[apuk_secondchoicecompletedon],
	assess.[apuk_thirdchoicestartedon],
	assess.[apuk_thirdchoicecompletedon],
	assess.[apuk_noofrooms1],
	assess.[apuk_noofrooms2],
	assess.[apuk_noofrooms3],
	assess.[apuk_noofrooms4],
	assess.[apuk_noofrooms5],
	assess.[apuk_noofrooms6],
	assess.[organizationid],
	assess.[organizationidname],
	assess.[createdonbehalfby],
	usrcreatedonbehalfby.[FullName] AS [createdonbehalfbyName],
	assess.[modifiedonbehalfby],
	usrmodifiedonbehalfby.[FullName] AS [modifiedonbehalfbyName],
	assess.[statecode],
	stStateCode.[LocalizedLabel] AS [statecode_description],
	assess.[statuscode],
	stStatusCode.[LocalizedLabel] AS [statuscode_description]
FROM [synapse_ce].[vwapuk_assessmentevent] assess
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON assess.statecode = stStateCode.State
		AND stStateCode.EntityName = 'apuk_assessmentevent'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON assess.statuscode = stStatusCode.Status
		AND stStatusCode.EntityName = 'apuk_assessmentevent'
	LEFT JOIN synapse_ce.OptionSetMetadata appltype
		ON assess.apuk_applicationtype = appltype.[Option]
		AND appltype.OptionSetName = 'apuk_applicationtype'
	LEFT JOIN synapse_ce.SystemUser usrcreatedby
		ON assess.[createdby] = usrcreatedby.[SystemUserId]
	LEFT JOIN synapse_ce.SystemUser usrmodifiedby
		ON assess.[modifiedby] = usrmodifiedby.[SystemUserId]
	LEFT JOIN synapse_ce.SystemUser usrcreatedonbehalfby
		ON assess.[createdonbehalfby] = usrcreatedonbehalfby.[SystemUserId]
	LEFT JOIN synapse_ce.SystemUser usrmodifiedonbehalfby
		ON assess.[modifiedonbehalfby] = usrmodifiedonbehalfby.[SystemUserId]

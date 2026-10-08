CREATE   VIEW [synapse_ce].[vwapuk_assessmentevent]
AS
SELECT 
	assess.[apuk_assessmenteventid],
	assess.[apuk_name],
	assess.[createdon],
	assess.[createdby],
	assess.[modifiedon],
	assess.[modifiedby],
	assess.[apuk_assessmentvenue],
	ven.[apuk_name] AS [apuk_assessmentvenueName],
	assess.[apuk_assessmentapplicationwindowid],
	wdw.[apuk_name] AS  [apuk_assessmentapplicationwindowidName],
	assess.[apuk_locationid],
	loc.[apuk_name] AS [apuk_locationidName],
	assess.[apuk_applicationtype],
	assess.[apuk_applicationtypeid],
	aptype.[apuk_name] AS [apuk_applicationtypeidName],
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
	org.[name] AS [organizationidname],
	assess.[createdonbehalfby],
	assess.[modifiedonbehalfby],
	assess.[statecode],
	assess.[statuscode]
FROM synapse_ce.apuk_assessmentevent assess
	LEFT JOIN synapse_ce.apuk_applicationtype aptype
		ON assess.[apuk_applicationtypeid] = aptype.[apuk_applicationtypeid]
	LEFT JOIN synapse_ce.apuk_location loc
		ON assess.apuk_locationid = loc.apuk_locationid
	LEFT JOIN synapse_ce.apuk_assessmentvenue ven
		ON assess.[apuk_assessmentvenue] = ven.[apuk_assessmentvenueid]
	LEFT JOIN synapse_ce.apuk_assessmentapplicationwindow wdw
		ON assess.[apuk_assessmentapplicationwindowid] = wdw.[apuk_assessmentapplicationwindowid]
	LEFT JOIN synapse_ce.organization org
		ON assess.[organizationid] = org.[organizationid]

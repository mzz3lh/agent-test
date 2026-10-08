CREATE   VIEW [RegsBI].[vwRICS_SurveyRequest_CE]
AS

SELECT 
	[rics_surveyrequestid],
	[rics_name],
	[rics_surveyresponse],
	[createdon],
	[createdby],
	[CreatedByName],
	[modifiedon],
	[modifiedby],
	[ModifiedByName],
	[ownerid],
	[OwnerIdName],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description]
FROM synapse_ce.vwRICS_SurveyRequest

CREATE   VIEW [CE].[vwCounsellorRelationship]
AS
SELECT
	[apuk_counsellorrelationshipid],
	[apuk_name],
	[createdon],
	[createdby],
	[CreatedByName],
	[modifiedon],
	[modifiedby],
	[ModifiedByName],
	[ownerid],
	[OwnerIdName],
	[apuk_counsellorid],
	[apuk_enrolmentid],
	[apuk_contactid],
	[apuk_startdate],
	[apuk_enddate],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description],
	[apuk_counsellormembernumber]
FROM [synapse_ce].[vwCounsellorRelationship]

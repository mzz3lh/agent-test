CREATE   VIEW [CE].[vwRics_assessoravailability]
AS 
SELECT 
	[Rics_assessoravailabilityId],
	[Rics_name],
	[rics_assessorid],
	[rics_sessionid],
	[rics_sessionidname],
	[OrganizationId],
	[Rics_DateOne],
	[Created_On],
	[CreatedBy],
	[CreatedByName],
	[Modified_On],
	[ModifiedBy],
	[ModifiedByName],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description],
	[apuk_enddate],
	[apuk_availabilityhours],
	[apuk_availabilityhours_Description],
	[apuk_maximumnumberofdays],
	[apuk_availabilitytype]
FROM [synapse_ce].[vwRics_assessoravailability]

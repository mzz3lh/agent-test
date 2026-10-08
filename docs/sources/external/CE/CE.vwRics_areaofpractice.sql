CREATE   VIEW [CE].[vwRics_areaofpractice]
AS 
SELECT 
	[Rics_areaofpracticeId],
	[Rics_name],
	[OrganizationId],
	[Created_On],
	[CreatedBy],
	[CreatedByName],
	[Modified_On],
	[ModifiedBy],
	[ModifiedByName],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description]
FROM [synapse_ce].[vwRics_areaofpractice]

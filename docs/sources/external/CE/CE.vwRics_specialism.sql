CREATE   VIEW [CE].[vwRics_specialism]
AS 
SELECT 
	[Rics_specialismId],
	[Rics_name],
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
FROM [synapse_ce].[vwRics_specialism]

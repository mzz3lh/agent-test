CREATE   VIEW [CE].[vwRics_Centre]
AS 
SELECT 
	[Rics_centreId],
	[Rics_name],
	[rics_venueid],
	[rics_venueidName],
	[Rics_Description],
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
	[ricsv2_ApplicationType],
	[ricsv2_ApplicationType_Description]
FROM [synapse_ce].[vwRics_Centre]

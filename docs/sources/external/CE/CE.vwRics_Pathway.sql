CREATE   VIEW [CE].[vwRics_Pathway]
AS 
SELECT 
	[Rics_pathwayId],
	[Rics_Code],
	[Rics_name],
	[Rics_PathwayGroup],
	[Rics_PathwayGroup_Description],
	[Rics_ProfessionalGroupId],
	[Rics_ProfessionalGroupIdName],
	[Created_On],
	[CreatedBy],
	[CreatedByName],
	[Modified_On],
	[ModifiedBy],
	[ModifiedByName],
	[Statecode],
	[StateCode_Description],
	[Statuscode],
	[StatusCode_Description]
FROM [synapse_ce].[vwRics_Pathway]

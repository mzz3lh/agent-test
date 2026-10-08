CREATE VIEW [dbo].[vwRics_pathway]
AS
SELECT
	[Rics_pathwayId],
	[Rics_Code],
	[Rics_name],
	[Rics_PathwayGroup],
	[Rics_ProfessionalGroupId],
	[Created_On],
	[CreatedBy],
	[CreatedByName],
	[Modified_On],
	[ModifiedBy],
	[ModifiedByName],
	[OwnerId],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description]
FROM [Ext].[PBI02_CRM_vwRics_pathway]

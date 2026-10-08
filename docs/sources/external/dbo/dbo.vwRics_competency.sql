CREATE VIEW [dbo].[vwRics_competency]
AS
	SELECT
		[Rics_competencyId],
		[Rics_Code],
		[Rics_CompetencyName],
		[Rics_name],
		[Created_On],
		[CreatedBy],
		[CreatedByName],
		[Modified_On],
		[ModifiedBy],
		[ModifiedByName],
		[OwnerId],
		[OwnerIdName],
		[OwningUser],
		[OwningTeam],
		[OverriddenCreatedOn],
		[OwningBusinessUnit],
		[Rics_CompetencyType],
		[Rics_CompetencyType_Description],
		[statecode],
		[StateCode_Description],
		[statuscode],
		[StatusCode_Description],
		[Rics_Level],
		[Rics_Level_Description]
	FROM [Ext].[PBI02_CRM_vwRics_competency]

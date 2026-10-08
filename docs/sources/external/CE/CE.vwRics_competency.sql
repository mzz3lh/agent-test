CREATE   VIEW [CE].[vwRics_competency]
AS 
SELECT 
	[Rics_competencyId],
	[Rics_Code],
	[Rics_competencyName],
	[Created_On],
	[CreatedBy],
	[CreatedByName],
	[modifiedon],
	[modifiedby],
	[ModifiedByName],
	[organizationid],
	[OrganizationName],
	[Rics_CompetencyType],
	[Rics_CompetencyType_Description],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description]
FROM [synapse_ce].[vwRics_competency] --[Ext].[PBI03_CE_vwRics_competency]

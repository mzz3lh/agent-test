CREATE VIEW [dbo].[vwRics_areaofpractice]
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
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description]
FROM [Ext].[PBI02_CRM_vwRics_areaofpractice]

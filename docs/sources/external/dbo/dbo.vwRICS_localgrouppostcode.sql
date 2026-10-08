CREATE VIEW [dbo].[vwRICS_localgrouppostcode]
AS

SELECT
	[RICS_localgrouppostcodeId],
	[RICS_name],
	[Created_On],
	[CreatedBy],
	[CreatedByName],
	[Modified_On],
	[ModifiedBy],
	[ModifiedByName],
	[OrganizationId],
	[OrganizationIdName],
	[rics_groupid],
	[rics_groupidName],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description]
FROM [Ext].[PBI02_dbo_vwRICS_localgrouppostcode]

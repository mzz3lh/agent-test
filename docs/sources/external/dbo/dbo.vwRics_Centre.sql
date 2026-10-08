CREATE VIEW [dbo].[vwRics_Centre]
AS
SELECT
	[Rics_centreId],
	[Rics_name],
	[rics_venueid],
	[rics_venueidName],
	[Rics_FullName],
	[Rics_Description],
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
	[StatusCode_Description],
	[ricsv2_ApplicationType],
	[ricsv2_ApplicationType_Description]
FROM [Ext].[PBI02_CRM_vwRics_Centre]

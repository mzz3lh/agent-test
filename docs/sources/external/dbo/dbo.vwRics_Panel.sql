CREATE VIEW [dbo].[vwRics_Panel]
AS
SELECT
	[Rics_panelId],
	[Rics_name],
	[CreatedBy],
	[CreatedByName],
	[Created_On],
	[ModifiedBy],
	[ModifiedByName],
	[Modified_On],
	[rics_centreid],
	[rics_centreidName],
	[rics_venueid],
	[rics_venueidName],
	[OwnerId],
	[Rics_Date],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description]
FROM [Ext].[PBI02_CRM_vwRics_Panel]

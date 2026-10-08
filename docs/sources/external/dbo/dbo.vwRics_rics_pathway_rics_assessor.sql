CREATE VIEW [dbo].[vwRics_rics_pathway_rics_assessor]
AS
SELECT
	[rics_rics_pathway_rics_assessorId],
	[rics_pathwayid],
	[rics_assessorid]
FROM [Ext].[PBI02_CRM_vwRics_rics_pathway_rics_assessor]

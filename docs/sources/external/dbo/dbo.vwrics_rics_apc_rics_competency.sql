CREATE VIEW [dbo].[vwrics_rics_apc_rics_competency]
AS
	SELECT
		[rics_rics_apc_rics_competencyId],
		[rics_apcid],
		[rics_competencyid]
FROM [Ext].[PBI02_CRM_vwrics_rics_apc_rics_competency]

CREATE VIEW [dbo].[vwrics_rics_apc_rics_areaofpractice]
AS
SELECT 
	ap.rics_rics_apc_rics_areaofpracticeId,
	ap.rics_apcid,
	ap.rics_areaofpracticeid
FROM [Ext].[PBI02_CRM_vwrics_rics_apc_rics_areaofpractice]   ap

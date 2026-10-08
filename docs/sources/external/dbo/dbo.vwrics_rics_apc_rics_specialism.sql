CREATE VIEW [dbo].[vwrics_rics_apc_rics_specialism]
AS
SELECT 
	sp.rics_rics_apc_rics_specialismId,
	sp.rics_apcid,
	sp.rics_specialismid
FROM [Ext].[PBI02_CRM_vwrics_rics_apc_rics_specialism] sp

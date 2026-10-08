CREATE VIEW [dbo].[vwrics_rics_apc_rics_country]
AS
SELECT 
	cnt.rics_rics_apc_rics_countryId,
	cnt.rics_apcid,
	cnt.rics_countryid
FROM [Ext].[PBI02_CRM_vwrics_rics_apc_rics_country] cnt

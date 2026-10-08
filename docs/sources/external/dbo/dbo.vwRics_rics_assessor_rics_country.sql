CREATE VIEW [dbo].[vwRics_rics_assessor_rics_country]
AS
SELECT
	[rics_rics_assessor_rics_countryId],
	[rics_assessorid],
	[rics_countryid]
FROM [Ext].[PBI02_CRM_vwRics_rics_assessor_rics_country]

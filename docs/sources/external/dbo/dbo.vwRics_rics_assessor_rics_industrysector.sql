CREATE VIEW [dbo].[vwRics_rics_assessor_rics_industrysector]
AS
SELECT
	[rics_rics_assessor_rics_industrysectorId],
	[rics_assessorid],
	[rics_industrysectorid]
FROM [Ext].[PBI02_CRM_vwRics_rics_assessor_rics_industrysector]

CREATE VIEW [dbo].[vwRics_rics_areaofpractice_rics_assessor]
AS
SELECT
	[rics_rics_areaofpractice_rics_assessorId],
	[rics_areaofpracticeid],
	[rics_assessorid]
FROM [Ext].[PBI02_CRM_vwRics_rics_areaofpractice_rics_assessor]

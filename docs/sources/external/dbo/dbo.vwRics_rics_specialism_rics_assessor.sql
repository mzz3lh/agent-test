CREATE VIEW [dbo].[vwRics_rics_specialism_rics_assessor]
AS
SELECT
	[rics_rics_specialism_rics_assessorId],
	[rics_specialismid],
	[rics_assessorid]
FROM [Ext].[PBI02_CRM_vwRics_rics_specialism_rics_assessor]

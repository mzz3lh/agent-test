CREATE VIEW [dbo].[vwrics_rics_specialism_contact]
AS
SELECT
	[rics_rics_specialism_contactId],
	[rics_specialismid],
	[Contactid]
FROM [Ext].[PBI02_CRM_vwrics_rics_specialism_contact]

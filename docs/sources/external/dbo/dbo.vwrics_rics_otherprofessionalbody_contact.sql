CREATE VIEW [dbo].[vwrics_rics_otherprofessionalbody_contact]
AS
SELECT
	[rics_rics_otherprofessionalbody_contactId],
	[rics_otherprofessionalbodyid],
	[Contactid]
FROM [Ext].[PBI02_CRM_vwrics_rics_otherprofessionalbody_contact]

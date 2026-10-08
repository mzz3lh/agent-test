CREATE VIEW [dbo].[vwRics_ContactAudit_Concessions]
AS

SELECT
	[Rics_contactauditId],
	[Rics_contactno],
	[rics_contactid],
	[Created_On],
	[CreatedBy],
	[CreatedByName],
	[Modified_On],
	[ModifiedBy],
	[ModifiedByName],
	[Rics_name],
	[Rics_ConcessionCode],
	[Rics_Concessioncode_Description_Current],
	[Rics_ConcessionCode_Pre],
	[Rics_Concessioncode_Description_Previous],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description]
FROM [Ext].[PBI02_dbo_vwRics_ContactAudit_Concessions]

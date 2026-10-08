CREATE VIEW [dbo].[vwRics_ContactRelationship]
AS

SELECT
	[Rics_contactrelationshipId],
	[Rics_name],
	[Created_On],
	[CreatedBy],
	[CreatedByName],
	[Modified_On],
	[ModifiedBy],
	[ModifiedByName],
	[rics_contactid],
	[rics_accountid],
	[Rics_ContactRelationshipNo],
	[Rics_EndDate],
	[Rics_StartDate],
	[Rics_FromCDB],
	[Rics_RelationshipType],
	[Rics_RelationshipType_Description],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description],
	[Rics_ContactType],
	[Rics_DRS],
	[Rics_IsParentAccount],
	[Rics_PublishinDirectory],
	[Rics_BusinessPhone],
	[Rics_BusinessEmail],
	[Rics_JobTitle],
	[Rics_Touch]
FROM [Ext].[PBI02_dbo_vwRics_ContactRelationship]

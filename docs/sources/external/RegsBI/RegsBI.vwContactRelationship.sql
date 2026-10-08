CREATE VIEW [RegsBI].[vwContactRelationship]
AS
SELECT 
	[Rics_contactrelationshipId],
	[Rics_name],
	[Created_On],
	[CreatedByName],
	[Modified_On],
	[ModifiedByName],
	[rics_contactid],
	[rics_contactidName],
	[Rics_contactno],
	[rics_accountid],
	[rics_accountidName],
	[Rics_ContactRelationshipNo],
	[Rics_EndDate],
	[Rics_StartDate],
	[Rics_RelationshipType],
	[StateCode],
	[StatusCode],
	[Rics_ContactType],
	[Rics_BusinessPhone],
	[Rics_BusinessEmail],
	[Rics_JobTitle],
	[rics_officenumber],
	[rics_firmnumber]
FROM [Ext].[PBI02_RegsBI_vwContactRelationship]

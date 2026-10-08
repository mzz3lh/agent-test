CREATE   VIEW [Eventbrite].[vwOrganization]
AS
SELECT	
	[organization_id]
	,[organization_name] AS [Organization]
FROM [EventBrite].[tblOrganization]

CREATE   VIEW [Eventbrite].[vwVenue]
AS
SELECT
	CAST(v.[venue_id] AS NVARCHAR(20)) + '_' + CAST(v.[organization_id] AS NVARCHAR(20)) AS [VenueKey]
	,v.[Venue_Id]
	,v.[Name] AS [Venue]
	,v.[Address1]
	,v.[Address2]
	,v.[City]
	,v.[Country]
	,v.[Region]
	,v.[Organization_Id]
FROM [EventBrite].[tblVenue] v

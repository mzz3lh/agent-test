CREATE VIEW [dbo].[vwOnDemandVideos]
AS
SELECT 
	[Video Id],
	[Video Name],
	[Video Topic],
	[On-Demand Type],
	[View Date],
	[Member No],
	[Member Name],
	[Member Grade],
	[Country],
	[Member Company],
	[CPDF Subscriber Status]
FROM [Ext].[PBI02_vwOndemandVideos]

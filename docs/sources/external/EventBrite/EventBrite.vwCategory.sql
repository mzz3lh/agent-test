CREATE   VIEW [Eventbrite].[vwCategory]
AS
SELECT
	CAST([Category_Id] AS NVARCHAR(20)) + '_' + CAST([Organization_Id] AS NVARCHAR(20)) AS [CategoryKey]	
	,[Category_Id]
	,[category_name] AS [Category]
	,[organization_id]
FROM [EventBrite].[tblCategory]

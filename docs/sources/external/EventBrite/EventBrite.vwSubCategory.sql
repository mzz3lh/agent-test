CREATE   VIEW [Eventbrite].[vwSubCategory]
AS
SELECT 
	CAST([Category_Id] AS NVARCHAR(20)) + '_' + CAST([Organization_Id] AS NVARCHAR(20)) AS [CategoryKey]	
	,CAST([SubCategory_Id] AS NVARCHAR(20)) + '_' + CAST([Organization_Id] AS NVARCHAR(20)) AS [SubCategoryKey]	
	,[SubCategory_Id]
	,[SubCategory_Name] AS [Sub Category]
FROM [EventBrite].[tblSubCategory]

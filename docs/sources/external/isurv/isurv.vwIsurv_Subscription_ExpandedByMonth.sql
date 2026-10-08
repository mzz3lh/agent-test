CREATE   VIEW [isurv].[vwIsurv_Subscription_ExpandedByMonth] AS

	WITH CTE AS (
	SELECT
	[First Day of the Month] AS 'Month'
	FROM BI.vwCalendar
	GROUP BY [First Day of the Month]
	)

	SELECT 
	 [Subscription ID]
	,[Acc/Con ID]
	,[Acc/Con Name]
	,[Acc/Con Type]
    ,[Sub Start Date]
    ,[Sub End Date]
	,DATEFROMPARTS(YEAR([Sub Start Date]), MONTH([Sub Start Date]), 01) AS 'Sub Start Date Flat'
	,DATEFROMPARTS(YEAR([Sub End Date]), MONTH([Sub End Date]), 01) AS 'Sub End Date Flat'
	,[Month]
FROM [isurv].[vwIsurv_Subscription]
LEFT JOIN CTE 
	ON CTE.[Month] BETWEEN DATEFROMPARTS(YEAR([Sub Start Date]), MONTH([Sub Start Date]), 01) AND DATEFROMPARTS(YEAR([Sub End Date]), MONTH([Sub End Date]), 01)
WHERE [Month] < GETDATE()

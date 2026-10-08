CREATE   VIEW [Expenses].[vwEgencia_CostCentre] 
AS

WITH EGC AS (
	SELECT
		IIF([Cost Center] = '', 'Not Known', [Cost Center]) AS 'Cost Center'
		,CASE 
			WHEN [Cost Center] = '' THEN '0000' 
			WHEN [Cost Center] = 'PLEASE SELECT' THEN '0000' 
			ELSE SUBSTRING([Cost Center], 1, CHARINDEX(' ', [Cost Center]))
			END AS 'Cost Centre Code'
	FROM [Expenses].[tblTravelExpenses] EGC
	GROUP BY  
		[Cost Center]
		,CASE 
			WHEN [Cost Center] = '' THEN '0000' 
			WHEN [Cost Center] = 'PLEASE SELECT' THEN '0000' 
			ELSE SUBSTRING([Cost Center], 1, CHARINDEX(' ', [Cost Center]))
			END
)

SELECT
	EGC.*
FROM EGC
	LEFT JOIN FO.vwCostCentre CC
		ON CC.CostCentre_Code = EGC.[Cost Centre Code]
--WHERE EGC.[Cost Centre Code] = '0000' OR CC.CostCentre_Name  IS NOT NULL

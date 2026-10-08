CREATE VIEW [Static].[vwEgencia_Employee] AS

WITH EMP1 AS (
	SELECT
	 CASE 
		WHEN [Employee ID] IS NULL THEN '00000'
		WHEN [Employee ID] IN ('NONE', 'N/a', '', '0') THEN '00000'
		ELSE [Employee ID]
		END AS 'Employee ID'
	,[Traveller Name]
	,[Transaction Date]

	FROM [Static].[tblEgenciaDemoExport]
	GROUP BY
	 CASE 
		WHEN [Employee ID] IS NULL THEN '00000'
		WHEN [Employee ID] IN ('NONE', 'N/a', '', '0') THEN '00000'
		ELSE [Employee ID]
		END
	,[Traveller Name]
	,[Transaction Date]
	),

EMP2 AS (
	SELECT
	*
	,ROW_NUMBER()  OVER(PARTITION BY [Employee ID] ORDER BY [Transaction Date] DESC) AS RowNo
	FROM EMP1
	)

SELECT
*
FROM EMP2
WHERE RowNo = 1

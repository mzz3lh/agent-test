CREATE VIEW [Static].[vwEgencia_CostCentre_DB] AS

WITH EGC AS (
	SELECT
	-- Directorate
	--[Cost Center]
	CASE 
		WHEN [Cost Center] = '' THEN '0000' 
		WHEN [Cost Center] = 'PLEASE SELECT' THEN '0000' 
		ELSE SUBSTRING([Cost Center], 1, CHARINDEX(' ', [Cost Center]))
		END AS 'Cost Centre Code'
	FROM static.tblEgenciaDemoExport EGC
	GROUP BY  
	-- Directorate
	CASE 
		WHEN [Cost Center] = '' THEN '0000' 
		WHEN [Cost Center] = 'PLEASE SELECT' THEN '0000' 
		ELSE SUBSTRING([Cost Center], 1, CHARINDEX(' ', [Cost Center]))
		END
	)

SELECT
 EGC.*
,CASE
	WHEN EGC.[Cost Centre Code] = '0000' THEN 'Not Known'
	WHEN CC.CostCentre_Name IS NULL THEN 'Not Known'
	ELSE CC.CostCentre_Name 
	END AS 'Cost Centre Name'
FROM EGC
LEFT JOIN FO.vwCostCentre CC
	ON CC.CostCentre_Code = EGC.[Cost Centre Code]
--WHERE EGC.[Cost Centre Code] = '0000' OR CC.CostCentre_Name  IS NOT NULL

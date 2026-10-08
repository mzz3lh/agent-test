CREATE VIEW [CE].[vwEQSFinalAssessmentStatsSummary]
AS

WITH cteSummary
AS
(
SELECT [Assessment Year] AS [Year],
--[final outcome] AS Outcome,Gender,[World Region],
COUNT(*) AS [PassCount] 

FROM CE.vwEQSAssessmentStats
WHERE [Assessment Type] = 'Candidate Final Assessment'
AND [World Region] = 'UK&I'
AND [Assessment Year] BETWEEN 2018 AND DATEPART(Year, GETDATE())  -- -1 --removed to include up to date stats DBA/PS 22/08/2025
AND [final outcome] ='Pass'
AND gendercode IN (1,2,200000000)
GROUP BY [Assessment Year]
--,[final outcome],Gender,[World Region]
),

cteSummary2
AS
(
SELECT [Year],
[PassCount], 
TotalAssessments AS TotalAss, 
ROUND(CAST(PassCount AS FLOAT) / CAST(TotalAssessments AS FLOAT)*100,0) AS PassRate,
LAG([PassCount],1) OVER(ORDER BY [Year]) PreviousYearPass,
LAG([TotalAssessments],1) OVER(ORDER BY [Year]) PreviousYearTotalAss,
LAG(ROUND(CAST(PassCount AS FLOAT) / CAST(TotalAssessments AS FLOAT)*100,0),1) OVER(ORDER BY [Year])AS PYPassRate,
CASE WHEN ROUND(CAST(PassCount AS FLOAT) / CAST(TotalAssessments AS FLOAT)*100,0)> LAG(ROUND(CAST(PassCount AS FLOAT) / CAST(TotalAssessments AS FLOAT)*100,0),1) OVER(ORDER BY [Year])
		THEN 'Up' --Pass Rate is Up on the previous year
	 WHEN ROUND(CAST(PassCount AS FLOAT) / CAST(TotalAssessments AS FLOAT)*100,0)< LAG(ROUND(CAST(PassCount AS FLOAT) / CAST(TotalAssessments AS FLOAT)*100,0),1) OVER(ORDER BY [Year])
		THEN 'Down'
	 WHEN ROUND(CAST(PassCount AS FLOAT) / CAST(TotalAssessments AS FLOAT)*100,0)= LAG(ROUND(CAST(PassCount AS FLOAT) / CAST(TotalAssessments AS FLOAT)*100,0),1) OVER(ORDER BY [Year])
		THEN 'Same'
	 WHEN LAG(ROUND(CAST(PassCount AS FLOAT) / CAST(TotalAssessments AS FLOAT)*100,0),1) OVER(ORDER BY [Year]) IS NULL
		THEN 'No Data'
END AS PrevYearCompTxt,
CASE WHEN ROUND(CAST(PassCount AS FLOAT) / CAST(TotalAssessments AS FLOAT)*100,0) < LAG(ROUND(CAST(PassCount AS FLOAT) / CAST(TotalAssessments AS FLOAT)*100,0),1) OVER(ORDER BY [Year])
		THEN -1 -- I.e The Year in question is Down on the Previous year
	 WHEN ROUND(CAST(PassCount AS FLOAT) / CAST(TotalAssessments AS FLOAT)*100,0) > LAG(ROUND(CAST(PassCount AS FLOAT) / CAST(TotalAssessments AS FLOAT)*100,0),1) OVER(ORDER BY [Year])
		THEN 1
	WHEN ROUND(CAST(PassCount AS FLOAT) / CAST(TotalAssessments AS FLOAT)*100,0) = LAG(ROUND(CAST(PassCount AS FLOAT) / CAST(TotalAssessments AS FLOAT)*100,0),1) OVER(ORDER BY [Year])
		THEN 0
	 WHEN LAG(ROUND(CAST(PassCount AS FLOAT) / CAST(TotalAssessments AS FLOAT)*100,0),1) OVER(ORDER BY [Year]) IS NULL
		THEN 9
END AS PrevYearCompVal,
DATEPART(Year,GETDATE())-1 AS LastFullYear
--(SELECT ROUND(CAST(PassCount AS FLOAT) / CAST(TotalAssessments AS FLOAT)*100,0) FROM cteSummary WHERE [Year] = DATEPART(Year,GETDATE())-1) AS LFYPassRate
	
FROM cteSummary

OUTER APPLY  --Total no of Assessments for each year
(SELECT [Assessment Year], COUNT(*) AS TotalAssessments FROM CE.vwEQSAssessmentStats
WHERE [Assessment Year] >= 2018
AND [Assessment Type] = 'Candidate Final Assessment'
AND [World Region] = 'UK&I'
AND gendercode IN (1,2,200000000)
AND [final outcome] IN ('Pass','Refer')
GROUP BY [Assessment Year]) Totals

WHERE cteSummary.[Year] = Totals.[Assessment Year]
),

cteLFYPassRate
AS
(
SELECT LastFullYear,PassRate AS LFYPassRate
FROM cteSummary2 
WHERE [Year] = DATEPART(Year,GETDATE())-1 
)


SELECT S2.*
,LFYPassRate
,CASE WHEN PassRate > LFYPassRate
		THEN 'Down' -- I.e The last full Year is Down on the year in question
	 WHEN PassRate < LFYPassRate
		THEN 'Up'
	WHEN PassRate = LFYPassRate
		AND [Year] <> LFYPR.[LastFullYear] 
		THEN 'Same'
	 WHEN [Year] = LFYPR.[LastFullYear] --DATEPART(Year,GETDATE())-1
		THEN 'Not Applicable'
END AS LastFullYearCompTxt
,CASE WHEN PassRate > LFYPassRate
		THEN -1 -- I.e The last full Year is Down on the year in question
	 WHEN PassRate < LFYPassRate
		THEN 1
	WHEN PassRate = LFYPassRate
	AND [Year] <> LFYPR.[LastFullYear]
		THEN 0
	 WHEN [Year] = LFYPR.[LastFullYear] -- DATEPART(Year,GETDATE())-1
		THEN 9
END AS LastFullYearCompVal
FROM cteSummary2 S2
INNER JOIN cteLFYPassRate LFYPR
	ON S2.LastFullYear = LFYPR.LastFullYear

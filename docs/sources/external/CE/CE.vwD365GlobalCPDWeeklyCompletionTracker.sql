CREATE VIEW CE.vwD365GlobalCPDWeeklyCompletionTracker
AS

WITH
cteBaseData
AS
(
SELECT DISTINCT SUM([Total Count]) AS [Total Count],
SUM([Count Complete]) AS [Count Complete],
SUM([CountNot Complete]) AS [Count Not Complete],
SUM([PY Total Count]) AS [PY Total Count],
SUM([PY Count Complete]) AS [PY Count Complete],
SUM([PY Count Not Complete]) AS [PY Count Not Complete],
SUM([Total Count]) - SUM([PY Total Count]) AS DiffTotal_Count,
DATEPART(ww,DateOfSnapshot) AS WeekNo, 
cast(DATEADD(day, -1*(DATEPART(WEEKDAY, DateOfSnapshot)-1), DateOfSnapshot) as DATE) as WeekStart,
DateOfSnapshot,
PYDateOfSnapshot,
cpdrecordingstatus,
rics_cpdyear,
Rics_WorldRegion,
rics_region,
rics_countryidname
--LocalGroup
FROM [CE].[vwD365GlobalDailyCompletionTracker]
--WHERE
--rics_cpdyear = '2021' AND
--[rics_CountryIdName] in ('Australia') AND
--[rics_region] IN ('Oceania') --AND 
----DateOfSnapshot = '2021-10-22'

GROUP BY DateOfSnapshot,PYDateOfSnapshot,cpdrecordingstatus,rics_cpdyear,Rics_WorldRegion,
rics_region,rics_countryidname
---,LocalGroup

),

cteWeekly
AS
(
SELECT 
SUM([Total Count]) AS [Total Count],
SUM([Count Complete]) AS [Count Complete],
SUM([Count Not Complete]) AS [Count Not Complete],
SUM([PY Total Count]) AS [PY Total Count],
SUM([PY Count Complete]) AS [PY Count Complete],
SUM([PY Count Not Complete]) AS [PY Count Not Complete],
SUM([DiffTotal_Count])  AS DiffTotal_Count,
MIN(WeekNo) AS WeekNo, 
WeekStart,
MIN(DateofSnapshot) AS SnapshotRange,
cpdrecordingstatus,
rics_cpdyear,
Rics_WorldRegion,
rics_region,
rics_countryidname
--INTO #Data
FROM cteBaseData
--WHERE WeekNo = 3
GROUP BY WeekStart,
cpdrecordingstatus,
rics_cpdyear,
Rics_WorldRegion,
rics_region,
rics_countryidname
)


SELECT [Total Count], [Count Complete],CONVERT(DECIMAL(10,2),CONVERT(DECIMAL ,[Count Complete])/CONVERT(DECIMAL,[Total Count]) * 100) AS [PCT Complete],
[Count Not Complete], CONVERT(DECIMAL(10,2),CONVERT(DECIMAL ,[Count Not Complete])/CONVERT(DECIMAL,[Total Count]) * 100) AS [PCT Not Complete],
[PY Total Count], [PY Count Complete], CONVERT(DECIMAL(10,2),CONVERT(DECIMAL ,[PY Count Complete])/CONVERT(DECIMAL,[PY Total Count]) * 100) AS [PY PCT Complete],
[PY Count Not Complete], CONVERT(DECIMAL(10,2),CONVERT(DECIMAL ,[PY Count Not Complete])/CONVERT(DECIMAL,[PY Total Count]) * 100) AS [PY PCT Not Complete],
DiffTotal_Count AS [Diff Total Count],CONVERT(DECIMAL(10,2),CONVERT(DECIMAL ,[DiffTotal_Count])/CONVERT(DECIMAL,[PY Total Count]) * 100) AS [PCT Diff Total Count],
WeekNo,WeekStart,SnapshotRange,cpdrecordingstatus AS [CPD Recording Status],rics_cpdyear AS [CPD Year],Rics_WorldRegion AS [World Region], Rics_Region AS [Region],
Rics_countryIDName AS [Country]
FROM cteWeekly

CREATE VIEW CE.vwD365GlobalDailyCompletionTracker
AS

--Base Data
WITH cteBase
AS
(
SELECT 
#.Total_Count,
#.[Count Complete],
#.[Count Not Complete],
#.DateOfSnapshot,
DATEADD(yy,-1,#.dateOfSnapshot) AS PYDateOfSnapshot,
#.cpdrecordingstatus,
#.rics_cpdyear,
lg.Rics_WorldRegion,
lg.rics_region,
lg.rics_countryidName,
lg.Rics_ReportingLocalGroup AS LocalGroup

FROM [Snapshots].[tblCPDWeekleyComplianceStatsSnapshot_CE_ALL] as #
		inner join CE.vwRicsGroup as lg on #.rics_groupid = lg.rics_groupid

),


--Base Data with PY Comparison Fields
cteComp
AS
(
SELECT * FROM cteBase #


OUTER APPLY 

(SELECT Total_Count AS PYTotal_Count FROM
cteBase ##
WHERE  ##.DateOfSnapshot = #.PYDateOfSnapshot
AND ##.cpdrecordingstatus = #.cpdrecordingstatus
AND ##.rics_cpdyear = #.rics_cpdyear-1
AND ##.rics_WorldRegion = #.rics_WorldRegion
AND ##.rics_Region = #.rics_Region 
AND ##.rics_Countryidname = #.rics_Countryidname
AND ##.LocalGroup = #.LocalGroup
) TC

OUTER APPLY

(SELECT [Count Complete] AS PYCountComplete FROM
cteBase ##
WHERE  ##.DateOfSnapshot = #.PYDateOfSnapshot
AND ##.cpdrecordingstatus = #.cpdrecordingstatus
AND ##.rics_cpdyear = #.rics_cpdyear-1
AND ##.rics_WorldRegion = #.rics_WorldRegion
AND ##.rics_Region = #.rics_Region 
AND ##.rics_Countryidname = #.rics_Countryidname
AND ##.LocalGroup = #.LocalGroup
) CC


OUTER APPLY

(SELECT [Count Not Complete] AS PYCountNotComplete FROM
cteBase ##
WHERE  ##.DateOfSnapshot = #.PYDateOfSnapshot
AND ##.cpdrecordingstatus = #.cpdrecordingstatus
AND ##.rics_cpdyear = #.rics_cpdyear-1
AND ##.rics_WorldRegion = #.rics_WorldRegion
AND ##.rics_Region = #.rics_Region 
AND ##.rics_Countryidname = #.rics_Countryidname
AND ##.LocalGroup = #.LocalGroup
) CNC

)

--Final SELECT
SELECT SUM(Total_Count) AS [Total Count],
SUM([Count Complete]) AS [Count Complete],
SUM([Count Not Complete]) AS [CountNot Complete],
SUM(PYTotal_Count) AS [PY Total Count],
SUM(PYCountComplete) AS [PY Count Complete],
SUM(PYCountNotComplete) AS [PY Count Not Complete],
SUM(PYTotal_Count) - SUM(Total_Count) AS DiffTotal_Count,
DateOfSnapshot,
PYDateOfSnapshot,
cpdrecordingstatus,
rics_cpdyear,
Rics_WorldRegion,
rics_region,
rics_countryidname,
LocalGroup

FROM cteComp

--where 
--cteComp.rics_cpdyear = '2021' AND
--cteComp.[rics_CountryIdName] in ('Australia') AND
--cteComp.[rics_region] IN ('Oceania') AND 
--cteComp.DateOfSnapshot = '2021-10-22'

GROUP BY DateOfSnapshot,PYDateOfSnapshot,cpdrecordingstatus,rics_cpdyear,Rics_WorldRegion,
rics_region,rics_countryidname,LocalGroup

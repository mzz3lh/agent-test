/*
This version is in response to U/S's 69859 and 69864
The CPD criteria definitions as supplied by Alan Smithers 10/01/2025
 No 25% buffer and only some Additional fields (that do not require additional joins) 
as suggested in the Candidate Engagement Segregation document since they aren't in the U/S's

CPD calculated backwards from Todays Date rather the forward from Enrolment date as per AS's recommendation
*/




CREATE PROCEDURE [CE].[uspCandidateLevelOfEngagement]
AS
BEGIN

/*
DROP TABLE #Main
DROP TABLE #NoICPD
DROP TABLE #NoFCPD
DROP TABLE #CPD
DROP TABLE #TotalHrs
DROP TABLE #CPDSummary
*/


	BEGIN

	SELECT 
	[Contact No]
	,[Contact Id]
	,[Forename]
	,[Surname]
	,[Local Group]
	,[World Region]
	,[Region]
	,[Market]
	,[Country]
	,CASE
		WHEN [Enrolment Date] IS NULL THEN 'No'
		ELSE 'Yes'
	END AS [Has Enrolment Date]
	,ISNULL([Enrolment Date], [Created Date]) AS [Enrolment Date]
	,[Created Date]
	,[Pathway]
	,[Route]
	,[Enrolment Type]
	,[ARC Last Logged In]
	,[ScoreALLI]
	,[StatusALLI]
	,[ARC Assessment Status]
	,[ScoreAAS]
	,[StatusAAS]
	,[Case Study Status]
	,[ScoreCSS]
	,[StatusCSS]
	,[Competency Selection Completed Date]
	,[ScoreCSCD]
	,[StatusCSCD]
	--,[TotalScore]
	--,[EngagementStatus]
	,CASE 
		WHEN [Route] IN ('APC Structured Training 12','APC Other','APC Prelim', 'Associate Assessment') THEN 365--12 months
		WHEN [Route] IN ('APC Structured Training 24') THEN 730 --24 Months
		WHEN [Route] IN ('Specialist Assessment','Senior Professional Assessment - July 2017') THEN 365 --12 Months
		ELSE 365  --catch all - TODO: check out for Assoc Direct Entry or any others not listed
	END AS TotalDaysAllowed,
	ROUND(DATEDIFF(dd,ISNULL([Enrolment Date],[Created Date]), GETDATE()),0) AS DaysSinceENR
	,CASE
		WHEN [Route] IN ('APC Structured Training 12','APC Other','APC Prelim', 'Associate Assessment') AND
			ROUND(DATEDIFF(dd,ISNULL([Enrolment Date],[Created Date]), GETDATE()),0)> 365 THEN GETDATE()-365 
		WHEN [Route] IN ('APC Structured Training 12','APC Other','APC Prelim', 'Associate Assessment') AND
			ROUND(DATEDIFF(dd,ISNULL([Enrolment Date],[Created Date]), GETDATE()),0)< 365 THEN [Enrolment Date]
		WHEN [Route] IN ('APC Structured Training 24') AND 
			ROUND(DATEDIFF(dd,ISNULL([Enrolment Date],[Created Date]), GETDATE()),0) > 1460 THEN GETDATE()-1460
		WHEN [Route] IN ('APC Structured Training 24') AND 
			ROUND(DATEDIFF(dd,ISNULL([Enrolment Date],[Created Date]), GETDATE()),0) < 1460 THEN [Enrolment Date]
		WHEN [Route] IN ('Specialist Assessment','Senior Professional Assessment - July 2017') AND 
			ROUND(DATEDIFF(dd,ISNULL([Enrolment Date],[Created Date]), GETDATE()),0)> 365 THEN GETDATE()-365
		WHEN [Route] IN ('Specialist Assessment','Senior Professional Assessment - July 2017') AND
			ROUND(DATEDIFF(dd,ISNULL([Enrolment Date],[Created Date]), GETDATE()),0)< 365 THEN [Enrolment Date]
	END AS CPDDatum
	,CASE
		WHEN [Route] IN ('APC Structured Training 12','APC Other','APC Prelim', 'Associate Assessment') THEN 48
		WHEN [Route] IN ('APC Structured Training 24') THEN 96
		WHEN [Route] IN ('Specialist Assessment','Senior Professional Assessment - July 2017') THEN 20
		ELSE 48  --catch all - TODO: check out for Assoc Direct Entry or any others not listed
	END AS TotalHrsReqd
	INTO #Main
	FROM CE.vwCandidateLevelOfEngagement

	

	--those who have CPD hours
	SELECT
	M.[Contact ID],
	ISNULL(CPD.apuk_numberofhours, 0.00) AS [NoOfHours],
	CASE CPD.apuk_formalinformal 
		WHEN 200000001 THEN 'Formal'
		WHEN 200000000 THEN 'Informal'
	END AS [FormalInformal],
	CPD.apuk_datecompleted AS [ActivityCompletedDate]
	INTO #CPD
	FROM #Main M
	LEFT OUTER JOIN synapse_ce.apuk_CPDActivity CPD on M.[Contact ID] = CPD.apuk_contactid
	WHERE CPD.apuk_contactid IN (SELECT [Contact ID] FROM #Main)
	AND CPD.apuk_eligible = 1
	AND CPD.apuk_datecompleted IS NOT NULL
	AND CPD.apuk_datecompleted >= CPDDatum




	--identify those who do not have any Informal CPD Hours but ARE in #CPD with Formal Hrs
	SELECT DISTINCT [Contact ID] INTO #NoICPD FROM #Main M
	WHERE NOT EXISTS(SELECT 1 FROM #CPD C WHERE M.[Contact Id] = C.[Contact ID]
	AND FormalInformal = 'Informal')

	--identify those who do not have any Formal CPD Hours but ARE in #CPD with Informal Hrs
	SELECT DISTINCT [Contact ID] INTO #NoFCPD FROM #Main M
	WHERE NOT EXISTS(SELECT 1 FROM #CPD C WHERE M.[Contact Id] = C.[Contact ID]
	AND FormalInformal = 'Formal')

	--INSERT single rows for those into #CPD who have No Informal Hrs 
	INSERT #CPD
	SELECT[Contact ID]
	,0.00 AS NoOfHours
	,'Informal' AS FormalInformal
	,NULL AS ActivityCompletedDate
	FROM #NoICPD

	--INSERT single rows for those into #CPD who have No Formal Hrs 
	INSERT #CPD
	SELECT[Contact ID]
	,0.00 AS NoOfHours
	,'Formal' AS FormalInformal
	,NULL AS ActivityCompletedDate
	FROM #NoFCPD

	--SELECT * FROM #CPD

	--Total CPD Hours
	SELECT [Contact Id]
	,SUM(NoOfHours) AS TotalHrs
	INTO #TotalHrs
	FROM #CPD
	GROUP BY [Contact ID]

	END


	BEGIN

	--Summarise the total hrs, formal hours, informal hours, their respective formal percentage and pro-rata value
	WITH
	cteProRata 
	AS
	(
	SELECT DISTINCT M.[Contact ID], M.[Contact No]
	,CASE
		--Version without 25% buffer
		WHEN CAST(CAST(M.DaysSinceENR AS NUMERIC(10,2)) / CAST(TotalDaysAllowed AS NUMERIC(10,2))AS NUMERIC(10,2))  >=1 THEN 1
		WHEN CAST(CAST(M.DaysSinceENR AS NUMERIC(10,2)) / CAST(TotalDaysAllowed AS NUMERIC(10,2))AS NUMERIC(10,2)) = 0 THEN 0.1 --to avoid a 'divide by zero' error without significantly influencing the score
		ELSE CAST(CAST(M.DaysSinceENR AS NUMERIC(10,2)) / CAST(TotalDaysAllowed AS NUMERIC(10,2))AS NUMERIC(10,2))
	
		--Version with 25% buffer
		--WHEN CAST((CAST(M.DaysSinceENR AS NUMERIC(10,2)) - CAST(TotalDaysAllowed*0.25 AS NUMERIC(10,2))) / CAST(TotalDaysAllowed AS NUMERIC(10,2))AS NUMERIC(10,2))  >=1 THEN 1
		--WHEN CAST((CAST(M.DaysSinceENR AS NUMERIC(10,2)) - CAST(TotalDaysAllowed*0.25 AS NUMERIC(10,2))) / CAST(TotalDaysAllowed AS NUMERIC(10,2))AS NUMERIC(10,2))  <=0 THEN 0
		--ELSE CAST((CAST(M.DaysSinceENR AS NUMERIC(10,2)) - CAST(TotalDaysAllowed*0.25 AS NUMERIC(10,2))) / CAST(TotalDaysAllowed AS NUMERIC(10,2))AS NUMERIC(10,2))
	END AS ProRata
	FROM #Main M
	),


	cteFormalHrs
	AS
	(
	SELECT [Contact Id]
	,SUM(NoOfHours) AS FormalHrs
	FROM #CPD
	WHERE FormalInformal = 'Formal'
	GROUP BY [Contact ID]
	),

	cteInformalHrs
	AS
	(
	SELECT [Contact Id]
	,SUM(NoOfHours) AS InformalHrs
	FROM #CPD
	WHERE FormalInformal = 'Informal'
	GROUP BY [Contact ID]
	),

	cteHrsSummary
	AS
	(
	SELECT T.[Contact ID]
	,T.TotalHrs
	,F.FormalHrs
	,I.InformalHrs
	,CASE
		WHEN T.TotalHrs <> 0.00
		THEN CAST((FormalHrs / TotalHrs)*100 AS DECIMAL(10,2))
		ELSE 0.00
	END AS PctFormal
	FROM 
	#TotalHrs T
	INNER JOIN cteFormalHrs F ON T.[Contact ID] = F.[Contact ID]
	INNER JOIN cteInformalHrs I ON T.[contact ID] = I.[contact ID]
	),

	--Diary Days
	cteDiaryDays
	AS
	(
	SELECT regardingobjectid AS [Contact Id],SUM(apuk_days) AS DiaryDays, M. [Enrolment Type] 
	FROM [synapse_ce].[vwCandidatediaryentry] CDE
	INNER JOIN #Main M ON M.[Contact Id] = CDE.RegardingObjectId

	OUTER APPLY
	(SELECT [Contact Id], [Enrolment Date]
	FROM #Main WHERE CDE.regardingobjectid = #Main.[contact ID]) ENR

	WHERE regardingobjectid IN (SELECT [Contact Id] FROM #Main)
	AND CDE.actualstart >= ENR.[Enrolment Date]
	--AND M.[Contact ID] = '00000000-0000-0000-0000-000000000000'  --65
	GROUP BY [regardingobjectid], [Enrolment Type]
	)

	SELECT HS.[Contact ID], PR.[Contact No]
	,TotalHrs
	,TotalHrsReqd * ProRata AS ExpectedTotalHrs
	,FormalHrs
	,(TotalHrsReqd/2) * ProRata AS ExpectedFormalHrs
	,InformalHrs
	,ProRata
	,PctFormal
	,(((TotalHrsReqd/2) * ProRata)/TotalHrsReqd)*100 AS ExpectedPctFormalHrs
	,CASE 
		WHEN PctFormal >= 50 THEN 3
		WHEN PctFormal BETWEEN 30 AND 49.99 THEN 2
		WHEN PctFormal < 30 THEN 1
	END AS ScorePF
	,CASE 
		WHEN PctFormal >= 50 THEN 'Green'
		WHEN PctFormal BETWEEN 30 AND 49.99 THEN 'Amber'
		WHEN PctFormal < 30 THEN 'Red'
	END AS StatusPF
	,CASE 
		WHEN TotalHrs / (TotalHrsReqd * ProRata) >= 1 THEN 3
		WHEN TotalHrs / (TotalHrsReqd * ProRata) BETWEEN 0.65 AND 0.99 THEN 2
		WHEN TotalHrs / (TotalHrsReqd * ProRata) < 0.65 THEN 1
	END AS ScoreTH
	,CASE 
		WHEN TotalHrs / (TotalHrsReqd * ProRata) >= 1 THEN 'Green'
		WHEN TotalHrs / (TotalHrsReqd * ProRata) BETWEEN 0.65 AND 0.99 THEN 'Amber'
		WHEN TotalHrs / (TotalHrsReqd * ProRata) < 0.65 THEN 'Red'
	END AS StatusTH
	,ISNULL(DiaryDays,0) AS DiaryDays
	,CASE 
		WHEN M.[Enrolment Type] NOT IN ('APC12 - Structured Training','APC24 - Structured Training') THEN 3 --added DBA/PS 20/08/2025 as per meeting to give 3 score to all except APC12/24
		WHEN ISNULL(DiaryDays,0) >= (200 * ProRata) AND M.[Enrolment Type] = 'APC12 - Structured Training' THEN 3
		WHEN ISNULL(DiaryDays,0) >= (400 * ProRata) AND M.[Enrolment Type] = 'APC24 - Structured Training' THEN 3
		WHEN ISNULL(DiaryDays,0) BETWEEN (100 * ProRata) AND (199 * ProRata) AND M.[Enrolment Type] = 'APC12 - Structured Training' THEN 2
		WHEN ISNULL(DiaryDays,0) BETWEEN (200 * ProRata) AND (399 * ProRata) AND M.[Enrolment Type] = 'APC24 - Structured Training' THEN 2
		WHEN ISNULL(DiaryDays,0) BETWEEN (0 * ProRata) AND (99 * ProRata) AND M.[Enrolment Type] = 'APC12 - Structured Training' THEN 1
		WHEN ISNULL(DiaryDays,0) BETWEEN (0 * ProRata) AND (199 * ProRata) AND M.[Enrolment Type] = 'APC24 - Structured Training' THEN 1
	END AS ScoreDD
	,CASE
		WHEN M.[Enrolment Type] NOT IN ('APC12 - Structured Training','APC24 - Structured Training') THEN 'Green' --added DBA/PS 20/08/2025 as per meeting to give 3 score to all except APC12/24
		WHEN ISNULL(DiaryDays,0) >= (200 * ProRata) AND M.[Enrolment Type] = 'APC12 - Structured Training' THEN 'Green'
		WHEN ISNULL(DiaryDays,0) >= (400 * ProRata) AND M.[Enrolment Type] = 'APC24 - Structured Training' THEN 'Green'
		WHEN ISNULL(DiaryDays,0) BETWEEN (100 * ProRata) AND (199 * ProRata) AND M.[Enrolment Type] = 'APC12 - Structured Training' THEN 'Amber'
		WHEN ISNULL(DiaryDays,0) BETWEEN (200 * ProRata) AND (399 * ProRata) AND M.[Enrolment Type] = 'APC24 - Structured Training' THEN 'Amber'
		WHEN ISNULL(DiaryDays,0) BETWEEN (0 * ProRata) AND (99 * ProRata) AND M.[Enrolment Type] = 'APC12 - Structured Training' THEN 'Red'
		WHEN ISNULL(DiaryDays,0) BETWEEN (0 * ProRata) AND (199 * ProRata) AND M.[Enrolment Type] = 'APC24 - Structured Training' THEN 'Red'
	END AS StatusDD

	INTO #CPDSummary 
	FROM cteHrsSummary HS
	INNER JOIN cteProRata PR
	ON HS.[Contact ID] = PR.[Contact ID]
	LEFT JOIN cteDiaryDays DD
	ON DD.[Contact ID] = HS.[Contact Id]
	LEFT JOIN #Main M
	ON M.[Contact Id] = HS.[Contact Id]

	--SELECT * FROM #CPDSummary

	DROP TABLE CE.tblCandidateEngagementCPDSummary

	SELECT CPD.*
	INTO CE.tblCandidateEngagementCPDSummary
	FROM #CPDSummary CPD

	--SELECT * FROM CE.tblCandidateEngagementCPDSummary

	END

END

CREATE VIEW [CE].[vwCandidateLevelOfEngagement]
AS

WITH cteScores
AS
(
SELECT [Contact No],
[Contact Id],
Forename,
Surname,
[Local Group],
[ParentCustomerIDName] AS [Company Name],
[EMailAddress1] AS [EMail Address],
[World Region],
[Region],
[Market],
[Country],
[ENR ID],
[Enrolment Date],
[Created Date],
[Pathway],
[Route],
[Enrolment Type],
[ARC Last Logged In],
CASE 
	WHEN [ARC Last Logged In] >= DATEADD(mm,-6,GETDATE()) THEN 3 --Within 0-6 Months - Green
	WHEN [ARC Last Logged In] BETWEEN DATEADD(mm,-12,GETDATE()) AND DATEADD(mm,-6,GETDATE())  THEN 2 --between 6-12 Months - Amber
	WHEN ISNULL([ARC Last Logged In],'00000000') < DATEADD(mm,-12,GETDATE()) THEN 1 --12+ months - Red
END AS ScoreALLI,
CASE 
	WHEN [ARC Last Logged In] >= DATEADD(mm,-6,GETDATE()) THEN 'Green' --Within 0-6 Months - Green
	WHEN [ARC Last Logged In] BETWEEN DATEADD(mm,-12,GETDATE()) AND DATEADD(mm,-6,GETDATE())  THEN 'Amber' --between 6-12 Months - Amber
	WHEN ISNULL([ARC Last Logged In],'00000000') < DATEADD(mm,-12,GETDATE()) THEN 'Red' --12+ months -- Red
END AS StatusALLI,
[ARC Assessment Status],
CASE 
	WHEN [ARC Assessment Status] IN ('Final Assessment Application Completed','Preliminary Assessment Application Completed','Preliminary Assessment Passed','Ready to Start Final Assessment')THEN 3 --Green  --'Ready to Start Final Assessment' ADDED PS
	WHEN [ARC Assessment Status] = 'Referred' AND [ARC Last Logged In] >= DATEADD(mm,-6,GETDATE()) THEN 3 --Green
	WHEN [ARC Assessment Status] = 'Preliminary Assessment Failed' THEN 2 --Amber
	WHEN [ARC Assessment Status] = 'Referred' AND [ARC Last Logged In] BETWEEN DATEADD(mm,-12,GETDATE()) AND DATEADD(mm,-6,GETDATE())  THEN 2 --Amber
	WHEN ISNULL([ARC Assessment Status],'Not Started') = 'Not Started' THEN 1 --Red
	WHEN [ARC Assessment Status] = 'Referred' AND ISNULL([ARC Last Logged In],'2099/01/01') < DATEADD(mm,-12,GETDATE()) THEN 1  --Red
	--What about 'Final Assessment Application Downloaded','Preliminary Assessment Application Downloaded','Ready to Start Final Assessment','Submitted'
END AS ScoreAAS,
CASE 
	WHEN [ARC Assessment Status] IN ('Final Assessment Application Completed','Preliminary Assessment Application Completed','Preliminary Assessment Passed','Ready to Start Final Assessment')THEN 'Green' --Green  --'Ready to Start Final Assessment' ADDED PS
	WHEN [ARC Assessment Status] = 'Referred' AND [ARC Last Logged In] >= DATEADD(mm,-6,GETDATE()) THEN 'Green' --Green
	WHEN [ARC Assessment Status] = 'Preliminary Assessment Failed' THEN 'Amber' --Amber
	WHEN [ARC Assessment Status] = 'Referred' AND [ARC Last Logged In] BETWEEN DATEADD(mm,-12,GETDATE()) AND DATEADD(mm,-6,GETDATE())  THEN 'Amber' --Amber
	WHEN ISNULL([ARC Assessment Status],'Not Started') = 'Not Started' THEN 'Red' --Red
	WHEN [ARC Assessment Status] = 'Referred' AND ISNULL([ARC Last Logged In],'2099/01/01') < DATEADD(mm,-12,GETDATE()) THEN 'Red'  --Red
	--What about 'Final Assessment Application Downloaded','Preliminary Assessment Application Downloaded','Ready to Start Final Assessment','Submitted'
END AS StatusAAS,
[Case Study Status],
CASE WHEN [Case Study Status] IN ('Sent For Review', 'Approved', 'Uploaded') THEN 3 -- Green
	 --WHEN [Case Study Status] = 'Uploaded' THEN 2 --Amber  --Removed and put into Green DBA/PS 20/08/2025 as per meeting 
	 WHEN ISNULL([Case Study Status],'Not Started') = 'Not Started' THEN 1 --Red
	 --What about 'Feedback Provided'?
END AS ScoreCSS,
CASE WHEN [Case Study Status] IN ('Sent For Review', 'Approved', 'Uploaded') THEN 'Green' -- Green
	 --WHEN [Case Study Status] = 'Uploaded' THEN 'Amber' --Amber - --Removed and put into Green DBA/PS 20/08/2025 as per meeting 
	 WHEN ISNULL([Case Study Status],'Not Started') = 'Not Started' THEN 'Red' --Red
	 --What about 'Feedback Provided'?
END AS StatusCSS,
[Competency Selection Completed Date],
CASE 
	WHEN ISNULL([Competency Selection Completed Date],'') <>'' THEN 3 --Just a Yes/No DBA/PS 20/08/2025 as per meeting
	WHEN ISNULL([Competency Selection Completed Date],'') = '' THEN 1
	--WHEN [Competency Selection Completed Date] >= DATEADD(mm,-6,GETDATE()) THEN 3 --Within 0-6 Months
	--WHEN [Competency Selection Completed Date] BETWEEN DATEADD(mm,-12,GETDATE()) AND DATEADD(mm,-6,GETDATE())  THEN 2 --between 6-12 Months
	--WHEN ISNULL([Competency Selection Completed Date],'00000000') < DATEADD(mm,-12,GETDATE()) THEN 1 --12+ months
END AS ScoreCSCD,
CASE 
	WHEN ISNULL([Competency Selection Completed Date],'') <>'' THEN 'Green' --Just a Yes/No DBA/PS 20/08/2025 as per meeting
	WHEN ISNULL([Competency Selection Completed Date],'') = '' THEN 'Red'
	--WHEN [Competency Selection Completed Date] >= DATEADD(mm,-6,GETDATE()) THEN 'Green' --Within 0-6 Months
	--WHEN [Competency Selection Completed Date] BETWEEN DATEADD(mm,-12,GETDATE()) AND DATEADD(mm,-6,GETDATE())  THEN 'Amber' --between 6-12 Months
	--WHEN ISNULL([Competency Selection Completed Date],'00000000') < DATEADD(mm,-12,GETDATE()) THEN 'Red' --12+ months
END AS StatusCSCD,
[Corporate Enrolment],
[Submission Received],

--additional fields from U/S 72092
CASE
WHEN RR.apuk_apprentice IS NULL THEN 'No'
WHEN RR.apuk_apprentice ='False' THEN 'No'
ELSE 'Yes'
END AS 'Apprentice',
[Case Study Feedback],
[Summary of Experience Feedback],
[Summary of Experience Status],
[Approved By Counsellor]
,[Graduate Diary Start Date]
,[Councellor]
,[Proposer]
,[Proposer Approved Date]
,[Seconder 1]
,[Seconder 1 Approved Date]
,[Seconder 2]
,[Seconder 2 Approved Date]
,[ARC Declaration Accepted]
,[Ethics Module Last Taken]



FROM [CE].[vwEnrolment_Candidate_Last] ECL
INNER JOIN CE.vwRicsRecord RR
	ON ECL.[Contact ID] = RR.apuk_contactid
WHERE [Member Grade] = 'Candidate' 
AND [Lapsed Code] IS NULL
AND RR.statecode = 0
)

SELECT DISTINCT S.*, 
CPDSum.DiaryDays,ISNULL(CPDSum.ScoreDD,1) AS ScoreDD,ISNULL(CPDSum.StatusDD,'Red') AS StatusDD,
CPDSum.FormalHrs,CPDSum.PctFormal,ISNULL(CPDSum.ScorePF,1) AS ScorePF,ISNULL(CPDSum.StatusPF,'Red') AS StatusPF,
CPDSum.TotalHrs,ISNULL(CPDSum.ScoreTH,1) AS ScoreTH,ISNULL(CPDSum.StatusTH,'Red') AS StatusTH,
CPDSum.InformalHrs,CPDSum.ProRata,
ISNULL(ScoreALLI,1) + ISNULL(ScoreAAS,1) + ISNULL(ScoreCSS,1) + ISNULL(ScoreCSCD,1) + ISNULL(ScoreTH,1) + ISNULL(ScorePF,1) + ISNULL(ScoreDD,1) AS TotalScore,
CASE
	WHEN ISNULL(ScoreALLI,1) + ISNULL(ScoreCSS,1) + ISNULL(ScoreCSCD,1) + ISNULL(ScoreTH,1) + ISNULL(ScorePF,1) + ISNULL(ScoreDD,1) BETWEEN 12 AND 18 THEN 'Green'-- Removed ISNULL(ScoreAAS,1) + 22/08/2025 was 15 - 21
	WHEN ISNULL(ScoreALLI,1) + ISNULL(ScoreCSS,1) + ISNULL(ScoreCSCD,1) + ISNULL(ScoreTH,1) + ISNULL(ScorePF,1) + ISNULL(ScoreDD,1) BETWEEN 7 AND 11 THEN 'Amber' -- Removed ISNULL(ScoreAAS,1) + 22/08/2025 was 8 - 14
	WHEN ISNULL(ScoreALLI,1) + ISNULL(ScoreCSS,1) + ISNULL(ScoreCSCD,1) + ISNULL(ScoreTH,1) + ISNULL(ScorePF,1) + ISNULL(ScoreDD,1) <=6 THEN 'Red' -- Removed ISNULL(ScoreAAS,1) + 22/08/2025 was <=7
END AS EngagementStatus
FROM cteScores S
LEFT JOIN CE.tblCandidateEngagementCPDSummary CPDSum
ON S.[Contact ID] = CPDSum.[Contact ID]

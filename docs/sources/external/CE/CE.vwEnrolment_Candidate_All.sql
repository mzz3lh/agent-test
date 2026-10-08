--View for Candidate Enrolment records CE.vwEnrolment_Candidate

CREATE VIEW [CE].[vwEnrolment_Candidate_All]
AS
WITH cteENR
AS
(
SELECT ENR.[ENR ID]
	,ENR.[Enrolment Name]
	,ENR.[Created Datetime]
	,ENR.[Created Date]
	,ENR.[Created By]
	,ENR.[End Date]
	,ENR.[Application Type ID]
	,ENR.[Application Type]
	,ENR.[Contact No]
	,ENR.[Contact ID]
	,ENR.[Election Date]
	,CASE
		WHEN ENR.[Application Type]= 'Direct Entry' AND ENR.[Election Date] IS NULL
		THEN COALESCE(ENR.[Enrolment Date],ENR.[Created Date])
		ELSE ENR.[Election Date]
	END AS [#Election Date]
	,ENR.[Enrolment Date]
	,CASE 
		WHEN ENR.[Application Type]= 'Direct Entry' AND ENR.[Enrolment Date] IS NULL
			THEN COALESCE (ENR.[Election Date],ENR.[Created Date])
		ELSE COALESCE(ENR.[Enrolment Date],ENR.[Created Date])
	END AS [#Enrolment Date]
	,ENR.[expected_final_date]
	,ENR.[Number of Attempts]
	,ENR.[Enrolment Local Group ID]
	,ENR.[Pathway ID]
	,ENR.[Pathway]
	,ENR.[Route ID]
	,ENR.[Route]
	,ENR.[Enrolment Type ID]
	,ENR.[Enrolment Type]
	,ENR.[Outcome ID]
	,ENR.[Outcome]
	,ENR.[State Code]
	,ENR.[State]
	,ENR.[Status Code]
	,ENR.[Status]
	,ENR.[ARC Last Logged In]
	,DATEDIFF(dd,ENR.[ARC Last Logged in],GETDATE()) AS 'Days Since ARC Login'
	,CON.[rics_localgroupid] AS 'Local Group ID'
	,CON.[AccountId] AS 'Account ID'
	,CON.[FirstName] AS 'Forename'
	,CON.[LastName] AS 'Surname'
	,CAST(CON.[BirthDate] AS DATE) AS 'DOB'
	,DATEDIFF(YY,BirthDate, GETDATE()) AS 'Age'
	,COALESCE(GenderCode_Description, 'NULL') AS 'Gender'
	,COALESCE(Rics_Ethnicity_Description, 'NULL') AS 'Ethnicity'
	,Rics_Disability AS 'Has Disability'
	,COALESCE(CON.apuk_religionorbelief, -1) AS 'Religion Code'
	,CON.[StateCode]
	,COALESCE([Rics_MemberGrade], -1) AS Rics_MemberGrade
	,CON.[MemberGrade_Description] AS 'Member Grade'
	,CAST(CON.[Rics_LapsedDate] AS DATE) AS 'Lapsed Date'
	,CON.[Rics_LapsedCode] AS 'Lapsed Code'
	,CON.[Rics_LapsedCode_Description] AS 'Lapsed Reason'
	,CASE WHEN CON.Rics_LapsedCode IS NOT NULL THEN 'Yes' ELSE 'No' END AS 'Is Lapsed'
	,LG.Fin_World_Region AS [World Region]
	,LG.Fin_Region AS Region
	,LG.Fin_Market AS Market
	,LG.apuk_countryid_name AS Country
	,DATEPART(yyyy,ENR.[Enrolment Date]) AS ENRYear
	,DATEPART(mm,ENR.[Enrolment Date]) AS ENRMonth
	,CASE 
		WHEN ENR.[Application Type]= 'Direct Entry' AND ENR.[Enrolment Date] IS NULL
			THEN COALESCE (DATENAME(yyyy,ENR.[Election Date]),DATENAME(yyyy,ENR.[Created Date]))
		ELSE COALESCE(DATENAME(yyyy,ENR.[Enrolment Date]),DATENAME(yyyy,ENR.[Created Date]))
	END AS [#ENRYear]
	,CASE 
		WHEN ENR.[Application Type]= 'Direct Entry' AND ENR.[Enrolment Date] IS NULL
			THEN COALESCE (DATENAME(mm,ENR.[Election Date]),DATENAME(mm,ENR.[Created Date]))
		ELSE COALESCE(DATENAME(mm,ENR.[Enrolment Date]),DATENAME(mm,ENR.[Created Date]))
	END AS [#ENRMonth],
	ENRL.[ENR ID] AS 'Latest ENR ID'
	,CASE apuk_corporateenrolment  
		WHEN 'True' THEN 'Yes'
		WHEN 'False' THEN 'No'
		ELSE 'No'	
	END AS [Corporate Enrolment]
FROM synapse_ce.vwEnrolments ENR
LEFT JOIN CE.vwEnrolments_Last ENRL
	ON ENR.[Contact ID] = ENRL.[Contact ID]
LEFT JOIN [synapse_ce].[tblContact_BI] CON
	ON ENR.[Contact ID] = CON.ContactId
LEFT JOIN [CE].[vwLocalGroup] LG
	ON CON.[rics_localgroupid] = LG.apuk_localgroupid
WHERE 1=1

/* No exclusions on Route as in the ENR demographics
AND [Route ID] NOT IN 
	(
	'00000000-0000-0000-0000-000000000000', --APC Other
	'00000000-0000-0000-0000-000000000000', --APC Prelim,
	'00000000-0000-0000-0000-000000000000', --APC Research,
	'00000000-0000-0000-0000-000000000000', --APC Structured Training 12,
	'00000000-0000-0000-0000-000000000000', --APC Structured Training 24,
	'00000000-0000-0000-0000-000000000000', --Associate Assessment,
	'00000000-0000-0000-0000-000000000000', --Senior Professional Assessment – 2017,
	'00000000-0000-0000-0000-000000000000' --Specialist Assessment
	
	)	
*/
/*
	AND ENR.[Application Type ID] NOT IN (
		 '00000000-0000-0000-0000-000000000000' --Chartered Alternative Designation
		,'00000000-0000-0000-0000-000000000000' --Alternative Designation
		,'00000000-0000-0000-0000-000000000000' --Apprenticeship
		,'00000000-0000-0000-0000-000000000000' --Credential Application
		,'00000000-0000-0000-0000-000000000000' --Fellowship
		,'00000000-0000-0000-0000-000000000000' --Honorary
		,'00000000-0000-0000-0000-000000000000' --Re-admission
		,'00000000-0000-0000-0000-000000000000' --Scheme
		,'00000000-0000-0000-0000-000000000000' --Student
		)
*/
AND ENR.[State Code] = 0
--AND [Enrolment Date] IS NOT NULL  --we are including DE so this does not apply, it does in ENR Demo
--AND NOT([Election Date] IS NULL AND [End Date] IS NOT NULL) --we are including DE so this does not apply, it does in ENR Demo
)

SELECT *
--DISTINCT [Route],[Application Type]
FROM cteENR ENR
WHERE 1=1 
--AND ENR.[Contact No] = '0000000'
--AND ENR.[election date] IS NULL
--AND [Enrolment Date] IS NULL
--AND [Application Type] = 'Direct Entry'
--AND ENR.[End Date] IS NULL
--ORDER BY [Route]













/******************************WORKING QUERIES****************************************************************
CREATE VIEW CE.vwContact_Candidate
AS
SELECT TOP 10 * FROM CE.vwContact -- was going to use [synapse_ce].[tblContact_BI] as in other vwContact_XXXX views but this view was still quite efficient
WHERE [Rics_MemberGrade] = 000000000


SELECT TOP 10 * FROM CE.vwEnrolments
WHERE [Contact ID] IN (SELECT [Contact ID] FROM CE.vwContact 
WHERE [Rics_MemberGrade] = 000000000)


SELECT CC.[ContactID] AS CC,CC.Rics_contactno, E.[Contact ID]AS E 
FROM CE.vwContact_Candidate CC
INNER JOIN [synapse_ce].[vwEnrolments] E  --Not using CE.vwEnrolments as it's restrictive on Route and Application Type
	ON CC.ContactId = E.[Contact ID]
WHERE 1=1
AND CC.[Rics_MemberGrade] = 000000000 --Only Candidates
AND E.[End Date] IS NULL  --Haven't been elected, changed route or dropped out

SELECT DISTINCT [application type]
FROM synapse_ce.vwEnrolments

SELECT DISTINCT [Route]
FROM synapse_ce.vwEnrolments


SELECT * FROM CE.vwLocalGroup

SELECT  * FROM synapse_ce.vwEnrolments WHERE [Application Type] = 'Direct Entry'

--Duplicates
SELECT 
ENR.[Contact No], COUNT(ENR.[Contact No]) AS [Count]
FROM cteENR ENR
GROUP BY ENR.[Contact No] 
HAVING COUNT(ENR.[Contact No])>1
**********************************************************************************************/

--View for Candidate Enrolment records CE.vwEnrolment_Candidate_Last
CREATE VIEW [CE].[vwEnrolment_Candidate_Last]
AS
----Chooses the Latest Enrolment Record for each Contact in order to measure 'Latest Enrolment'
--	WITH CTE AS (
--	SELECT
--	 [ENR ID]
--	,ROW_NUMBER() OVER (PARTITION BY [Contact ID] ORDER BY [Enrolment Date] DESC) AS ROWNUM
--	FROM CE.vwEnrolments
--	)
WITH
cteENR
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
	,CAST(ENR.[Election Date] AS DATE) AS [Election Date]
	,ENR.[Enrolment Date]
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
	,CASE ISNULL (ENR.[Submission Received],'')
		WHEN '' THEN 'No'
		ELSE 'Yes'
	END AS HasSubmissionRecdDate --Added DBA/PS 18/04/2024 - U/S 56614
	,CASE ISNULL(ENR.[End Date],'')
		WHEN '' THEN 'Yes'
		ELSE 'No'
	END AS IsActive
	,CASE ISNULL (ENR.[expected_final_date],'')
		WHEN '' THEN 'No'
		ELSE 'Yes'
	END AS HasExpectedFinalDate --Added DBA/PS 10/05/2024 - U/S 54525
	,DATEDIFF(dd,ENR.[ARC Last Logged in],GETDATE()) AS 'Days Since ARC Login'
	,CON.[rics_localgroupid] AS 'Local Group ID'
	,CON.[rics_localgroupidName] AS 'Local Group'  --Added DBA/PS 10/05/2024 - U/S 54525
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
		WHEN ENR.[Application Type]= 'Direct Entry'
			THEN 'DE'
		WHEN ENR.[Application Type] IN ('APC','APC12','APC24','Assoc','SPA')
			THEN 'APC Related'
		ELSE 'Other'
	END AS AppTypeGroup
	,CASE
		WHEN ENR.[Election Date] IS NULL
			THEN NULL
		ELSE DATEDIFF(dd,ENR.[Enrolment Date],ENR.[Election Date]) 
	END AS [Days To Election]
	,MD1.LocalizedLabel AS 'ARC Assessment Status'
	,CASE ENR.[Approved By Counsellor]
		WHEN 1 THEN 'Yes'
		WHEN 0 THEN 'No'
	END AS 'Approved By Counsellor'
	,CAST(ENR.[Competency Selection Completed Date] AS DATE) AS 'Competency Selection Completed Date'
	,MD2.LocalizedLabel AS 'Case Study Status'
	,ENR.[Case Study Feedback] AS 'Case Study Feedback'
	,MD3.LocalizedLabel AS 'Summary of Experience Status'
	,ENR.[Summary of Experience Feedback] AS 'Summary of Experience Feedback'
	,CAST(ENR.[Preliminary Submission Received] AS DATE) AS 'Preliminary Submission Received'
	,CAST(ENR.[Submission Received] AS DATE) AS 'Submission Received'
	,ROW_NUMBER() OVER (PARTITION BY [Contact ID] ORDER BY [Enrolment Date] DESC)AS ROWNUM
	,CASE apuk_corporateenrolment  
		WHEN 'True' THEN 'Yes'
		WHEN 'False' THEN 'No'
		ELSE 'No'	
	END AS [Corporate Enrolment] --Added by PS 31/10/2024 - for Assesments (and Candidate Support seperately requested 30/10/2024) - U/S 66020
	,apuk_otherdetails AS [Other Details] --Added by PS 31/10/2024 - request from Enrolments Team via Amanda Smith 30/10/2024 (RISE indicator)
	,ParentCustomerIdName --Added by PS 05/12/2024 to support Candidate Engagement Stats
	,EMailAddress1 --Added by PS 05/12/2024 to support Candidate Engagement Stats

	--Added PS 21/02/2025 ref U/S 72092
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
	,CASE ISNULL(RR.apuk_apprentice,0) --Added DBA/PS 19/08/2025 to enable 'Apprentice' flag filter
		WHEN 'True' THEN 'Yes'
		WHEN 'False' THEN 'No'
		ELSE 'No'
	END AS Apprentice
FROM synapse_ce.vwEnrolments ENR
LEFT JOIN [synapse_ce].[tblContact_BI] CON
	ON ENR.[Contact ID] = CON.ContactId
LEFT JOIN  synapse_ce.vwRicsRecord RR  --Added DBA/PS 19/08/2025 to enable 'Apprentice' flag filter
		ON CON.[ContactID] = RR.apuk_contactid
LEFT JOIN [CE].[vwLocalGroup] LG
	ON CON.[rics_localgroupid] = LG.apuk_localgroupid
LEFT JOIN [synapse_ce].[vwGlobalOptionSetMetadata] MD1
	ON MD1.[Option] = ENR.[ARC Assessment Status]
	AND MD1.OptionSetName = 'apuk_arcassessmentstatus'
LEFT JOIN [synapse_ce].[vwGlobalOptionSetMetadata] MD2
	ON MD2.[Option] = ENR.[Case Study Status]
	AND MD2.OptionSetName = 'apuk_casestudystatus'
LEFT JOIN [synapse_ce].[vwGlobalOptionSetMetadata] MD3
	ON MD3.[Option] = ENR.[Summary of Experience Status]
	AND MD3.OptionSetName = 'apuk_summaryofexperiencestatus'
	
WHERE ENR.[State Code] = 0


/* No exclusions on Route as in the ENR demographics */
/* No exclusions on Application Type as there are in the ENR demographics*/

--AND [Enrolment Date] IS NOT NULL  --we are including DE so this does not apply, it does in ENR Demo
--AND NOT([Election Date] IS NULL AND [End Date] IS NOT NULL) --we are including DE so this does not apply, it does in ENR Demo
)

SELECT *
FROM cteENR ENR
WHERE
ROWNUM = 1
		--)

--For testing scenarios
--AND ENR.[Contact No] = '0000000'
--AND ENR.[election date] IS NULL
--AND [Enrolment Date] IS NULL
--AND [Application Type] = 'Direct Entry'
--AND ENR.[End Date] IS NULL
--ORDER BY [Route]











/******************************WORKING QUERIES****************************************************************
SELECT * FROM CE.vwEnrolment_Candidate_Last

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

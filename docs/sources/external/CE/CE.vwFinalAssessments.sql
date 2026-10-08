CREATE VIEW CE.vwFinalAssessments
AS


SELECT
ENR.[Contact No]
,CON.[ContactID]
,CON.[FirstName] AS 'Forename'
,CON.[LastName] AS 'Surname'
,CON.[MemberGrade_Description] AS 'Member Grade'
,CAST(CON.[Rics_LapsedDate] AS DATE) AS 'Lapsed Date'
,CON.[Rics_LapsedCode] AS 'Lapsed Code'
,CON.[Rics_LapsedCode_Description] AS 'Lapsed Reason'
,CASE WHEN CON.Rics_LapsedCode IS NOT NULL THEN 'Yes' ELSE 'No' END AS 'Is Lapsed'
,ENR.[ENR ID]
,ENR.[Enrolment Type]
,ENR.[Submission Received] AS [Latest Submission Received]
,ENR.Pathway
,ENR.[Route]
,ENR.[Application Type]
,AMT.apuk_datetime AS [Assessment Date and Time]
,CAST(AMT.apuk_datetime AS DATE) AS [Assessment Date]
,AMT.apuk_assessmentid AS [Assessment ID]
,CASE
	WHEN GOM1.LocalizedLabel = 'Pass' THEN 1
	ELSE 0
END AS IsPass
,CASE
	WHEN GOM1.LocalizedLabel = 'Refer' THEN 1
	ELSE 0
END AS IsRefer
,GOM1.LocalizedLabel AS [Final Outcome]
,GOM2.LocalizedLabel AS [Assessment Method]
,GOM3.LocalizedLabel AS [Assessment Type]
,GOM4.LocalizedLabel AS [ARC Assessment Status]
,LG.Fin_World_Region AS [World Region]
,LG.Fin_Region AS Region
,LG.Fin_Market AS Market
,LG.apuk_countryid_name AS Country

FROM synapse_ce.vwEnrolments ENR
LEFT JOIN synapse_ce.apuk_assessment AMT
	ON AMT.apuk_enrolmentID = ENR.[ENR ID]
	AND AMT.apuk_candidateid = ENR.[Contact id]
LEFT JOIN [CE].[vwGlobalOptionSetMetadata] GOM1
	ON GOM1.[Option] = AMT.apuk_finaloutcome
	AND GOM1.OptionSetName = 'apuk_finaloutcome'
LEFT JOIN [CE].[vwGlobalOptionSetMetadata] GOM2
	ON GOM2.[Option] = AMT.apuk_assessmentmethod
	AND GOM2.OptionSetName = 'apuk_assessmentmethod'
	AND GOM2.EntityName = 'apuk_assessment' 
LEFT JOIN [CE].[vwGlobalOptionSetMetadata] GOM3
	ON GOM3.[Option] = AMT.apuk_assessmenttype
	AND GOM3.OptionSetName = 'apuk_assessmenttype'
LEFT JOIN [CE].[vwGlobalOptionSetMetadata] GOM4
	ON GOM4.[Option] = ENR.[ARC Assessment Status]
	AND GOM4.OptionSetName = 'apuk_arcassessmentstatus'
LEFT JOIN [synapse_ce].[tblContact_BI] CON
	ON ENR.[Contact ID] = CON.ContactId
LEFT JOIN [CE].[vwLocalGroup] LG
	ON CON.[rics_localgroupid] = LG.apuk_localgroupid
WHERE 1=1
--AND ENR.[Contact No] = '0000000'
AND ENR.[state] = 'Active'
AND AMT.statecode = 0
--AND ENR.[Enrolment Type] LIKE '%Direct Entry%' --2 DE and 54 Asoc DE










/***************************************WORKING QUERIES********************************************


SELECT TOP 10 * FROM synapse_ce.vwEnrolments ENR
WHERE [Contact No] = '0000000'  --00000000-0000-0000-0000-000000000000 - contactid

SELECT TOP 10 * FROM synapse_ce.apuk_assessment AMT
WHERE apuk_candidateid = '00000000-0000-0000-0000-000000000000' 
AND statecode = 0

SELECT * FROM [CE].[vwGlobalOptionSetMetadata] GOM
WHERE OptionSetName = 'apuk_assessmentmethod'

SELECT DISTINCT [Enrolment Type] FROM synapse_ce.vwEnrolments

SELECT * FROM CE.vwFinalAssessments
WHERE [Latest Submission Received] IS NULL
AND [Assessment Date] IS NOT NULL

--[Contact No] = '0000000'

*******************************************************************************/

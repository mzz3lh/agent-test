CREATE VIEW [CE].[vwEQSAssessmentStats]
AS

WITH cteAll
AS
(

SELECT A.apuk_assessmentid
,A.apuk_assessmentmethod
,A.apuk_assessmenttype
,A.apuk_datetime
,CAST(apuk_datetime AS DATE) AS AssessmentDate
,DATEPART(Year,apuk_datetime) AS [Assessment Year]
,A.apuk_finaloutcome
,GOM1.LocalizedLabel AS [Final Outcome]
,GOM2.LocalizedLabel AS [Assessment Method]
,GOM3.LocalizedLabel AS [Assessment Type]
,ISNULL(GOM4.LocalizedLabel, 'Not Given') AS [Gender]
,A.apuk_dateresultissued
,A.createdon
,A.createdby
,A.apuk_chairmanresultsreceiveddate
,A.apuk_resultlastupdatedbyid
,A.apuk_resultapprovedon
,A.apuk_resultapprovedby
,a.apuk_chairmanid
,E.apuk_contactid
,E.apuk_routeid
,E.apuk_routeidname AS [Route]
,E.apuk_pathwayid
,P.Pathway
,E.apuk_applicationtypeid
,E.apuk_ricsrecordid
,E.apuk_enrolmentenddate
,E.apuk_enrolmentdate
,E.apuk_electiondate
,C.lastname
,C.firstname
,C.apuk_membergrade
,C.apuk_contactnumber AS [Contact Number]
,C.apuk_localgroupid
,C.gendercode
,C.apuk_genderidentity
,C.apuk_preferredaddresscountryid
,C.apuk_region
,LG.apuk_Regionid_name AS [Region]
,LG.apuk_WorldRegionid_name AS [World Region]
,LG.apuk_subregion_name AS [Sub-Region]
,LG.apuk_name AS [Local Group]
FROM synapse_ce.apuk_assessment A
INNER JOIN synapse_ce.apuk_enrolment E
	ON A.apuk_enrolmentid = E.apuk_enrolmentid
LEFT JOIN synapse_ce.contact C
	ON A.apuk_candidateid = C.contactid
LEFT JOIN [CE].[vwGlobalOptionSetMetadata] GOM1
	ON GOM1.[Option] = A.apuk_finaloutcome
	AND GOM1.OptionSetName = 'apuk_finaloutcome'
LEFT JOIN [CE].[vwGlobalOptionSetMetadata] GOM2
	ON GOM2.[Option] = A.apuk_assessmentmethod
	AND GOM2.OptionSetName = 'apuk_assessmentmethod'
	AND GOM2.EntityName = 'apuk_assessment' 
LEFT JOIN [CE].[vwGlobalOptionSetMetadata] GOM3
	ON GOM3.[Option] = A.apuk_assessmenttype
	AND GOM3.OptionSetName = 'apuk_assessmenttype'
LEFT JOIN [CE].[vwOptionSetMetadata] GOM4
	ON GOM4.[Option] = C.gendercode
	AND GOM4.OptionSetName = 'gendercode'
LEFT JOIN CE.vwPathway P
	ON P.[Pathway ID] = E.apuk_PathwayId
	AND P.[State] = 0
LEFT JOIN [CE].[vwLocalGroup] LG
	ON C.[apuk_localgroupid] = LG.apuk_localgroupid
WHERE A.statecode = 0
AND DATEPART(Year,apuk_datetime) BETWEEN 2018 AND DATEPART(Year, GETDATE())  -- -1 removed to include up to date stats DBA/PS 22/08/2025
AND A.apuk_assessmentmethod NOT IN (200000003,200000004) --Appeal, Vetting
AND A.apuk_assessmenttype IN (200000000,200000008,200000006) --Candidate Final Assessment, Associate Assessment, Prelim Assessment 
--AND A.apuk_datetime <= '2023-12-31'--only used to compare stats for 2023 pack
AND E.apuk_applicationtypeid NOT IN (
									 '00000000-0000-0000-0000-000000000000' --Fellowship
								   , '00000000-0000-0000-0000-000000000000' --Chartered Alternative Designation
								   , '00000000-0000-0000-0000-000000000000' --Alternative Designation
								     )
AND E.apuk_routeid <> '00000000-0000-0000-0000-000000000000' --Associate Direct Entry
)

SELECT * FROM cteAll

--Appeals based on the AF XML

CREATE VIEW CE.vwEQSAssessmentAppeals
AS

SELECT A.apuk_assessmentid,
A.apuk_assessmentmethod,
A.apuk_assessmenttype,
A.apuk_datetime AS [Assessment Date],
DATEPART(yyyy,A.apuk_datetime) AS [Assessment Year],--Added for yearly summary, not in AF
A.apuk_finaloutcome,
GOM1.LocalizedLabel AS [Final Outcome],
GOM2.LocalizedLabel AS [Assessment Method],
GOM3.LocalizedLabel AS [Assessment Type],
GOM4.LocalizedLabel AS [Gender],
A.apuk_electiondate AS ElectionDate_Assessment,
A.apuk_dateresultissued AS [Date Result Issued],
A.createdon,
A.createdby,
E.apuk_contactid,
E.apuk_routeid,
E.apuk_pathwayid,
P.Pathway,
E.apuk_applicationtypeid,
E.apuk_ricsrecordid,
E.apuk_enrolmentenddate AS [Enrolment End Date],
E.apuk_enrolmentdate AS [Enrolment Date],
E.apuk_electiondate AS ElectionDate_Enrolment,
C.lastname AS [Last Name],
C.firstname AS [First Name],
C.apuk_membergrade,
C.apuk_contactnumber AS [Contact Number],
C.apuk_localgroupid,
C.gendercode,
C.apuk_genderidentity,
C.apuk_preferredaddresscountryid,
LG.apuk_Regionid_name AS [Region],
LG.apuk_WorldRegionid_name AS [World Region],
LG.apuk_subregion_name AS [Sub-Region],
LG.apuk_name AS [Local Group],
LG.apuk_countryid_name AS Country

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
--AND DATEPART(Year,apuk_datetime) BETWEEN 2018 AND DATEPART(Year, GETDATE())-1
AND A.apuk_finaloutcome IS NOT NULL
AND A.apuk_assessmentmethod = 200000003
AND A.apuk_assessmenttype NOT IN 
	(200000001,200000003,200000007,200000002,200000004)
AND E.apuk_applicationtypeid NOT IN
	('00000000-0000-0000-0000-000000000000', --Fellowship
	'00000000-0000-0000-0000-000000000000', --Chartered Alternative Designation
	'00000000-0000-0000-0000-000000000000') --Alternative Designation
AND E.apuk_routeid <> '00000000-0000-0000-0000-000000000000' --Associate Direct Entry

--AND DATEPART(Year,apuk_datetime) = 2023

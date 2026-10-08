CREATE VIEW [dbo].[vwDataAssessorAvailability]
AS


WITH cteAAData
AS
(
SELECT  AA.Created_On,
AA.rics_sessionidName , 
AA.Rics_DayOne, AA.Rics_DayTwo , AA.Rics_DayThree,AA.Rics_DayFour, AA.Rics_DayFive, AA.Rics_DaySix,
AA.Rics_DateOne, AA.Rics_DateTwo , AA.Rics_DateThree, AA.Rics_DateFour, AA.Rics_DateFive ,AA.Rics_DateSix,
AV.rics_venueidname,  AV.rics_fullname, AV.rics_description, 
fc.rics_contactno,
ab.rics_name as Specialism,
p.rics_name as Pathway,A.ricsv2_FromDate,  A.ricsv2_ToDate,a.ricsv2_MaximumDays,
A.ricsV2_MaxWrittenAssessments AS MaxWrittenAssessments,
CASE A.rics_AvailabilityAmPm
	WHEN '000000000' THEN 'All Day'
	WHEN '000000000' THEN 'AM Only'
	WHEN '000000000' THEN 'PM Only'
END AS AvailabilityAmPM,
A.Rics_Chairman AS Chairman, A.Rics_Auditor AS Auditor,
fc.mobilephone,fc.rics_memberGrade,fc.rics_Honours,
aa.rics_assessorid,
--,0 AS AssessorRoles,
A.Rics_Languages AS Languages,  --one to many
aop.rics_name as AreaofPractice, --one to many
ind.rics_name as IndustrySector,  --Additional columns for QS only  --one to many
rc.Rics_Country as IntExpCountry

--INTO #AssessorAvailability
FROM  dbo.vwRics_assessoravailability AA 
INNER JOIN dbo.vwRics_assessor A 
	ON AA.rics_assessorid  =  A.rics_assessorid
LEFT JOIN dbo.vwRics_centre AV  
	ON AA.rics_sessionid  =  AV.rics_centreid
INNER JOIN  dbo.vwContact FC 
	ON A.rics_contactid  =  FC.contactid
LEFT JOIN dbo.vwrics_rics_specialism_rics_assessor  rics_rics_specialism_rics_assessor3   --need to add
	ON A.rics_assessorid  =  rics_rics_specialism_rics_assessor3.rics_assessorid
left JOIN dbo.vwRics_specialism  ab --need to add
	ON rics_rics_specialism_rics_assessor3.rics_specialismid  =  ab.rics_specialismid
INNER JOIN dbo.vwrics_rics_pathway_rics_assessor  AP --need to add
	ON A.rics_assessorid  = AP.rics_assessorid
INNER JOIN  dbo.vwRics_pathway P   --need to add
	ON  AP.rics_pathwayid = P.rics_pathwayid
LEFT JOIN [dbo].[vwrics_rics_assessor_rics_industrysector] ais  --need to add
	ON A.rics_assessorId = ais.rics_assessorId
LEFT JOIN [dbo].[vwRics_industrysector] ind  --need to add
	ON ais.rics_industrySectorId = ind.rics_industrySectorId
LEFT JOIN dbo.[vwrics_rics_areaofpractice_rics_assessor] aaop  --need to add
	ON A.Rics_AssessorID = aaop.Rics_AssessorID
LEFT JOIN [dbo].[vwRics_areaofpractice] aop  --need to add
	ON aop.Rics_AreaOfPracticeID = aaop.Rics_AreaOfPracticeId
LEFT JOIN dbo.[vwrics_rics_assessor_rics_country] arc   --need to add
    ON A.Rics_assessorId = arc.Rics_AssessorID
LEFT JOIN dbo.vwRics_country rc  --need to add
    ON arc.rics_countryid = rc.Rics_countryId


WHERE  AA.statecode = 0
AND AV.created_on >DATEADD(yy,-1,GETDATE())--'2016-11-01';
--AND ab.statecode = 0
),

cteRoles
AS
(
SELECT DISTINCT C.rics_ContactNo,RA.rics_assessorId,RAR.Rics_assessorroleId
FROM dbo.vwcontact C
INNER JOIN cteAAData AA--#AssessorAvailability AA
	ON AA.rics_contactno = C.rics_contactNo
LEFT JOIN dbo.vwrics_assessor RA
	ON C.contactid = RA.rics_contactID
LEFT JOIN dbo.vwrics_assessorrole RAR
	ON RA.Rics_assessorId = RAR.rics_assessorid
WHERE RAR.statecode = 0
GROUP BY C.Rics_contactno,RA.rics_assessorId,RAR.Rics_assessorroleId
),



cteNoOfRoles
AS
(
SELECT rics_contactNo,COUNT(rics_contactNo) AS NoOfAssessorRoles
FROM cteRoles
WHERE rics_assessorRoleid IS NOT NULL
GROUP BY rics_contactNo
)


SELECT DISTINCT AA.*, R.NoOfAssessorRoles
FROM cteAAData AA
LEFT JOIN cteNoOfRoles R
ON AA.rics_contactno = R.rics_contactNo

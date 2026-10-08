/****** Object:  View [dbo].[vwDataAssessorAvailability]    Script Date: 20/06/2022 14:19:09 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO


CREATE PROCEDURE [CE].[uspD365DataAssessorAvailability]
AS

BEGIN


DROP TABLE CE.tblD365DataAssessorAvailability;

WITH cteAAData
AS
(
SELECT  AA.Created_On,
AA.rics_sessionidName , 
------AA.Rics_DayOne, AA.Rics_DayTwo , AA.Rics_DayThree,AA.Rics_DayFour, AA.Rics_DayFive, AA.Rics_DaySix,  --NOT IN CE
AA.Rics_DateOne, ------AA.Rics_DateTwo , AA.Rics_DateThree, AA.Rics_DateFour, AA.Rics_DateFive ,AA.Rics_DateSix,  --NOT IN CE
AV.rics_venueidname,  
AV.rics_name AS rics_fullname,--WAS AV.rics_fullname, 
AV.rics_description, 
FC.rics_contactno,
--ab.rics_name as Specialism,
--p.rics_name as Pathway,
A.ricsv2_FromDate,  
A.ricsv2_ToDate,
AA.apuk_maximumnumberofdays, -- WAS A.ricsv2_MaximumDays,
0 AS MaxNoOfDaysCalc,
A.ricsV2_MaxWrittenAssessments AS MaxWrittenAssessments,
CASE AA.apuk_availabilityhours-- WAS A.rics_AvailabilityAmPm
	WHEN '000000000' THEN 'All Day'
	WHEN '000000000' THEN 'AM'
	WHEN '000000000' THEN 'PM'
END AS AvailabilityAmPM,
A.Rics_Chairman AS Chairman, 
A.Rics_Auditor AS Auditor,
FC.mobilephone,
FC.rics_memberGrade,
FC.rics_Honours,
AA.rics_assessorid,
------A.Rics_Languages AS Languages,  --one to many
AOP.rics_name as AreaofPractice, --one to many
IND.rics_name as IndustrySector,  --Additional columns for QS only  --one to many
RC.Rics_Country as IntExpCountry,
CASE AA.apuk_availabilitytype  --Added DBA/PS 01/02/2023 - request from A.Vokes for D365 Assessor Availability scheduling report
	WHEN 200000000 THEN 'Not Available'
	WHEN 200000001 THEN 'Date'
	WHEN 200000002 THEN 'Date Range'
END AS AvailabilityType


FROM  CE.vwRics_assessoravailability AA 
INNER JOIN CE.vwRics_assessor A 
	ON AA.rics_assessorid  =  A.Rics_ContactID--WAS A.rics_assessorid
LEFT JOIN CE.vwRics_centre AV  
	ON AA.rics_sessionid  =  AV.rics_centreid
INNER JOIN CE.vwContact FC 
	ON A.rics_contactid  =  FC.contactid
	AND AA.rics_assessorid  =  FC.ContactID
--LEFT JOIN dbo.vwrics_rics_specialism_rics_assessor  RRSRA
--   ON A.rics_assessorid  =  RRSRA.rics_assessorid
----LEFT JOIN [CE].[vwrics_rics_specialism_contact] RSC
--	--ON RSC.Contactid = FC.ContactId  --replaces dbo.vwrics_rics_specialism_rics_assessor DBA/PS 27/02/2023
--LEFT JOIN CE.vwRics_specialism  ab 
--	ON RRSRA.rics_specialismid  =  ab.rics_specialismid
--INNER JOIN CE.vwRics_AssessorPathway AP     -- WAS dbo.vwrics_rics_pathway_rics_assessor  AP 
--	ON A.rics_assessorid  = AP.apuk_assessorid
--INNER JOIN  CE.vwRics_pathway P   
--	ON  AP.apuk_pathwayid = P.rics_pathwayid
LEFT JOIN [CE].[vwrics_rics_assessor_rics_industrysector] AIS  
	ON A.rics_assessorId = AIS.apuk_assessorid
LEFT JOIN [CE].[vwRics_industrysector] IND  
	ON AIS.apuk_industrysectorid = IND.rics_industrySectorId
LEFT JOIN CE.[vwrics_rics_areaofpractice_rics_assessor] AAOP  
	ON A.Rics_AssessorID = AAOP.apuk_assessorid
LEFT JOIN [CE].[vwRics_areaofpractice] AOP  
	ON AOP.Rics_AreaOfPracticeID = AAOP.apuk_areaofpracticeid
LEFT JOIN CE.[vwrics_rics_assessor_rics_country] ARC   
    ON A.Rics_assessorId = ARC.apuk_assessorid
LEFT JOIN CE.vwRics_country rc  
    ON ARC.rics_countryid = RC.Rics_countryId


WHERE  AA.statecode = 0
AND AA.Rics_DateOne >=GETDATE()
--AND ISNULL(AV.Created_On,GETDATE()) >DATEADD(yy,-1,GETDATE())--'2016-11-01';
--AND ISNULL(A.ricsv2_ToDate,'') =''
--AND ab.statecode = 0

AND A.ricsv2_FromDate IS NOT NULL
AND A.ricsv2_ToDate IS NULL

--AND FC.Rics_contactno = '0000000'
)

SELECT * 
INTO #AssessorAvailability
FROM cteAAData;

WITH
cteRoles
AS
(
SELECT DISTINCT C.rics_ContactNo,
RA.rics_assessorId,
RAR.Rics_assessorroleId
FROM CE.vwcontact C
INNER JOIN #AssessorAvailability AA--cteAAData AA--
	ON AA.rics_contactno = C.rics_contactNo
LEFT JOIN CE.vwrics_assessor RA
	ON C.contactid = RA.rics_contactID
LEFT JOIN CE.vwrics_assessorrole RAR
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
INTO CE.tblD365DataAssessorAvailability
FROM #AssessorAvailability AA--cteAAData AA
LEFT JOIN cteNoOfRoles R
ON AA.rics_contactno = R.rics_contactNo
END


--SELECT * FROM CE.tblD365DataAssessorAvailability#

CREATE VIEW [dbo].[vwRptAssessorAvailability]
AS



WITH
cteSp AS
(
SELECT DISTINCT Rics_ContactNo,specialism 
FROM dbo.vwDataAssessorAvailability
),

cteSpList AS
(
SELECT Rics_ContactNo , STRING_AGG([specialism], ', ') AS Specialism
FROM cteSp
GROUP BY Rics_ContactNo
),



ctePwy AS
(
SELECT DISTINCT Rics_ContactNo,Pathway 
FROM dbo.vwDataAssessorAvailability
),

ctePwyList AS

(
SELECT Rics_ContactNo , STRING_AGG([Pathway], ', ') AS Pathway
FROM ctePwy
GROUP BY Rics_ContactNo
),


cteISec AS
(
SELECT DISTINCT Rics_ContactNo,IndustrySector 
FROM dbo.vwDataAssessorAvailability
),

cteISecList AS

(
SELECT Rics_ContactNo , STRING_AGG([IndustrySector], ', ') AS IndustrySector
FROM cteISec
GROUP BY Rics_ContactNo
),


cteAOP AS
(
SELECT DISTINCT Rics_ContactNo, AreaOfPractice 
FROM dbo.vwDataAssessorAvailability
),

cteAOPList AS

(
SELECT Rics_ContactNo , STRING_AGG([AreaofPractice], ', ') AS AreaOfPractice
FROM cteAOP
GROUP BY Rics_ContactNo
),


cteLang AS
(
SELECT DISTINCT Rics_ContactNo, Languages 
FROM dbo.vwDataAssessorAvailability
),

cteLangList AS

(
SELECT Rics_ContactNo , STRING_AGG([Languages], ', ') AS Languages
FROM cteLang
GROUP BY Rics_ContactNo
),


cteIntExp
     AS (
     SELECT DISTINCT
            Rics_ContactNo,
            IntExpCountry
     FROM dbo.vwDataAssessorAvailability),

 cteIntExpList
     AS 
	 (
SELECT Rics_ContactNo , STRING_AGG([IntExpCountry], ', ') AS IntExpCountry
FROM cteIntExp
GROUP BY Rics_ContactNo
)


/*****************************************
Get the report data
*****************************************/
SELECT DISTINCT 
[rics_sessionidname] AS [Session Name]
,CASE[rics_dayone] 
	WHEN 1 THEN 'Green'
	ELSE 'Red'
	END AS [Day One]
,CASE[Rics_DayTwo] 
	WHEN 1 THEN 'Green'
	ELSE 'Red'
	END AS [Day Two]
,CASE[Rics_DayThree] 
	WHEN 1 THEN 'Green'
	ELSE 'Red'
	END AS [Day Three]
,CASE[Rics_DayFour] 
	WHEN 1 THEN 'Green'
	ELSE 'Red'
	END AS [Day Four]
,CASE[Rics_DayFive] 
	WHEN 1 THEN 'Green'
	ELSE 'Red'
	END AS [Day Five]
,CASE[Rics_DaySix] 
	WHEN 1 THEN 'Green'
	ELSE 'Red'
	END AS [Day Six]
,[rics_dateone] AS [Date One]
,[rics_datetwo] AS [Date Two]
,[rics_datethree] AS [Date Three]
,[rics_datefour] AS [Date Four]
,[rics_datefive] AS [Date Five]
,[rics_datesix] AS [Date Six]
,ISNULL([rics_venueidname],'') AS [Venue Name]
,ISNULL([rics_fullname],'') AS [Full Name]
,ISNULL([rics_description],'') AS [Description]
,ISNULL(cteMain.rics_contactno,'') AS [Contact No]
,ISNULL(cteSpList.Specialism,'') AS Specialisms
,ISNULL(ctePwyList.Pathway,'') AS Pathways
,ISNULL(cteLangList.Languages,'') AS Languages
,ISNULL(cteAOPList.AreaOfPractice,'') AS [Areas of Practice]
,ISNULL(cteISecList.IndustrySector,'') AS [Industry Sectors]
,[ricsv2_fromdate] AS [From Date]
,[ricsv2_todate] AS [To Date]
,[ricsv2_maximumdays] AS [Max. No of days]
,MaxWrittenAssessments AS [Max. No of Written Assessments]
,ISNULL(AvailabilityAmPM,'') AS [Availability AM/PM]
,ISNULL(FC.Salutation,'') AS Salutation
--,SM.Value AS Rics_Title  --Look into this
,ISNULL(FC.FirstName,'') AS [First Name]
,ISNULL(FC.LastName,'') AS [Last Name]
,ISNULL(FC.AccountIDName,'') AS [Account Name]
,ISNULL(FC.EmailAddress1,'') AS [EMail]
,[Chairman] 
,[Auditor]
--,FC.rics_corespadd_coname  --needs to be added
,ISNULL(FC.address1_Line1,'') AS [Address Line 1]
,ISNULL(FC.address1_Line2,'') AS [Address Line 2]
,ISNULL(FC.Address1_Line3,'') AS [Address Line 3]
,ISNULL(FC.Address1_City,'') AS [City]
--,FC.address1_county  --needs to be added
,ISNULL(FC.Address1_PostalCode,'') AS [Postal Code]
,ISNULL(FC.Address1_Country,'') AS Country
,cteMain.[mobilephone] AS [Mobile Phone]
,SM1.[Value] AS [Member Grade]
,cteMain.[rics_Honours] AS [Honours]
,cteMain.Created_On AS AvGiven
,cteMain.NoOfAssessorRoles AS [No of Assessor Roles]
,ISNULL(cteIntExpList.IntExpCountry,'') AS InternationalExperience
,RG.Rics_ReportingSubWorldRegion AS [Sub-World Region]

FROM dbo.vwDataAssessorAvailability cteMain
LEFT JOIN cteSpList
ON cteMain.rics_contactNo = cteSpList.rics_contactNo
LEFT JOIN ctePwyList
ON cteMain.rics_contactNo = ctePwyList.rics_contactNo
LEFT JOIN cteLangList
ON cteMain.rics_contactNo = cteLangList.rics_contactNo
LEFT JOIN cteAOPList
ON cteMain.rics_contactNo = cteAOPList.rics_contactNo
LEFT JOIN cteISecList
ON cteMain.rics_contactNo = cteISecList.rics_contactNo
LEFT JOIN cteIntExpList ON cteMain.rics_contactNo = cteIntExpList.rics_contactNo
INNER JOIN dbo.vwContact AS FC ON FC.rics_contactno = cteMain.rics_contactno
--INNER JOIN dbo.vwStringMap SM
--	ON SM.attributeValue = FC.rics_title
--	AND SM.AttributeName = 'rics_title'
--	AND SM.ObjectTypeCode = 2
INNER JOIN dbo.vwStringMap SM1
	ON SM1.attributeValue = FC.rics_MemberGrade
	AND SM1.AttributeName = 'rics_MemberGrade'
	AND SM1.ObjectTypeCode = 2
LEFT JOIN dbo.vwRicsGroup RG
	ON FC.Address1_Country = RG.rics_countryidname
	AND RG.statecode = 0

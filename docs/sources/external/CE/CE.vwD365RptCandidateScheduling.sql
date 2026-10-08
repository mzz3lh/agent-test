--/****** Object:  View [CE].[vwD365RptCandidateScheduling]    Script Date: 09/01/2023 09:37:56 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO


CREATE   VIEW [CE].[vwD365RptCandidateScheduling]
AS



WITH
cteSp AS  --This is the specialism attached to the applicant record
(
SELECT DISTINCT rics_contactno,Specialism 
FROM [CE].[tblD365DataCandidateScheduling]
WHERE Specialism IS NOT NULL
),

cteSpList AS
(
SELECT rics_contactno , STRING_AGG([specialism], ', ') AS Specialism
FROM cteSp
GROUP BY Rics_ContactNo
),

--SELECT * FROM cteSpList
--SELECT * FROM [CE].[vwD365DataCandidateScheduling] WHERE rics_contactno = '0000000'

--Specialisms attached to the contact record instead of the applicant record
cteSpCon AS
(SELECT DISTINCT rics_contactno, rs.rics_name AS specialism 
FROM [CE].[vwrics_rics_specialism_contact] AS rsc
LEFT JOIN CE.[vwRics_specialism] AS rs ON rs.rics_specialismid = rsc.rics_specialismid
INNER JOIN [CE].[tblD365DataCandidateScheduling] DCS ON rsc.ContactID = DCS.ContactID),
--WHERE rsc.Contactid IN (SELECT DISTINCT ContactID FROM  dbo.vwDataCandidateScheduling)),

cteSpConList AS
(
SELECT Rics_ContactNo , STRING_AGG([specialism], ', ') AS Specialism
FROM cteSpCon
GROUP BY Rics_ContactNo
),

ctePwy AS
(
SELECT DISTINCT Rics_ContactNo,rics_Pathwayidname AS Pathway 
FROM [CE].[tblD365DataCandidateScheduling]
WHERE rics_pathwayidname IS NOT NULL
),

ctePwyList AS

(
SELECT Rics_ContactNo , STRING_AGG([Pathway], ', ') AS Pathway
FROM ctePwy
GROUP BY Rics_ContactNo
),


--cteISec AS
--(
--SELECT DISTINCT Rics_ContactNo,IndustrySector 
--FROM [CE].[vwD365DataCandidateScheduling]
--WHERE IndustrySector IS NOT NULL
--),

--cteISecList AS

--(
--SELECT Rics_ContactNo , STRING_AGG([IndustrySector], ', ') AS IndustrySector
--FROM cteISec
--GROUP BY Rics_ContactNo
--),


cteAOP AS
(
SELECT DISTINCT Rics_ContactNo, AreaOfPractice 
FROM [CE].[tblD365DataCandidateScheduling]
WHERE AreaOfPractice IS NOT NULL
),

cteAOPList AS

(
SELECT Rics_ContactNo , STRING_AGG([AreaofPractice], ', ') AS AreaOfPractice
FROM cteAOP
GROUP BY Rics_ContactNo
)


--cteLang AS
--(
--SELECT DISTINCT Rics_ContactNo, Languages 
--FROM dbo.vwDataCandidateScheduling
--),

--cteLangList AS

--(
--SELECT Rics_ContactNo , STRING_AGG([Languages], ', ') AS Languages
--FROM cteLang
--GROUP BY Rics_ContactNo
--),


--cteIntExp    ---THS IS NOW JUST A YES/NO
--     AS (
--     SELECT DISTINCT
--            Rics_ContactNo,
--            IntExperience
--   FROM dbo.D365CandidateSchedulingStaging
--	 WHERE IntExperience IS NOT NULL),

-- cteIntExpList
--     AS 
--	 (
--SELECT Rics_ContactNo , STRING_AGG([IntExperience], ', ') AS IntExperience
--FROM cteIntExp
--GROUP BY Rics_ContactNo
--)

SELECT DISTINCT contactid,
Rics_apcId, 
DCS.rics_contactno AS [Contact No], 
fullname AS [Full Name], 
rics_counselloridname AS [Counsellor Name], 
CounsellorNo AS [Counsellor Contact No], 
rics_applicationtypeidname AS [Application Type], 
rics_routeidname AS [Route], 
rics_pathwayidname AS [Pathway], 
rics_pathwayid, 
apuk_firstlocationchoiceidname AS [1st Choice Assessment Centre], 
apuk_secondlocationchoiceidname AS [2nd Choice Assessment Centre], 
apuk_thirdlocationchoiceidname AS [3rd Choice Assessment Centre], 
accountidname AS [Account], 
address1_line1 AS [Address Line 1], 
address1_line2 AS [Address Line 2], 
address1_city AS [City], 
address1_country AS [Country], 
address1_postalcode AS [Postal Code], 
--Rics_Disability AS [Disability], 
rics_localgroupidname AS [Local Group], 
ContactType AS [Contact Type],
MemberGrade AS [Member Grade], 
emailaddress1 AS [EMail Address], 
telephone1 AS [Telephone], 
rics_numberofattempts AS [No Of Attempts], 
ISNULL(SPC.specialism,'') + ','+
ISNULL(SP.specialism,'') AS [Specialisms],
WorldRegion, 
SubmissionReceived AS [Submission Received], 
DCS.IndustrySector AS [Industry Sector],
AOP.AreaOfPractice AS [Area of Practice],
DCS.IntExperience AS [International Experience],
PreviouslyReferred AS [Previously Referred],
HasOutstandingBalance AS [Has Outstanding Balance]


FROM [CE].[tblD365DataCandidateScheduling] DCS
	LEFT JOIN cteSpList SP ON DCS.rics_contactNo = SP.Rics_ContactNo
	LEFT JOIN cteSpConList SPC ON DCS.rics_contactNo = SPC.Rics_ContactNo
	LEFT JOIN ctePwyList PW ON DCS.rics_contactNo = PW.Rics_ContactNo
	--LEFT JOIN cteISecList ISL ON DCS.rics_contactNo = ISL.Rics_ContactNo
	LEFT JOIN cteAOPList AOP ON DCS.rics_contactNo = AOP.Rics_ContactNo
	--LEFT JOIN cteIntExpList IEL ON DCS.rics_contactNo = IEL.Rics_ContactNo

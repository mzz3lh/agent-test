/************************************************************************************
Adobe Campaign  - Master Data

Connection: az-pbi-prod-uks-epdbs01.database.windows.net
Database: az-sqldb-uks-prd-pbi01
**************************************************************************************/

CREATE VIEW AdobeCampaign.vwMasterData
AS

SELECT  
C.Rics_ContactNo AS [Contact No],
C.FullName AS [Full Name],
C.FirstName AS [First Name],
C.MiddleName AS [Middle Name],
C.LastName AS [Last Name],
C.MemberGrade_Description AS [Member Grade],
C.Rics_Region AS [Region],
RG.Rics_ReportingSubWorldRegion AS [Reporting Sub World Region],
C.rics_localgroupidName AS [Local Group],
C.rics_countryidName AS [Country],
C.Rics_LapsedCode_Description AS [Lapsed Code],
C.rics_pathwaytomembershipidName AS [Pathway To Membership],
C.rics_primaryprofessionalgroupidName AS [Primary Professional Group],
C.Rics_ConcessionCode_Descritpion AS [Current Concession], 
C.EMailAddress1 AS [Preferred Email]

FROM CE.vwContact C
LEFT JOIN  CE.vwRicsGroup RG ON RG.Rics_ReportingLocalGroup = C.rics_localgroupidName
WHERE C.StateCode = 0

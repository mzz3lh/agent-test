/******************************************************************************************************************
SD 000000 - Application Competencies - Alan Smithers

Connection: az-pbi-prod-uks-epdbs01.database.windows.net
Database: az-sqldb-uks-prd-pbi01

**********************************************************************************************************************/
CREATE VIEW [dbo].[vwApplicationCompetency]
AS

WITH cteAppCom
AS
(

SELECT APP.rics_ContactNo AS [Contact Number], APP.rics_contactidname AS [Contact Name],APP.rics_enrolmentdate AS [Enrolment Date],RG.Rics_ReportingSubWorldRegion AS [Sub-World Region],
rics_routeidname AS [Route],rics_pathwayidname AS [Pathway],COM.Rics_CompetencyName AS Competency, COM.Rics_Level AS [Level]
FROM [dbo].[vwApplications] APP
LEFT JOIN [dbo].[vwrics_rics_apc_rics_competency] AC ON AC.rics_apcid = APP.rics_apcid
LEFT JOIN [dbo].[vwRics_competency] COM ON AC.rics_competencyid = COM.Rics_competencyId
INNER JOIN [dbo].[vwContact] C ON C.ContactId = APP.rics_contactid
LEFT JOIN [dbo].vwricsgroup AS RG on C.rics_localgroupid = RG.Rics_groupId
WHERE APP.rics_lapseddate IS NULL
--AND C.rics_contactno = 0000000
AND COM.Rics_CompetencyName IS NOT NULL
AND APP.statecode = 0
AND C.statecode = 0
AND COM.statecode = 0
)

SELECT * FROM cteAppCom  --WHERE [Contact Number] = '0000000'
--ORDER BY Route,Pathway,Level






/*******************************************WORKING QUERIES AND NOTES******************************************************************
SELECT TOP 100 * FROM [dbo].[vwApplications]

SELECT TOP 100 * FROM 

***********************************************************************************************************************************************/

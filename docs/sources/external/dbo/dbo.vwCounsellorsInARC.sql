/*******************************************************************************************************
CounsellorsInARC Power BI Report

Connection: az-pbi-prod-uks-epdbs01.database.windows.net
Database: az-sqldb-uks-prd-pbi01
*******************************************************************************************************/
CREATE VIEW [dbo].[vwCounsellorsInARC]
AS

SELECT 
coun.[Counsellor Contact No],
[Counsellor Name],
[Preferred Email Address],
[Candidate Contact No],
Candidate,
region,
[Reporting Sub World Region],
country
FROM
(
SELECT DISTINCT
ou.ContactNumber AS [Counsellor Contact No],
co.rics_counselloridname AS [Counsellor Name],
CASE
	WHEN c.rics_emailpreference = 1 AND c.emailaddress2 IS NOT NULL THEN 	c.emailaddress2
	WHEN c.rics_emailpreference = 2 AND c.emailaddress3 IS NOT NULL THEN 	c.emailaddress3
	ELSE NULL
END AS [Preferred Email Address],  
g.Rics_ReportingRegionIdName AS region,
g.ricsv2_ReportingSubRegionIdName AS [Reporting Sub World Region],
g.rics_countryidName AS country
FROM OCE.vwOceUsers AS ou 
inner join [dbo].vwricsapc AS co on ou.ContactId = co.rics_counsellorid
inner join [dbo].vwcontact AS c on co.rics_counsellorid = c.ContactId
inner join [dbo].vwricsgroup AS g on c.rics_localgroupid = g.Rics_groupId
WHERE rics_counsellorid is not null and co.Rics_ApplicationEndDate is null
)AS Coun

outer apply
(
SELECT
c.FullName as Candidate,
c.Rics_contactno as [Candidate Contact No],
cc.Rics_contactno as [Councellor Contact No]
FROM [OCE].[vwOceUsers] as ou left join
[dbo].[vwcontact] as c on ou.ContactId = c.ContactId left join
[dbo].[vwcontact] as cc on ou.CounselorId = cc.ContactId 
WHERE c.StateCode = 0 
--and c.ricsv1_ExcludeFromBetaTesting = 0 -- No   ADD COLUMN TO IMPORT
and cc.Rics_contactno = Coun.[Counsellor Contact No] collate Latin1_General_CI_AI
)as Cand
WHERE [Candidate Contact No]not in ('0000000','0000000','0000000','0000000') and coun.[Counsellor Contact No] not in ('0000000','0000000')



/*
select 
Rics_Region,
Rics_ReportingRegionIdName,
Rics_ReportingSubWorldRegion,
Rics_WorldRegion,
ricsv2_ReportingSubRegionIdName,
ricsv2_ReportingWorldRegionIdName 
from [dbo].vwricsgroup
where Rics_Region is not null
*/

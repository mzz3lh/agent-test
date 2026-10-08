CREATE VIEW [dbo].[vwCouncellorReporting]
AS

select
a.rics_counselloridName AS [Councellor Name],
c.rics_contactno AS [Contact No],--c.fullname,
c.firstname AS [First Name],
c.lastname AS [Last Name],
c.emailaddress1 AS [EMail Address],
sm1.Value AS [Member Grade],
sm2.value AS [Lapsed Code], 
sm3.Value as [Assessment Result],
s.rics_date as [Assessment Date], 
c.rics_electiondate as [Counsellor FQ Date],
g.ricsv2_ReportingSubRegionIdName AS [Reporting Sub World Region]
from dbo.vwricssession s
inner join dbo.vwRicsAPC a on a.rics_apcid = s.rics_candidateid
inner join dbo.vwcontact c on a.rics_counsellorid = c.contactid
LEFT JOIN [dbo].vwricsgroup AS g on c.rics_localgroupid = g.Rics_groupId

left join dbo.vwstringmap as sm1 on c.rics_membergrade = sm1.AttributeValue and sm1.attributename = 'rics_membergrade' and sm1.ObjectTypeCode = 2
left join dbo.vwstringmap as sm2 on c.Rics_LapsedCode = sm2.AttributeValue and sm2.attributename = 'rics_lapsedcode' and sm2.ObjectTypeCode = 2
left join dbo.vwstringmap as sm3 on s.Rics_Result = sm3.AttributeValue and sm3.attributename = 'rics_result' and sm3.ObjectTypeCode = 10006

where 

a.statuscode = 1
and s.statecode = 0
and c.statecode = 0

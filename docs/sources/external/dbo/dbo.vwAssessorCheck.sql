/**************************************************************
Assessor Check Power BI Report

Connection: az-pbi-prod-uks-epdbs01.database.windows.net
Database: az-sqldb-uks-dev-pbi01
**************************************************************/
CREATE VIEW [dbo].[vwAssessorCheck]
AS
Select distinct
main.*,
isnull(opencases.[Open Cases],0) as 'open cases',
isnull(openreturns.[open returns],0)as 'open returns',
isnull(casepartyopencases.[Open Case Party],0)as 'open case party',
isnull(consentorders.[Consent Orders],0)as 'consent orders',
case when case when([Assessment Authority] = 'Cannot assess any grade') then 1 else 0 end + isnull(opencases.[open cases],0)+isnull(openreturns.[open returns],0)+isnull(casepartyopencases.[open case party],0)+isnull(consentorders.[consent orders],0) > 0 Then 'Yes' else 'No' end as 'Review' 

from(
select distinct 
c.fullname AS Assessor, --as rics_assessoridName,
c.rics_contactno AS [Contact No],--as contactno,
lg.Rics_WorldRegion AS [World Region],
lg.rics_countryidName AS [Country],
SM1.value AS [Grade],--as Rics_ContactType,
case 
when SM1.value = 'Member - FRICS' then 'Assess any grade'
when SM1.value = 'Member - MRICS' then 'Assess any grade'
when SM1.value = 'Member - AssocRICS' then 'Assess only Associate candidates'
else 'Cannot assess any grade' end 
AS [Assessment Authority]

 
from [dbo].[vwRics_Assessor] as a inner join
vwContact as c on a.rics_contactid = c.contactid inner join
vwRics_Assessorrole as ar on a.rics_assessorid = ar.rics_assessorid inner join
vwRicsGroup as lg on c.rics_localgroupid = lg.Rics_groupId inner join
vwStringmap as SM1 on c.Rics_ContactType = SM1.AttributeValue and SM1.AttributeName = 'Rics_ContactType' and SM1.ObjectTypeCode = 2

where 
a.statecode = 0 and 
a.rics_enddate is null and
a.Rics_StartDate is not null and 
c.Rics_LapsedCode is null
)as main

outer apply
(
SELECT rics_contactno,count(rics_contactno)as [Open Cases] FROM vwCclregs_Case as cs  inner join
vwContact as ct on cs.cclregs_regardingmemberid = ct.contactid
group by rics_contactno,cclregs_regulationcasestatusidname,cs.statecode,cclregs_regardingmemberid
Having 
cclregs_regulationcasestatusidname not in ('Closed') and
cs.statecode = 0 and
cclregs_regardingmemberid is not null and
rics_contactno = main.[Contact No]
)opencases

outer apply
(
SELECT rics_contactno,count(rics_contactno) as [Open Returns] FROM vwcclregs_regulatoryreturn as r inner join
vwContact as ct on r.cclregs_regmemberid = ct.contactid
group by rics_contactno,cclregs_regulatoryreturntypeid,r.statuscode,r.statecode
Having cclregs_regulatoryreturntypeid not in ('00000000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000000') 
and r.statuscode not in('2','10','12','13') and r.statecode = 0 and 
rics_contactno = main.[Contact No]
)openreturns 

outer apply 
(
select rics_contactno,count(rics_contactno) as [Open Case Party]
from vwCclregs_Caseparty as cp inner join
vwCclregs_Case as c on cp.cclregs_regulationcaseidName = c.Cclregs_caseref inner join
vwContact as ct on cp.cclregs_partyid = ct.contactid
group by rics_contactno,cp.statecode,c.statecode,c.Cclregs_CaseClosureDate ,cclregs_partyid, rics_contactno
having cp.statecode = 0 and c.statecode = 0 and c.Cclregs_CaseClosureDate is null and cclregs_partyid is not null and rics_contactno = main.[Contact No]
)casepartyopencases

outer apply
(
SELECT rics_contactno,count(rics_contactno) as [Consent Orders] FROM vwcclregs_disciplinarymeasure as dm inner join
vwCclregs_Term as t on dm.cclregs_disciplinarymeasureid = t.cclregs_disciplinarymeasureid inner join
vwContact as ct on t.cclrv1_RegardingMemberid = ct.contactid  
group by rics_contactno,Cclregs_DisciplinaryMeasureType,Cclregs_ActualComplianceDate,Cclregs_ConsentOrderStatus
having cclregs_disciplinarymeasuretype = '1' and cclregs_actualcompliancedate is null and cclregs_consentorderstatus not in('10','11','13')and 
rics_contactno = main.[Contact No]
)consentorders

--select * from StringMap where AttributeName = 'Rics_ContactType' and ObjectTypeCode = 2

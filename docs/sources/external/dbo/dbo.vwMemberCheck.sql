/***************************************************************************
Member Check


**************************************************************************/
CREATE VIEW [dbo].[vwMemberCheck]
AS

--DECLARE @ContactNumber VARCHAR(10) = '0000000';

-----PREVENT LAPSE 1=yes
with CTEPreventLapse
as(
SELECT firstname,lastname,rics_contactno, 
CASE CAST(ISNULL(rics_preventlapse,0) AS INT)
WHEN 0 THEN 0
WHEN 1 THEN 1
END AS rics_preventlapse,
rics_alerttext 
FROM dbo.vwcontact
--where rics_contactno = @ContactNumber
), --SELECT * FROM CTEPreventLapse
-----OPEN CASES
CTEOpenCases
as(
SELECT rics_contactno,count(rics_contactno)as opencases FROM [dbo].[vwCclregs_Case] as cs  inner join
dbo.vwcontact as ct on cs.cclregs_regardingmemberid = ct.contactid
group by rics_contactno,cclregs_regulationcasestatusidname,cs.statecode,cclregs_regardingmemberid
Having cclregs_regulationcasestatusidname not in ('Closed') and cs.statecode = 0 and cclregs_regardingmemberid is not null --and rics_contactno = @ContactNumber
),-- SELECT * FROM CTEOpenCases

-----OPEN RETURNS
CTEOpenReturn
as(
SELECT rics_contactno,count(rics_contactno) as openreturns FROM [dbo].[vwcclregs_regulatoryreturn] as r inner join
dbo.vwcontact as ct on r.cclregs_regmemberid = ct.contactid
group by rics_contactno,cclregs_regulatoryreturntypeid,r.statuscode,r.statecode
Having cclregs_regulatoryreturntypeid not in ('00000000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000000') 
and r.statuscode not in('2','10','12','13') and r.statecode = 0 --and rics_contactno = @ContactNumber
),-- SELECT * FROM CTEOpenReturn

-----OPEN SCHEMES
CTEOpenScheme
as(
SELECT rics_contactno,count(rics_contactno) as openschemes FROM [dbo].[vwCclregs_Regulatedscheme] as s inner join
dbo.vwcontact as ct on s.cclregs_contactid = ct.contactid
group by rics_contactno,cclregs_ceaseddate
having cclregs_ceaseddate is null --and rics_contactno = @ContactNumber
),-- SELECT * FROM CTEOpenScheme

-----ALERT TEXT KEY WORDS?
--SELECT * FROM [10.50.10.189].rics_mscrm.

--select * from [10.50.10.189].RICS_MSCRM.dbo.rics_contactrelationship

-----DIRECTOR PRINCIPAL OF REGULATED FIRM
CTEDirectorPrince
as(
SELECT rics_contactno,count(rics_contactno) as rics_relationshiptype 
FROM          [dbo].[vwRics_ContactRelationship] cr inner join 
dbo.vwcontact as ct on cr.rics_contactid = ct.contactid inner join
(select accountid from [dbo].[vwCclregs_Regulatedscheme] as s inner join
dbo.vwaccount as a on s.cclregs_accountid = a.accountid
where 
cclregs_regulatedschemetypeid = '00000000-0000-0000-0000-000000000000' and
cclregs_licenseapprovaldate is not null and
cclregs_ceaseddate is null and
rics_schemelicencestatus in (7,8,9) and
s.statecode = 0 and 
a.statecode = 0) AS rf on cr.rics_accountid = rf.accountid -- was DBADB.dbo.regulatedFirms as rf on cr.rics_accountid = rf.accountid 
group by rics_contactno,rics_contactid, cr.rics_relationshiptype,ct.statecode, CR.statecode,rics_enddate
having cr.rics_relationshiptype = '1' --and rics_contactno = /*'0000000'*/@ContactNumber 
and ct.statecode = 0 and CR.statecode = 0 and rics_enddate is null
),-- SELECT * FROM CTEDirectorPrince

-----CASE PARTY - OPEN CASES
CTEOpenCaseParty
as(
select rics_contactno,count(rics_contactno) as opencaseparty
from [dbo].[vwCclregs_Caseparty] as cp inner join
[dbo].[vwCclregs_Case] as c on cp.cclregs_regulationcaseidName = c.Cclregs_caseref inner join
dbo.vwcontact as ct on cp.cclregs_partyid = ct.contactid
group by rics_contactno,cp.statecode,c.statecode,c.Cclregs_CaseClosureDate ,cclregs_partyid, rics_contactno
having cp.statecode = 0 and c.statecode = 0 and c.Cclregs_CaseClosureDate is null and cclregs_partyid is not null --and rics_contactno = @ContactNumber
), --SELECT * FROM CTEOpenCaseParty

-----CONSENT ORDER 
CTEActiveConsentOrder
as(
SELECT rics_contactno,count(rics_contactno) as consentorders FROM [dbo].[vwcclregs_disciplinarymeasure] as dm inner join
dbo.vwcclregs_term as t on dm.cclregs_disciplinarymeasureid = t.cclregs_disciplinarymeasureid inner join
dbo.vwcontact as ct on t.cclrv1_RegardingMemberid = ct.contactid  
group by rics_contactno,Cclregs_DisciplinaryMeasureType,Cclregs_ActualComplianceDate,Cclregs_ConsentOrderStatus
having cclregs_disciplinarymeasuretype = '1' and cclregs_actualcompliancedate is null and cclregs_consentorderstatus not in('10','11','13')--and rics_contactno = @ContactNumber
), --SELECT * FROM CTEActiveConsentOrder

cteFinal
AS
(
select ii.*, Case when total >0 then 'Refer To Regulation' else 'No outstanding regulatory matters' end as message
from(
select i.*, opencases + openreturns + openschemes 
+ preventlapse 
+ relationships + opencaseparty + consentorders as total
from(
select 
firstname,
lastname,
pl.rics_contactno,
isnull(opencases,0)as opencases,
isnull(openreturns,0)as openreturns,
isnull(openschemes,0)as openschemes,
ISNULL(rics_preventlapse,0) AS preventlapse,
isnull(rics_alerttext,'No Alerts')as alerttext,
isnull(rics_relationshiptype,0)as relationships,
isnull(opencaseparty,0)as opencaseparty,
isnull(consentorders,0)as consentorders
from 
CTEPreventLapse as pl left join
CTEOpenCases as oc on pl.rics_contactNo = oc.rics_contactNo left join
CTEOpenReturn as opr on pl.rics_contactNo = opr.rics_contactNo left join
CTEOpenScheme as os on pl.rics_contactNo = os.rics_contactNo left join
CTEDirectorPrince as dp on pl.rics_contactNo = dp.rics_contactNo left join
CTEOpenCaseParty as cp on pl.rics_contactNo = cp.rics_contactNo left join
CTEActiveConsentOrder as co on pl.rics_contactNo = co.rics_contactNo
)i
)ii
)
SELECT *, 
CASE alerttext
WHEN 'No Alerts' THEN 0
ELSE 1
END as alerttextcolour,
CASE [Message]
WHEN 'No outstanding regulatory matters' THEN 0
ELSE 1
END as messagecolour,
CASE [preventlapse]
WHEN 0 THEN 'No'
WHEN 1 THEN 'Yes'
END as preventlapsetext

FROM cteFinal

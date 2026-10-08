create view  [InsightsBI].[vwAD_Market_Analysis_global_key_accounts] as

with head_offices as (
select
AccountId,
rics_firmnumber,
name,
case when Address1_City is not null  then Address1_City
	when Address1_City is  null then Address1_Country
	else null end as head_office_location
	
from  ce.vwAccount A
where Rics_IsHeadoffice = 1)
,
all_accounts as (
select

case when Rics_IsHeadoffice = 1 then AccountId else ParentAccountId
end as head_office_account,
AccountId as sub_office_accountid,
lg.Fin_Region as sub_office_location

from ce.vwAccount A

left join ce.vwLocalGroup LG
on a.Rics_LocalGroupId = LG.apuk_localgroupid
),

number_of_offices as (
select
HO.AccountId
,count(distinct(AA.sub_office_accountid)) as number_of_offices

from head_offices HO

left join all_accounts AA
on ho.AccountId = aa.head_office_account

group by HO.AccountId),

number_of_surveyors AS (
	SELECT 
		a.AccountId,
		COUNT(DISTINCT b.contactid) AS qualified_employees
	FROM ce.vwaccount AS a
	LEFT JOIN ce.vwContact AS b ON a.AccountId = b.AccountId
	WHERE b.MemberGrade_Description IN ('Qualified Professional', 'Qualified Professional - 2 years')
	  AND b.StateCode_Description = 'Active'
	  AND b.Rics_LapsedCode IS NULL
	  AND a.StateCode_Description = 'Active'
	GROUP BY a.AccountId
),

number_of_candidates AS	 (
	SELECT 
		a.AccountId,
		COUNT(DISTINCT b.contactid) AS NUMBER_OF_CANDIDATES_NON_STALLED
	FROM ce.vwaccount AS a
	LEFT JOIN ce.vwContact AS b ON a.AccountId = b.AccountId
	WHERE b.MemberGrade_Description ='Candidate'
	  AND b.StateCode_Description = 'Active'
	  AND b.Rics_LapsedCode IS NULL
	  AND a.StateCode_Description = 'Active'
	  and b.CreatedOn >= DATEADD(year,-2,GETDATE())
	GROUP BY a.AccountId
)

select
HO.AccountId
,HO.rics_firmnumber 
,HO.name
,HO.head_office_location
,NOO.number_of_offices
,AA.sub_office_location
,SUM(NOS.qualified_employees) as total_surveyors
,sum(NOC.NUMBER_OF_CANDIDATES_NON_STALLED) as total_candidates
,SUM(NOS.qualified_employees + NOC.NUMBER_OF_CANDIDATES_NON_STALLED) as Total


from head_offices HO

left join number_of_offices NOO
on HO.AccountId = NOO.AccountId

left join all_accounts AA
on ho.AccountId = AA.head_office_account

LEFT JOIN number_of_surveyors NOS
on AA.sub_office_accountid = NOS.AccountId

LEFT JOIN number_of_candidates NOC
on AA.sub_office_accountid = NOC.AccountId

GROUP BY HO.AccountId,
HO.rics_firmnumber,
HO.name,
HO.head_office_location,
NOO.number_of_offices,
AA.sub_office_location

/***************************************************************************************************
Query Name:			Key Accounts
Procedure:          
Create Date:        2025-06-01
Author:             Joe Expert
Description:        
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------



***************************************************************************************************/
CREATE VIEW InsightsBI.vwAD_MWM_KeyAccounts AS

with 

all_key_accounts as 
(
-- CBRE
select
	distinct AccountId
	,Rics_IsHeadoffice
	,Rics_LocalGroupId
	,'CBRE' as KEY_ACCOUNT_NAME
from ce.vwAccount
where 
	( 
		rics_tradingname like '%CBRE%'
		or rics_registeredname like '%CBRE%'
		or name like '%CBRE%'
	)
	and StateCode = 0

UNION ALL
-- JLL
select
	distinct AccountId
	,Rics_IsHeadoffice
	,Rics_LocalGroupId
	,'JLL' as KEY_ACCOUNT_NAME
from ce.vwAccount
where 
	( 
		rics_tradingname like '%JLL%'
		or rics_tradingname like '%Jones Lang LaSalle%'
		or rics_registeredname like '%JLL%'
		or rics_registeredname like '%Jones Lang LaSalle%'
		or name like '%JLL%'
		or name like '%Jones Lang LaSalle%'
	)
	and StateCode = 0
	and name not like '%punjlloyd%'

UNION ALL
-- Savills
select
	distinct AccountId
	,Rics_IsHeadoffice
	,Rics_LocalGroupId
	,'Savills' as KEY_ACCOUNT_NAME
from ce.vwAccount
where 
	( 
		rics_tradingname like '%Savills%'
		or rics_registeredname like '%Savills%'
		or name like '%Savills%'
	)
	and StateCode = 0

UNION ALL
-- Cushman & Wakefield
select
	distinct AccountId
	,Rics_IsHeadoffice
	,Rics_LocalGroupId
	,'Cushman & Wakefield' as KEY_ACCOUNT_NAME
from ce.vwAccount
where 
	( 
		rics_tradingname like '%Cushman & Wakefield%'
		or rics_tradingname like '%Cushman and Wakefield%'
		or rics_registeredname like '%Cushman & Wakefield%'
		or rics_registeredname like '%Cushman and Wakefield%'
		or name like '%Cushman & Wakefield%'
		or name like '%Cushman and Wakefield%'
	)

UNION ALL
-- Arcadis
select
	distinct AccountId
	,Rics_IsHeadoffice
	,Rics_LocalGroupId
	,'Arcadis' as KEY_ACCOUNT_NAME
from ce.vwAccount
where 
	( 
		rics_tradingname like '%Arcadis%'
		or rics_registeredname like '%Arcadis%'
		or name like '%Arcadis%'
	)
	and StateCode = 0

UNION ALL
-- Knight Frank
select
	distinct AccountId
	,Rics_IsHeadoffice
	,Rics_LocalGroupId
	,'Knight Frank' as KEY_ACCOUNT_NAME
from ce.vwAccount
where 
	( 
		rics_tradingname like '%Knight Frank%'
		or rics_registeredname like '%Knight Frank%'
		or name like '%Knight Frank%'
	)
	and StateCode = 0

UNION ALL
-- Turner & Townsend
select
	distinct AccountId
	,Rics_IsHeadoffice
	,Rics_LocalGroupId
	,'Turner & Townsend' as KEY_ACCOUNT_NAME
from ce.vwAccount
where 
	( 
		rics_tradingname like '%Turner & Townsend%'
		or rics_registeredname like '%Turner & Townsend%'
		or name like '%Turner & Townsend%'
	)
	and StateCode = 0

UNION ALL
-- Colliers
select
	distinct AccountId
	,Rics_IsHeadoffice
	,Rics_LocalGroupId
	,'Colliers' as KEY_ACCOUNT_NAME
from ce.vwAccount
where 
	( 
		rics_tradingname like '%Colliers%'
		or rics_registeredname like '%Colliers%'
		or name like '%Colliers%'
	)
	and StateCode = 0

UNION ALL
-- AECOM
select
	distinct AccountId
	,Rics_IsHeadoffice
	,Rics_LocalGroupId
	,'AECOM' as KEY_ACCOUNT_NAME
from ce.vwAccount
where 
	( 
		rics_tradingname like '%AECOM%'
		or rics_registeredname like '%AECOM%'
		or name like '%AECOM%'
	)
	and StateCode = 0

UNION ALL
-- Rider Levett Bucknall
select
	distinct AccountId
	,Rics_IsHeadoffice
	,Rics_LocalGroupId
	,'Rider Levett Bucknall' as KEY_ACCOUNT_NAME
from ce.vwAccount
where 
	( 
		rics_tradingname = 'RLB'
		or rics_registeredname = 'RLB'
		or name = 'RLB'

		or rics_tradingname like '%(RLB%'
		or rics_registeredname like '%(RLB%'
		or name like '%(RLB%'
	 
		or	rics_tradingname like '% RLB%'
		or rics_registeredname like '% RLB%'
		or name like '% RLB%'

		or rics_tradingname like '%RLB %'
		or rics_registeredname like '%RLB %'
		or name like '%RLB %'

		or rics_tradingname like '%Rider Levett Bucknall%'
		or rics_registeredname like '%Rider Levett Bucknall%'
		or name like '%Rider Levett Bucknall%'
	)
	and StateCode = 0

UNION ALL
-- Faithful & Gould

select
	distinct AccountId
	,Rics_IsHeadoffice
	,Rics_LocalGroupId
	,'AtkinsRealis' as KEY_ACCOUNT_NAME
from ce.vwAccount
where 
	( 
		rics_tradingname like '%Faithful & Gould%'
		or rics_tradingname like '%Faithful+Gould%'
		or rics_tradingname like '%AtkinsRéalis%'
		or rics_tradingname like '%AtkinsRealis%'
		or rics_registeredname like '%Faithful & Gould%'
		or rics_registeredname like '%Faithful+Gould%'
		or rics_registeredname like '%AtkinsRéalis%'
		or rics_registeredname like '%AtkinsRealis%'
		or name like '%Faithful & Gould%'
		or name like '%Faithful+Gould%'
		or name like '%AtkinsRéalis%'
		or name like '%AtkinsRealis%'
	)
	and StateCode = 0


UNION ALL
-- BNP Paribas
select
	distinct AccountId
	,Rics_IsHeadoffice
	,Rics_LocalGroupId
	,'BNP Paribas' as KEY_ACCOUNT_NAME
from ce.vwAccount
where 
	( 
		rics_tradingname like '%BNP Paribas%'
		or rics_registeredname like '%BNP Paribas%'
		or name like '%BNP Paribas%'
	)
	and StateCode = 0

UNION ALL
-- Avison Young
select
	distinct AccountId
	,Rics_IsHeadoffice
	,Rics_LocalGroupId
	,'Avison Young' as KEY_ACCOUNT_NAME
from ce.vwAccount
where 
	( 
		rics_tradingname like '%Avison Young%'
		or rics_registeredname like '%Avison Young%'
		or name like '%Avison Young%'
	)
	and StateCode = 0

UNION ALL
-- Gardiner & Theobald
select
	distinct AccountId
	,Rics_IsHeadoffice
	,Rics_LocalGroupId
	,'Gardiner & Theobald' as KEY_ACCOUNT_NAME
from ce.vwAccount
where 
	( 
		rics_tradingname like '%Gardiner & Theobald%'
		or rics_tradingname like '%Gardiner and Theobald%'
		or rics_registeredname like '%Gardiner & Theobald%'
		or rics_registeredname like '%Gardiner and Theobald%'
		or name like '%Gardiner & Theobald%'
		or name like '%Gardiner and Theobald%'
	)
	and StateCode = 0

UNION ALL
-- Gleeds
select
	distinct AccountId
	,Rics_IsHeadoffice
	,Rics_LocalGroupId
	,'Gleeds' as KEY_ACCOUNT_NAME
from ce.vwAccount
where 
	( 
		rics_tradingname like '%Gleeds%'
		or rics_registeredname like '%Gleeds%'
		or name like '%Gleeds%'
	)
	and StateCode = 0

UNION ALL
-- Mace
select
	distinct AccountId
	,Rics_IsHeadoffice
	,Rics_LocalGroupId
	,'Mace' as KEY_ACCOUNT_NAME
from ce.vwAccount
where 
	( 
		rics_tradingname like '%Mace%'
		or rics_registeredname like '%Mace%'
		or name like '%Mace%'
	)
	and StateCode = 0

UNION ALL
-- Currie & Brown
select
	distinct AccountId
	,Rics_IsHeadoffice
	,Rics_LocalGroupId
	,'Currie & Brown' as KEY_ACCOUNT_NAME
from ce.vwAccount
where 
	( 
		rics_tradingname like '%Currie & Brown%'
		or rics_tradingname like '%Currie and Brown%'
		or rics_registeredname like '%Currie & Brown%'
		or rics_registeredname like '%Currie and Brown%'
		or name like '%Currie & Brown%'
		or name like '%Currie and Brown%'
	)
	and StateCode = 0

UNION ALL
-- KPMG
select
	distinct AccountId
	,Rics_IsHeadoffice
	,Rics_LocalGroupId
	,'KPMG' as KEY_ACCOUNT_NAME
from ce.vwAccount
where 
	( 
		rics_tradingname like '%KPMG%'
		or rics_registeredname like '%KPMG%'
		or name like '%KPMG%'
	)
	and StateCode = 0

UNION ALL
-- Balfour Beatty
select
	distinct AccountId
	,Rics_IsHeadoffice
	,Rics_LocalGroupId
	,'Balfour Beatty' as KEY_ACCOUNT_NAME
from ce.vwAccount
where 
	( 
		rics_tradingname like '%Balfour Beatty%'
		or rics_registeredname like '%Balfour Beatty%'
		or name like '%Balfour Beatty%'
	)
	and StateCode = 0

UNION ALL
-- Deloitte
select
	distinct AccountId
	,Rics_IsHeadoffice
	,Rics_LocalGroupId
	,'Deloitte' as KEY_ACCOUNT_NAME
from ce.vwAccount
where 
	( 
		rics_tradingname like '%Deloitte%'
		or rics_registeredname like '%Deloitte%'
		or name like '%Deloitte%'
	)
	and StateCode = 0

)

SELECT
*
FROM all_key_accounts
--where AccountId IS NOT NULL

/*
TESTING CODE FOR JOINING IN CONTACTS
,
contacts as (
select
c.*
,ac.KEY_ACCOUNT_NAME
,ac.Rics_IsHeadoffice
from all_key_accounts AC 
LEFT JOIN ce.vwContact C
ON ac.AccountId = c.ParentCustomerId

 where statecode=0
)

select
--KEY_ACCOUNT_NAME
----,MemberGrade_Description
--,count(distinct(accountid)) as accounts
--,count(distinct(case when Rics_IsHeadoffice = 1 then AccountId else NULL end)) as head_offices
--,count(distinct(contactid)) as contacts
--,sum(case when MemberGrade_Description in ('Qualified Professional', 'Qualified Professional - 2 years') then 1 else 0 end) as qualified_members
--,sum(case when MemberGrade_Description in ('Candidate') then 1 else 0 end) as candidates
----,count(*) as all_rows

*

from contacts 

--and membergrade_description in( 'Qualified Professional', 'Qualified Professional - 2 years')
--group by 
--KEY_ACCOUNT_NAME
----,MemberGrade_Description

--order by contacts desc
*/

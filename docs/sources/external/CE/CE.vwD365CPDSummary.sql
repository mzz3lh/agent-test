CREATE  VIEW [CE].[vwD365CPDSummary]
AS

SELECT DISTINCT
--Contact No (Contact)
c.Rics_contactno,
--Contact (I was pulling this from Contact relationships, but just need full name)
c.FullName,
--Office Number (Account)
a.rics_firmnumber,
a.Rics_TradingName AS AccountIdName,
a.Rics_OfficeNumber,
--Relationship type (Contact relationships)
CR.Rics_RelationshipType_Description AS Rics_RelationshipType,  --SM4.Value as Rics_RelationshipType,
--Complete (Annual Summaries) -this is just yes/no
ASUM.Rics_CPDComplete_Description AS [CPD Complete],  --SM3.Value as [Cpd Complete],
--CPD Complete Date (Annual Summaries) - formatted as a date. if blank return blank
isnull(convert(varchar(10),asum.ricsv1_CpdCompleteDate,103),'') as CpdCompleteDate,
--Total Completed Hrs (Annual Summaries) - can this return a zero if blank?
case 
when asum.Rics_totalcompletedhrs IS NULL then ''
when asum.Rics_totalcompletedhrs = 0 then '' 
when asum.Rics_totalcompletedhrs > 0 then cast(cast(asum.Rics_totalcompletedhrs as decimal(10,2)) as varchar(15)) 
end as [Total Completed Hrs],
--Completed Formal Hrs (Annual Summaries) - can this return a zero if blank?
case
when asum.Rics_completedformalhrs IS NULL then ''
when asum.Rics_completedformalhrs = 0 then ''
when asum.Rics_completedformalhrs > 0 then cast(cast(asum.Rics_completedformalhrs as decimal(10,2)) as varchar(15)) 
end as [Completed Formal Hrs],
asum.Rics_CPDYear AS CPDYear

from[synapse_ce].[vwCPDAnnualSummary]  AS ASUM  --tblRics_cpdannualsummary as asum
left join [synapse_ce].[tblContact_BI] AS C
	ON asum.rics_contactid = c.contactid
left join [synapse_ce].[vwRics_ContactRelationship] AS CR  --tblRics_contactrelationship as cr 
	ON c.ContactId = cr.rics_contactid -- and c.AccountId = cr.rics_accountid
inner join [synapse_ce].[vwAccount] AS A  --tblAccount as a 
	ON cr.rics_accountid = a.accountid
WHERE
ASUM.ricsv1_CPDRecordingStatus_Description = 'Targeted'     ---SM1.Value = 'Targeted' and
AND ASUM.ricsv1_ExemptionStatus_Description IS NULL  --SM2.Value is null and
AND ASUM.statecode = 0 
AND c.statecode = 0
AND c.rics_lapsedcode IS NULL
AND cr.rics_enddate IS NULL
AND cr.statecode = 0

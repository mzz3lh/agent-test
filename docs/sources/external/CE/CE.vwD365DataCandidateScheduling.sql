CREATE   VIEW [CE].[vwD365DataCandidateScheduling]
AS

WITH cteStaging
AS
(
SELECT
fc.ContactId,
apc.rics_apcid,
fc.Rics_contactno,
--sm3.value AS title,
fc.FullName, 
apc.rics_counselloridName,
coun.Rics_contactno AS CounsellorNo, 
apc.rics_applicationtypeidname,
apc.rics_routeidname, 
apc.rics_pathwayidname,
apc.rics_pathwayid, 
--apc.rics_1stchoiceassessmentcentreidname, ARE THE SE GOING TO BE ADDED?
--apc.rics_2ndchoiceassessmentcentreidname, 
--apc.rics_3rdchoiceassessmentcentreidname, 
fc.AccountIdName,
fa.address1_line1, 
fa.address1_line2, 
fa.Address1_City, 
fa.Address1_Country, 
fa.address1_postalcode,
--apuk_hasdisability2 AS HasDisability,  --TO ADD IN --Do we need details? - this can be multiple disabilities --sm1.Value AS Rics_Disability, 
fc.rics_localgroupidName, 
fc.Rics_MemberGrade AS rics_membergrade,    --sm2.Value AS rics_membergrade, 
fc.EMailAddress1, 
fc.Telephone1, 
apc.Rics_NumberofAttempts,
rs.Rics_name AS Specialism,
g.Rics_WorldRegion AS WorldRegion,
apc.rics_submissionreceived AS SubmissionReceived,
--apc.rics_industrysectoridName as IndustrySector,  --NOT IN VIEW
aop.Rics_name as AreaOfPractice,
rc.Rics_country AS IntExperience


--INTO DBADB.dbo.CandidateScheduling

FROM synapse_ce.vwRicsAPC AS apc
INNER JOIN synapse_ce.tblContact_BI AS fc ON fc.ContactId = apc.rics_contactid
LEFT JOIN synapse_ce.vwAccount AS fa 	ON fc.AccountId = fa.AccountId
LEFT JOIN synapse_ce.tblContact_BI AS coun ON coun.ContactId = apc.rics_counsellorid
LEFT JOIN synapse_ce.[vwrics_rics_apc_rics_specialism] AS rars ON  rars.apuk_enrolmentid= apc.rics_apcid   --was rars.rics_apcid
LEFT JOIN synapse_ce.[vwRics_specialism] AS rs ON rs.Rics_specialismId = apuk_specialismid--was rars.rics_specialismid
LEFT JOIN synapse_ce.[vwrics_rics_apc_rics_areaofpractice] rara on apc.rics_apcid = rara.apuk_enrolmentid--was rara.rics_apcid  
LEFT JOIN synapse_ce.vwRics_areaofpractice aop on aop.Rics_areaofpracticeId = rara.apuk_areaofpracticeid--was rara.rics_areaofpracticeid  
LEFT JOIN CE.[vwrics_rics_apc_rics_country] racb ON apc.rics_apcid = racb.rics_apcid 
LEFT JOIN synapse_ce.[vwrics_country] rc ON racb.Rics_country = rc.Rics_countryId
--INNER JOIN dbo.[vwStringMap] AS sm1 ON fc.Rics_Disability = sm1.AttributeValue 	AND sm1.ObjectTypeCode = 2	AND sm1.AttributeName = 'Rics_Disability'
--INNER JOIN dbo.[vwStringMap] AS sm2 ON fc.rics_membergrade = sm2.AttributeValue	AND sm2.ObjectTypeCode = 2 	AND sm2.AttributeName = 'rics_membergrade'
INNER JOIN CE.vwRicsGroup g ON g.Rics_name = fc.rics_localgroupidName 
--INNER JOIN [dbo].[vwStringMap] AS sm3	ON fc.rics_title = sm3.AttributeValue AND sm3.ObjectTypeCode = 2 AND sm3.AttributeName = 'rics_title'

WHERE apc.statecode = 0
--AND fc.ricsv1_ExcludeFromBetaTesting = 0 -- No
AND fc.Rics_LapsedCode IS NULL
AND apc.rics_electiondate IS NULL
AND apc.statecode = 0
--AND fc.rics_membergrade IN (16,15,6,4) --added 16 - ref SD000000  needs to be student,APC Candidate,Associate Candidate,AssociateMember 
AND fc.Rics_MemberGrade IN(200000000, 200000003) --Candidate , student
AND fc.StateCode = 0
)

SELECT DISTINCT
ContactId,
rics_apcid, Rics_contactno, 
--title, 
FullName, rics_counselloridName, CounsellorNo, rics_applicationtypeidname, rics_routeidname, 
rics_pathwayidname, rics_pathwayid, 
--rics_1stchoiceassessmentcentreidname, 
--rics_2ndchoiceassessmentcentreidname, 
--rics_3rdchoiceassessmentcentreidname, 
AccountIdName, address1_line1, address1_line2, Address1_City, Address1_Country, 
address1_postalcode, 
--Rics_Disability, 
rics_localgroupidName, 
--rics_membergrade, 
EMailAddress1, Telephone1, Rics_NumberofAttempts, 
Specialism, WorldRegion, SubmissionReceived, 
--IndustrySector,
AreaOfPractice,IntExperience

--INTO DBADB.dbo.D365CandidateScheduling

FROM cteStaging

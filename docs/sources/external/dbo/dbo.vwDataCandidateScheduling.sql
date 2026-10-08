CREATE VIEW [dbo].[vwDataCandidateScheduling]
AS

WITH cteStaging
AS
(
SELECT
fc.contactid,
apc.Rics_apcid,
fc.rics_contactno,
sm3.value AS title,
fc.fullname, 
apc.rics_counselloridname,
coun.rics_contactno AS CounsellorNo, 
apc.rics_applicationtypeidname,
apc.rics_routeidname, 
apc.rics_pathwayidname,
apc.rics_pathwayid, 
apc.rics_1stchoiceassessmentcentreidname, 
apc.rics_2ndchoiceassessmentcentreidname, 
apc.rics_3rdchoiceassessmentcentreidname, 
fc.accountidname,
fa.address1_line1, 
fa.address1_line2, 
fa.address1_city, 
fa.address1_country, 
fa.address1_postalcode,
sm1.Value AS Rics_Disability, 
fc.rics_localgroupidname, 
sm2.Value AS rics_membergrade, 
fc.emailaddress1, 
fc.telephone1, 
apc.rics_numberofattempts,
rs.rics_name AS Specialism,
g.rics_WorldRegion AS WorldRegion,
apc.rics_submissionreceived AS SubmissionReceived,
apc.rics_industrysectoridName as IndustrySector,
aop.Rics_name as AreaOfPractice,
rc.Rics_Country AS IntExperience


--INTO DBADB.dbo.CandidateScheduling

FROM dbo.vwRicsAPC AS apc
INNER JOIN dbo.vwcontact AS fc ON fc.ContactId = apc.rics_contactid
LEFT JOIN dbo.vwAccount AS fa 	ON fc.AccountId = fa.AccountId
LEFT JOIN dbo.vwcontact AS coun ON coun.ContactId = apc.rics_counsellorid
LEFT JOIN dbo.[vwrics_rics_apc_rics_specialism] AS rars ON rars.rics_apcid = apc.rics_apcid   --need to add
LEFT JOIN dbo.[vwRics_specialism] AS rs ON rs.rics_specialismid = rars.rics_specialismid
left join dbo.[vwrics_rics_apc_rics_areaofpractice] rara on apc.Rics_apcId = rara.rics_apcid  --need to add
left join dbo.vwRics_areaofpractice aop on aop.Rics_areaofpracticeId = rara.rics_areaofpracticeid  
LEFT JOIN [dbo].[vwrics_rics_apc_rics_country] racb ON apc.rics_apcid = racb.rics_apcid --need to add
LEFT JOIN [dbo].[vwrics_country] rc ON racb.rics_countryid = rc.rics_countryid
INNER JOIN dbo.[vwStringMap] AS sm1 ON fc.Rics_Disability = sm1.AttributeValue 	AND sm1.ObjectTypeCode = 2	AND sm1.AttributeName = 'Rics_Disability'
INNER JOIN dbo.[vwStringMap] AS sm2 ON fc.rics_membergrade = sm2.AttributeValue	AND sm2.ObjectTypeCode = 2 	AND sm2.AttributeName = 'rics_membergrade'
INNER JOIN dbo.vwRicsGroup g ON g.rics_name = fc.rics_localgroupidname 
INNER JOIN [dbo].[vwStringMap] AS sm3	ON fc.rics_title = sm3.AttributeValue AND sm3.ObjectTypeCode = 2 AND sm3.AttributeName = 'rics_title'

WHERE apc.statecode = 0
--AND fc.ricsv1_ExcludeFromBetaTesting = 0 -- No
AND fc.rics_lapsedcode IS NULL
AND apc.rics_electiondate IS NULL
AND apc.statecode = 0
AND fc.rics_membergrade IN (16,15,6,4) --added 16 - ref SD000000
AND fc.statecode = 0
)

SELECT DISTINCT
contactid,
Rics_apcId, rics_contactno, title, fullname, rics_counselloridname, CounsellorNo, rics_applicationtypeidname, rics_routeidname, 
rics_pathwayidname, rics_pathwayid, rics_1stchoiceassessmentcentreidname, rics_2ndchoiceassessmentcentreidname, 
rics_3rdchoiceassessmentcentreidname, accountidname, address1_line1, address1_line2, address1_city, address1_country, 
address1_postalcode, Rics_Disability, rics_localgroupidname, rics_membergrade, emailaddress1, telephone1, rics_numberofattempts, 
Specialism, WorldRegion, SubmissionReceived, IndustrySector,AreaOfPractice,IntExperience


FROM cteStaging

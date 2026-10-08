/****** Object:  View [dbo].[vwDataCandidateScheduling]    Script Date: 27/06/2022 15:15:50 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

CREATE PROCEDURE [CE].[uspD365DataCandidateScheduling]
AS

TRUNCATE TABLE CE.tblD365DataCandidateScheduling;

WITH cteCSData
AS
(
--Get raw data
SELECT 
fc.ContactId,
apc.rics_apcid,
fc.Rics_contactno,
fc.FullName, 
apc.rics_counselloridName,
coun.Rics_contactno AS CounsellorNo, 
apc.rics_applicationtypeidname,
apc.rics_routeidname, 
apc.rics_pathwayidname,
apc.rics_pathwayid, 
sess.apuk_firstlocationchoiceidname, 
sess.apuk_secondlocationchoiceidname, 
sess.apuk_thirdlocationchoiceidname, 
fc.AccountIdName,
fa.address1_line1, 
fa.address1_line2, 
fa.Address1_City, 
fa.Address1_Country, 
fa.address1_postalcode,
--apuk_hasdisability2 AS HasDisability,  --TO ADD IN --Do we need details? - this can be multiple disabilities --sm1.Value AS Rics_Disability, 
fc.rics_localgroupidName, 
fc.MemberGrade_Description AS ContactType, 
fc.apuk_designation_description AS MemberGrade,
fc.EMailAddress1, 
fc.Telephone1, 
apc.Rics_NumberofAttempts,
rs.Rics_name AS Specialism,
g.Rics_WorldRegion AS WorldRegion,
apc.rics_submissionreceived AS SubmissionReceived,
IND.Rics_name as IndustrySector, 
aop.Rics_name as AreaOfPractice,
CASE ISNULL(sess.apuk_internationalexperience,0)
WHEN 1 THEN 'Yes'
ELSE 'No'
END AS IntExperience,

--Additional Columns for referrals
CASE ISNULL(apuk_previouslyreferred,0)
WHEN 1 THEN 'Yes'
ELSE 'No'
END AS PreviouslyReferred,
 '   ' AS HasOutstandingBalance



FROM synapse_ce.vwRicsAPC AS apc
INNER JOIN synapse_ce.vwcontact AS fc ON fc.ContactId = apc.rics_contactid
LEFT JOIN synapse_ce.vwAccount AS fa 	ON fc.AccountId = fa.AccountId
LEFT JOIN synapse_ce.vwcontact AS coun ON coun.ContactId = apc.rics_counsellorid
LEFT JOIN synapse_ce.[vwrics_rics_apc_rics_specialism] AS rars ON  rars.apuk_enrolmentid= apc.rics_apcid   --was rars.rics_apcid
LEFT JOIN synapse_ce.[vwRics_specialism] AS rs ON rs.Rics_specialismId = apuk_specialismid--was rars.rics_specialismid
LEFT JOIN synapse_ce.[vwrics_rics_apc_rics_areaofpractice] rara on apc.rics_apcid = rara.apuk_enrolmentid--was rara.rics_apcid  
LEFT JOIN synapse_ce.vwRics_areaofpractice aop on aop.Rics_areaofpracticeId = rara.apuk_areaofpracticeid--was rara.rics_areaofpracticeid  
LEFT JOIN synapse_ce.[vwrics_rics_apc_rics_country] racb ON apc.rics_apcid = racb.apuk_enrolmentid--racb.rics_apcid 
LEFT JOIN synapse_ce.[vwrics_country] rc ON racb.rics_countryid = rc.Rics_countryId
INNER JOIN synapse_ce.vwRicsGroup g ON g.Rics_name = fc.rics_localgroupidName

LEFT JOIN synapse_ce.vwRicsSession AS sess
ON apc.rics_contactid = sess.contactid
AND fc.contactid = sess.contactid
LEFT JOIN synapse_ce.vwrics_industrysector IND ON IND.Rics_industrysectorId = apc.apuk_industrysectorid
LEFT JOIN [dbo].[vwD365MultiCurrencyBalances] OB ON OB.ACCOUNTNUM =fc.Rics_contactno 

WHERE apc.statecode = 0
AND fc.Rics_LapsedCode IS NULL
AND apc.rics_electiondate IS NULL
--AND fc.rics_membergrade IN (16,15,6,4) --added 16 - ref SD000000  needs to be student,APC Candidate,Associate Candidate,AssociateMember 
AND (fc.Rics_MemberGrade IN(200000000, 200000003) --Candidate , student
OR fc.apuk_designation IN(200000000)) --AssocRics
AND fc.StateCode = 0
AND apc.rics_submissionreceived IS NOT NULL
AND sess.rics_result IS NULL
AND sess.Rics_Date IS NULL
AND sess.statecode = 0

--AND fc.Rics_contactno = '0000000'
)
INSERT CE.tblD365DataCandidateScheduling
SELECT DISTINCT
ContactId,
rics_apcid, Rics_contactno, 
FullName, rics_counselloridName, CounsellorNo, rics_applicationtypeidname, rics_routeidname, 
rics_pathwayidname, rics_pathwayid, 
apuk_firstlocationchoiceidname, 
apuk_secondlocationchoiceidname, 
apuk_thirdlocationchoiceidname, 
AccountIdName, address1_line1, address1_line2, Address1_City, Address1_Country, 
address1_postalcode, 
--Rics_Disability, 
rics_localgroupidName,
ContactType,
MemberGrade, 
EMailAddress1, Telephone1, Rics_NumberofAttempts, 
Specialism, WorldRegion, SubmissionReceived, IndustrySector,
AreaOfPractice,
IntExperience,
PreviouslyReferred,
HasOutstandingBalance


--INTO  CE.tblD365DataCandidateScheduling
FROM cteCSData

SELECT ACCOUNTNUM,SUM([BalCur]) AS BalCur
INTO #Bal
FROM dbo.vwD365MultiCurrencyBalances
WHERE ACCOUNTNUM IN (SELECT Rics_ContactNo FROM CE.tblD365DataCandidateScheduling)
GROUP BY ACCOUNTNUM

UPDATE CE.tblD365DataCandidateScheduling
SET HasOutstandingBalance = 
CASE
	WHEN BalCur > 0 THEN 'Yes'
	ELSE 'No'
END
	FROM #Bal #
	WHERE #.ACCOUNTNUM = CE.tblD365DataCandidateScheduling.Rics_ContactNo

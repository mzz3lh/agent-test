CREATE VIEW CE.vwARC_Assessments_Bespoke AS 

WITH APP AS (
	SELECT
	 rics_apcid
	,CAST(Created_on AS DATE) AS 'Assessment Date'
	,YEAR(Created_on) AS 'Assessment Year'
	,CAST([rics_applicationenddate] AS DATE) AS 'Application End Date'
	,[rics_applicationtypeidname] 'Application Type'
	,[rics_contactno] AS 'Contact No'
	,CAST([rics_electiondate] AS DATE) AS 'Election Date'
	,CAST([rics_enrolmentdate] AS DATE) AS 'Enrolment Date'
	,YEAR([rics_enrolmentdate]) AS 'Enrolment Year'
	,[rics_pathwayidname] AS 'Pathway'
	,[rics_routeidname] AS 'Route'
	,[StateCode_Description] AS 'APC State'
	,[StatusCode_Description] AS 'APC Status'
	,CASE
		WHEN [StatusCode_Description] IN ('Withdrawn', 'Unsuccessful', 'Vetting Outcome Declined') THEN 'Failed'
		WHEN [StatusCode_Description] IN ('Pending Payment', 'In-progress', 'Vetting In-progress', 'Vetting Outcome Approved', 'Submitted for Assessment', 'Pending Ethics Module') THEN 'Pending'
		WHEN [StatusCode_Description] IN ('Completed - Student', 'Elected', 'Successful', 'Successful - Archived', 'Enrolled') THEN 'Successful'
		ELSE 'Unknown' END AS 'APC Status Group'
	,[EnrolmentType] As 'Enrolment Type'
	,DATEDIFF(d, CAST(rics_enrolmentdate AS DATE), CAST([rics_electiondate] AS DATE)) AS 'Days to Complete' 
	FROM [CE].[tblApplications]
),
APPCOUNT AS (
	SELECT
	 [Contact No]
	,COUNT([Contact No]) AS 'Record Count'
	FROM APP
	GROUP BY [Contact No]
),
APPMIN AS (
 	SELECT 
	rics_contactno
	,MIN(CAST(rics_enrolmentdate AS DATE)) AS FirstEnrolmentDate
	,MIN(CAST(rics_electiondate AS DATE)) AS FirstElectionDate
	FROM CE.vwApplications
	WHERE rics_enrolmentdate IS NOT NULL
	GROUP BY rics_contactno
),
CONTACT AS (
SELECT 
 CON.Rics_contactno 'Contact No.'
--,Rics_LapsedCode_Description AS 'Lapsed Reason'
--,Rics_LapsedDate AS 'Lapsed Date'
,MemberGrade_Description AS 'Member Grade'
,apuk_applicanttype_description AS 'Applicant Type'
,CASE
	WHEN GenderCode_Description IS NULL THEN 'Not Known'
	WHEN GenderCode_Description IN ('Male', 'Female') THEN GenderCode_Description 
	ELSE 'Not Known' END AS 'Gender'
,AdjustedAge AS 'Age'
,CON.rics_localgroupid
,rics_pathwaytomembershipidName AS 'Pathway to Membership'
,FirstEnrolmentDate AS 'First Enrolment Date'
,FirstElectionDate AS 'First Election Date'
FROM CE.vwContact CON
INNER JOIN APPMIN
	ON APPMIN.rics_contactno = CON.Rics_contactno
LEFT JOIN CE.vwLocalGroup LG
	ON LG.apuk_localgroupid = CON.rics_localgroupid
WHERE Rics_LapsedCode IS NULL
AND CON.StateCode = 0
AND CON.Rics_MemberGrade IN (200000000, 200000001, 200000002)
)

SELECT 
 CON.*
,APPCOUNT.[Record Count]
,APP.*
FROM CONTACT CON
INNER JOIN APP APP
	ON CON.[Contact No.] = APP.[Contact No]
LEFT JOIN APPCOUNT APPCOUNT
	ON CON.[Contact No.] = APPCOUNT.[Contact No]

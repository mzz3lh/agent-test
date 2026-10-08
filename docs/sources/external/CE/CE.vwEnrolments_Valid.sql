CREATE    VIEW [CE].[vwEnrolments_Valid] AS

WITH cteEnrValid
AS
(

	SELECT 
	 [ENR ID]
	,[Enrolment Name]
	,[Created Datetime]
	,[Created Date]
	,[Created By]
	,[End Date]
	,[Application Type ID]
	,[Application Type]
	,[Contact No]
	,[Contact ID]
	,[Election Date]
	,CASE WHEN [Enrolment Date] < '1980-01-01' THEN '1980-01-01' ELSE [Enrolment Date] END AS 'Enrolment Date'
	,CASE WHEN [Enrolment Date] < '1980-01-01' THEN 1980 ELSE YEAR([Enrolment Date]) END AS 'Enrolment Year'
	,[Number of Attempts]
	,expected_final_date AS 'Expected Final Date'
	,[Enrolment Local Group ID]
	,[Pathway ID]
	,[Pathway]
	,[Route ID]
	,[Route]
	,[Enrolment Type ID]
	,[Enrolment Type]
	,[Outcome ID]
	,[Outcome]
	,[State Code]
	,[State]
	,[Status Code]
	,[Status]
	,[apuk_ricsrecordid]
	,[ARC Assessment Status]
	,[Approved By Counsellor]
	,[Competency Selection Completed Date]
	,[Case Study Status]
	,[Case Study Feedback]
	,[Summary of Experience Status]
	,[Summary of Experience Feedback]
	,[Preliminary Submission Received]
	,[Submission Received]
	,CASE [apuk_corporateenrolment] --Added by PS 31/10/2024 ref U/S 64962
		WHEN 'True' THEN 'Yes'
		WHEN 'False' THEN 'No'
		ELSE 'No'
	END AS [apuk_corporateenrolment]

	FROM [synapse_ce].[vwEnrolments]
	WHERE [Route ID] IN  --(Route replaces Enrolment type as per meeting 17/11/2023)
	(
	'00000000-0000-0000-0000-000000000000', --APC Other
	'00000000-0000-0000-0000-000000000000', --APC Prelim,
	'00000000-0000-0000-0000-000000000000', --APC Research,
	'00000000-0000-0000-0000-000000000000', --APC Structured Training 12,
	'00000000-0000-0000-0000-000000000000', --APC Structured Training 24,
	'00000000-0000-0000-0000-000000000000', --Associate Assessment,
	'00000000-0000-0000-0000-000000000000', --Senior Professional Assessment – 2017,
	'00000000-0000-0000-0000-000000000000' --Specialist Assessment

	,'00000000-0000-0000-0000-000000000000'  --Acedemic  --Added DBA/PS 04/03/2024 - US 55324
	
	)	
/************** Enrolment type taken out as per meeting 17/11/2023***********************
		(--[Enrolment Type ID] IS NULL OR --Temp inclusion
		[Enrolment Type ID] NOT IN (
		 '000000000' --APC - Progression AssocRICS - MRICS
		,'000000000' --APC - Registered Valuer Top Up
		,'000000000' --Assoc - Associate Direct Entry
		,'000000000' --Direct Entry
		,'000000000' --FRICS - Fellowship Application
		,'000000000' --Non Applicant Type
		,'000000000' --Student
		))
****************************************************************************************/


	AND (--[Application Type ID] IS NULL OR --Temp Inclusion
		[Application Type ID] NOT IN (
		 '00000000-0000-0000-0000-000000000000' --Chartered Alternative Designation
		,'00000000-0000-0000-0000-000000000000' --Alternative Designation
		,'00000000-0000-0000-0000-000000000000' --Apprenticeship
		,'00000000-0000-0000-0000-000000000000' --Credential Application
		,'00000000-0000-0000-0000-000000000000' --Direct Entry  --Removed DBA/PS 06/03/2024 this is affecting the data set for CE.Contact_ElectionDemo where DE IS required
		,'00000000-0000-0000-0000-000000000000' --Fellowship 
		,'00000000-0000-0000-0000-000000000000' --Honorary
		,'00000000-0000-0000-0000-000000000000' --Re-admission
		,'00000000-0000-0000-0000-000000000000' --Scheme
		,'00000000-0000-0000-0000-000000000000' --Student
		))
	--AND [State Code] = 0 --Active  --taken out as per meeting 17/11/2023
	AND [Enrolment Date] IS NOT NULL
	AND NOT([Election Date] IS NULL AND [End Date] IS NOT NULL) 
	)
	
	
	SELECT cte.*, lg.[budget_region] + '_' + convert(varchar,DATEADD(month, DATEDIFF(month, 0, cte.[Enrolment Date]), 0),112) AS [Budget_Key]
	FROM cteEnrValid cte
		LEFT JOIN [CE].[vwLocalGroup] lg
			ON cte.[Enrolment Local Group ID] = lg.[apuk_localgroupid]
	WHERE cte.[ENR ID] NOT IN (SELECT [ENR ID] FROM cteEnrValid
						WHERE [End Date] <= DATEADD(dd,14,[Enrolment Date])) --End date could be due to cancelling during 14 Day cool off period. Therefore a non-payer. U/S 55339.

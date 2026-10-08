CREATE      VIEW [CE].[vwEnrolments_Last] AS


	SELECT *
	FROM CE.tbl_Enrolments_Last

	--RM, 2025-10-29
	--Stored into a table due to bad performance

/*
--Chooses the earliest Enrolment Record for each Contact in order to measure 'First Enrolment'
	WITH CTE AS (
	SELECT
	 [ENR ID]
	,ROW_NUMBER() OVER (PARTITION BY [Contact ID] ORDER BY [Enrolment Date], [Created date] DESC) AS ROWNUM
	FROM CE.vwEnrolments
	WHERE [Election Date] IS NOT NULL
	)

	SELECT
	 ENR.[ENR ID]
    ,ENR.[Enrolment Name]
    ,ENR.[Created Datetime]
    ,ENR.[Created Date]
    ,ENR.[Created By]
    ,ENR.[End Date]
    ,ENR.[Application Type ID]
    ,ENR.[Application Type]
    ,ENR.[Contact No]
    ,ENR.[Contact ID]
    ,ENR.[Election Date]
    ,ENR.[Enrolment Date]
	,ENR.[Enrolment Year]
    ,ENR.[Number of Attempts]
    ,ENR.[Expected Final Date]
    ,ENR.[Enrolment Local Group ID]
    ,ENR.[Pathway ID]
    ,ENR.[Pathway]
    ,ENR.[Route ID]
    ,ENR.[Route]
    ,ENR.[Enrolment Type ID]
    ,ENR.[Enrolment Type]
    ,ENR.[Outcome ID]
    ,ENR.[Outcome]
    ,ENR.[State Code]
    ,ENR.[State]
    ,ENR.[Status Code]
    ,ENR.[Status]
	,ENR.[ARC Assessment Status] --added 28/06/2024 - DBA/PS - for Alex Durston
	,ENR.[Approved By Counsellor] --added 28/06/2024 - DBA/PS
	,ENR.[Competency Selection Completed Date] --added 28/06/2024 - DBA/PS
	,ENR.[Case Study Status] --added 28/06/2024 - DBA/PS
	,ENR.[Summary of Experience Status] --added 28/06/2024 - DBA/PS
	,ENR.[Submission Received] --added 28/06/2024 - DBA/PS
	,CASE ENR.[Corporate Enrolment] --add DBA/PS 05/11/2024 to bring in line with other enrolment views and to add to Election Demographics (see note on that view)
		WHEN 'True' THEN 'Yes'
		WHEN 'False' THEN 'No'
		ELSE 'No'
	END AS [Corporate Enrolment]
	,rt.[Application_Type] AS [Application Entry Type]
	,ENR.[apuk_highestprofessionalbody]
	,ENR.[apuk_highestqualification]
	,ENR.[apuk_highestprofessionalbodylookupname]
	,ENR.[apuk_firstqualifiedlocalgroup]
	,ENR.[apuk_firstqualifiedlocalgroupname]
	FROM CE.vwEnrolments ENR
		LEFT JOIN [CE].[vwRics_Route] rt
			ON ENR.[Route ID] = rt.[Rics_routeId]
	WHERE EXISTS (
		SELECT 
		[ENR ID]
		FROM CTE
		WHERE CTE.[ENR ID] = ENR.[ENR ID]
		AND CTE.ROWNUM = 1
		)
	
	AND ENR.[Application Type] NOT IN
		(
		'Student',
		'Scheme',
		'Chartered Alternative Designation',
		'Accreditation Application',
		'Additional Role',
		'Alternative Designation',
		'Appeal',
		'Apprenticeship',
		'Complaint Report',
		'Concession',
		'Credential Application',
		'Deceased',
		'Deferral Application',
		'Fixed Penalty Review',
		'Mentor',
		'Re-admission',
		'Recognised Qualification',
		'Removal',
		'Resignation',
		'Route Change',
		'Fellowship'
	)
	AND enr.[Route] <> 'Registered Valuer Top Up'

*/

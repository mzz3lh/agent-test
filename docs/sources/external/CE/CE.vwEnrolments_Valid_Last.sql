CREATE   VIEW [CE].[vwEnrolments_Valid_Last] AS
--Chooses the earliest Enrolment Record for each Contact in order to measure 'First Enrolment'
	WITH CTE AS (
	SELECT
	 [ENR ID]
	,ROW_NUMBER() OVER (PARTITION BY [Contact ID] ORDER BY [Enrolment Date] DESC) AS ROWNUM
	FROM CE.vwEnrolments
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
	,ENR.[apuk_ricsrecordid]
	,ENR.[ARC Assessment Status]
	,ENR.[Approved By Counsellor]
	,ENR.[Competency Selection Completed Date]
	,ENR.[Case Study Status]
	,ENR.[Case Study Feedback]
	,ENR.[Summary of Experience Status]
	,ENR.[Summary of Experience Feedback]
	,ENR.[Preliminary Submission Received]
	,ENR.[Submission Received]

	FROM CE.vwEnrolments_Valid ENR
	WHERE EXISTS (
		SELECT 
		[ENR ID]
		FROM CTE
		WHERE CTE.[ENR ID] = ENR.[ENR ID]
		AND CTE.ROWNUM = 1
		)

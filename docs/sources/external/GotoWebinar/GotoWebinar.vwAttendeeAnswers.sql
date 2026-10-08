CREATE   VIEW [GotoWebinar].[vwAttendeeAnswers]
As
SELECT 
	CAST([WebinarKey] AS NVARCHAR(20)) + '_' + CAST([SessionKey] AS NVARCHAR(20)) + '_' + CAST([RegistrantKey] AS NVARCHAR(20)) AS AttendeeSessionKey
	,[WebinarKey]
	,[sessionkey]
	,[RegistrantKey]
	,[questiontype]
	,[question]
	,[answer]
	,'Survey' AS [Engagement Type]
FROM [GoToWebinar].[tblAttendeeAnswers]

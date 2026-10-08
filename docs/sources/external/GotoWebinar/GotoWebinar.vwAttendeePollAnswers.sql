CREATE   VIEW [GotoWebinar].[vwAttendeePollAnswers]
AS
SELECT 
	CAST([WebinarKey] AS NVARCHAR(20)) + '_' + CAST([SessionKey] AS NVARCHAR(20)) + '_' + CAST([RegistrantKey] AS NVARCHAR(20)) AS AttendeeSessionKey
	,[WebinarKey]
	,[sessionkey]
	,[RegistrantKey]
	,[questiontype]
	,[question]
	,[answers] AS [answer]
	,[dateAsked] AS [Date Asked]
	,'Poll' As [Engagement Type]
FROM [GoToWebinar].[tblAttendeePollAnswers]

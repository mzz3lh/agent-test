CREATE   VIEW [GotoWebinar].[vwAttendeeResponses]
AS
SELECT 
	[RegistrantKey],
	[SessionKey],
	[WebinarKey],
	[answer],
	[question],
	[questionType],
	'Survey' AS [EngagementType],
	NULL AS [DateAsked]
FROM [GoToWebinar].[tblAttendeeAnswers]
UNION ALL
SELECT 
	[RegistrantKey],
	[SessionKey],
	[WebinarKey],
	[answers] AS [answer],
	[question],
	[questionType],
	'Poll' AS [EngagementType],
	[dateAsked] AS [DateAsked]
FROM [GoToWebinar].[tblAttendeePollAnswers]

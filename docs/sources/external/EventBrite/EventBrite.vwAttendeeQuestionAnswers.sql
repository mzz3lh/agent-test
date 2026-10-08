CREATE   VIEW [Eventbrite].[vwAttendeeQuestionAnswers]
AS
SELECT
	CAST([Attendee_Id] AS NVARCHAR(20)) + '_' + CAST([Event_Id] AS NVARCHAR(20)) + '_' + CAST([Organization_Id] AS NVARCHAR(20)) AS [AttendeeKey]
	,CAST([Event_Id] AS NVARCHAR(20)) + '_' + CAST([Organization_Id] AS NVARCHAR(20)) AS [EventKey]
	,[Event_Id]
	,[Attendee_Id]
	,[Question_Id]
	,[Answer]
	,[Organization_Id]
FROM [EventBrite].[tblAttendeeQuestions]

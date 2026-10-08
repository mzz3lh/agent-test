CREATE   PROCEDURE [EventBrite].[usp_Insert_AttendeeQuestions]
AS
BEGIN
	
	INSERT INTO [EventBrite].[tblAttendeeQuestions]
	(
		[Event_Id],
		[Attendee_Id],
		[Question_Id],
		[Question],
		[Answer],
		[Organization_Id]
	)
	SELECT
		src.[Event_Id],
		src.[Attendee_Id],
		src.[Question_Id],
		src.[Question],
		src.[Answer],
		src.[Organization_Id]
	FROM [Work].[tblAttendeeQuestions_EventBrite] src
		LEFT JOIN [EventBrite].[tblAttendeeQuestions] tgt
			ON 	src.[Organization_Id] = tgt.[Organization_Id] 
			AND src.[Event_Id] = tgt.[Event_Id]
			AND src.[Attendee_Id] = tgt.[Attendee_Id]
			AND src.[Question_Id] = tgt.Question_Id
	WHERE tgt.[Attendee_Id] IS NULL

END

CREATE   PROCEDURE [EventBrite].[usp_Update_AttendeeQuestions]
AS
BEGIN
	
	UPDATE tgt SET 
		tgt.[Question] = src.[Question],
		tgt.[Answer] = src.[Answer]
	FROM [EventBrite].[tblAttendeeQuestions] tgt
		INNER JOIN [Work].[tblAttendeeQuestions_EventBrite] src
			ON 	src.[Organization_Id] = tgt.[Organization_Id] 
			AND src.[Event_Id] = tgt.[Event_Id]
			AND src.[Attendee_Id] = tgt.[Attendee_Id]
			AND src.[Question_Id] = tgt.Question_Id


END

CREATE   PROCEDURE [SurveyMonkey].[usp_Insert_SurveyResponse_AnsweredQuestions]
AS
BEGIN

	INSERT INTO [SurveyMonkey].[tblSurveyResponse_AnsweredQuestions]
	(
		[SurveyResponseAnsweredQuestionsId],
		[SurveyResponseLinkId],
		[Survey_Id],
		[SurveyQuestionId],
		[LastImportedOn]
	)
	SELECT 
		wrk.[SurveyResponseAnsweredQuestionsId],
		wrk.[SurveyResponseLinkId],
		wrk.[Survey_Id],
		wrk.[SurveyQuestionId],
		GETDATE()
	FROM [Work].[tblSurveyResponse_AnsweredQuestions] wrk
		LEFT JOIN [SurveyMonkey].[tblSurveyResponse_AnsweredQuestions] tgt
			ON 	tgt.[SurveyResponseAnsweredQuestionsId] = wrk.[SurveyResponseAnsweredQuestionsId]
				AND tgt.[SurveyResponseLinkId] = wrk.[SurveyResponseLinkId]
				AND tgt.[Survey_Id] = wrk.[Survey_Id] 

	WHERE tgt.[SurveyResponseAnsweredQuestionsId] IS NULL

END

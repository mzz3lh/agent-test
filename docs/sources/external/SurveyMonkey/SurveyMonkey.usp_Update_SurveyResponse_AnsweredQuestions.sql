CREATE   PROCEDURE [SurveyMonkey].[usp_Update_SurveyResponse_AnsweredQuestions]
AS
BEGIN

	UPDATE tgt SET
		tgt.[SurveyQuestionId] = src.[SurveyQuestionId],
		tgt.[LastImportedOn] = GETDATE()
	FROM [SurveyMonkey].[tblSurveyResponse_AnsweredQuestions] tgt
		INNER JOIN [Work].[tblSurveyResponse_AnsweredQuestions] src
			ON 	tgt.[SurveyResponseAnsweredQuestionsId] = src.[SurveyResponseAnsweredQuestionsId]
				AND tgt.[SurveyResponseLinkId] = src.[SurveyResponseLinkId]
				AND tgt.[Survey_Id] = src.[Survey_Id] 

END

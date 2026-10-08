CREATE PROCEDURE [Work].[usp_Insert_SurveyResponse_AnsweredQuestions]
AS
BEGIN

	INSERT INTO [SurveyMonkey].[tblSurveyResponse_AnsweredQuestions]
	(
		[SurveyResponseAnsweredQuestionsId],
		[SurveyResponseLinkId],
		[Survey_Id],
		[SurveyQuestionId],
		[BI_Created]
	)
	SELECT 
		wrk.[SurveyResponseAnsweredQuestionsId],
		wrk.[SurveyResponseLinkId],
		wrk.[Survey_Id],
		wrk.[SurveyQuestionId],
		GETDATE()
	FROM [Work].[tblSurveyResponse_AnsweredQuestions] wrk
		LEFT JOIN [SurveyMonkey].[tblSurveyResponse_AnsweredQuestions] tgt
			ON wrk.[SurveyResponseAnsweredQuestionsId] = tgt.[SurveyResponseAnsweredQuestionsId]
				AND wrk.[SurveyResponseLinkId] = tgt.[SurveyResponseLinkId]	
				AND wrk.Survey_Id = tgt.Survey_Id			
	WHERE tgt.[SurveyResponseAnsweredQuestionsId] IS NULL

END

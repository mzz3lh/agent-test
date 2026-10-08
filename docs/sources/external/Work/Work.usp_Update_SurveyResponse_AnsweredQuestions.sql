CREATE PROCEDURE [Work].[usp_Update_SurveyResponse_AnsweredQuestions]
AS
BEGIN

	UPDATE tgt SET
		tgt.[Survey_Id] = src.[Survey_Id],
		tgt.[SurveyQuestionId] = src.[SurveyQuestionId],
		tgt.[BI_Modified] = getdate()
	FROM [SurveyMonkey].[tblSurveyResponse_AnsweredQuestions] tgt
		INNER JOIN
			(
				SELECT
					wrk.[SurveyResponseAnsweredQuestionsId],
					wrk.[SurveyResponseLinkId],
					wrk.[Survey_Id],
					wrk.[SurveyQuestionId]
				FROM [Work].[tblSurveyResponse_AnsweredQuestions] wrk
			) src
			ON tgt.[SurveyResponseAnsweredQuestionsId] = src.[SurveyResponseAnsweredQuestionsId]
				AND tgt.[SurveyResponseLinkId] = src.[SurveyResponseLinkId]
				AND tgt.[Survey_Id] = src.[Survey_Id]


END

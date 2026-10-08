CREATE PROCEDURE [Work].[usp_Insert_SurveyResponse_AnsweredValues]
AS
BEGIN

	-- DELETE EXISTING
	DELETE FROM SurveyMonkey.tblSurveyResponse_AnsweredValues 
	WHERE Survey_Id IN (SELECT DISTINCT Survey_Id FROM Work.tblSurveyResponse_AnsweredValues)


	INSERT INTO [SurveyMonkey].[tblSurveyResponse_AnsweredValues]
	(
		[SurveyResponseAnsweredQuestionsLinkId],
		[Survey_Id],
		[SurveyQuestionChoiceId],
		[Answer_Text],
		[BI_Created]
	)
	SELECT 
		wrk.[SurveyResponseAnsweredQuestionsLinkId],
		wrk.[Survey_Id],
		wrk.[SurveyQuestionChoiceId],
		wrk.[Answer_Text],
		GETDATE()
	FROM [Work].[tblSurveyResponse_AnsweredValues] wrk
	--	LEFT JOIN [SurveyMonkey].[tblSurveyResponse_AnsweredValues] tgt
	--		ON wrk.[SurveyResponseAnsweredQuestionsId] = tgt.[SurveyResponseAnsweredQuestionsId]				
	--WHERE tgt.[SurveyResponseAnsweredQuestionsId] IS NULL

END

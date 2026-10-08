CREATE   PROCEDURE [SurveyMonkey].[usp_Update_SurveyResponse_AnsweredValues]
AS
BEGIN

	UPDATE tgt SET
		tgt.[SurveyResponseAnsweredQuestionsLinkId] = src.[SurveyResponseAnsweredQuestionsLinkId],
		tgt.[Survey_Id] = src.[Survey_Id],
		tgt.[SurveyQuestionChoiceId] = src.[SurveyQuestionChoiceId],
		tgt.[Col_Id] = src.[Col_Id],
		tgt.[Other_Id] = src.[Other_Id],
		tgt.[Row_Id] = src.[Row_Id],
		tgt.[Answer_Text] = src.[Answer_Text],
		tgt.[LastImportedOn] = GETDATE()
	FROM [SurveyMonkey].[tblSurveyResponse_AnsweredValues] tgt
		INNER JOIN [Work].[tblSurveyResponse_AnsweredValues] src
			ON 	tgt.[SurveyResponseAnsweredValuesId] = src.[SurveyResponseAnsweredValuesId]

END

CREATE   PROCEDURE [SurveyMonkey].[usp_Update_SurveyQuestionChoices]
AS
BEGIN

	UPDATE tgt SET
		tgt.[Choice_Score] = src.[Choice_Score],
		tgt.[Choice_Text] = src.[Choice_Text],
		tgt.[Position] = src.[Position],
		tgt.[Visible] = src.[Visible],
		tgt.[Weight] = src.[Weight],
		tgt.[LastImportedOn] = getdate()
	FROM [SurveyMonkey].[tblSurveyQuestionChoices] tgt
		INNER JOIN [Work].[tblSurveyQuestionChoices] src
			ON tgt.[SurveyQuestionChoiceId] = src.[SurveyQuestionChoiceId]
				AND tgt.[SurveyQuestionId] = src.[SurveyQuestionId] 
				AND tgt.[Survey_Id] = src.[Survey_Id]

END

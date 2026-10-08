CREATE   PROCEDURE [SurveyMonkey].[usp_Update_SurveyChoiceHeaders]
AS
BEGIN

	UPDATE tgt SET
		tgt.[Header_Text] = src.[Header_Text],
		tgt.[Header_Type] = src.[Header_Type],
		tgt.[LastImportedOn] = getdate()
	FROM [SurveyMonkey].[tblSurveyChoiceHeaders] tgt
		INNER JOIN [Work].[tblSurveyChoiceHeaders] src
			ON tgt.[SurveyQuestionId] = src.[SurveyQuestionId]
				AND tgt.[Survey_Id] = src.[Survey_Id]
				AND tgt.[Position] = src.[Position]
				AND tgt.[Visible] = src.[Visible]

END

CREATE PROCEDURE [Work].[usp_Update_SurveyQuestionChoices]
AS
BEGIN

	UPDATE tgt SET
		tgt.[SurveyQuestionId] = src.[SurveyQuestionId],
		tgt.[Survey_Id] = src.[Survey_Id],
		tgt.[Choice_Score] = src.[Choice_Score],
		tgt.[Choice_Text] = src.[Choice_Text],
		tgt.[Position] = src.[Position],
		tgt.[Visible] = src.[Visible],
		tgt.[Weight] = src.[Weight],
		tgt.[BI_Modified] = getdate()
	FROM [SurveyMonkey].[tblSurveyQuestionChoices] tgt
		INNER JOIN
			(
				SELECT
					wrk.[SurveyQuestionChoiceId],
					wrk.[SurveyQuestionId],
					wrk.[Survey_Id],
					wrk.[Choice_Score],
					wrk.[Choice_Text],
					wrk.[Position],
					wrk.[Visible],
					wrk.[Weight]
				FROM [Work].[tblSurveyQuestionChoices] wrk
			) src
			ON tgt.[SurveyQuestionChoiceId] = src.[SurveyQuestionChoiceId]
				AND tgt.[Survey_Id] = src.[Survey_Id]

END

CREATE PROCEDURE [Work].[usp_Insert_SurveyQuestionChoices]
AS
BEGIN

	INSERT INTO [SurveyMonkey].[tblSurveyQuestionChoices]
	(
		[SurveyQuestionChoiceId],
		[SurveyQuestionId],
		[Survey_Id],
		[Choice_Score],
		[Choice_Text],
		[Position],
		[Visible],
		[Weight],
		[BI_Created]
	)
	SELECT 
		wrk.[SurveyQuestionChoiceId],
		wrk.[SurveyQuestionId],
		wrk.[Survey_Id],
		wrk.[Choice_Score],
		wrk.[Choice_Text],
		wrk.[Position],
		wrk.[Visible],
		wrk.[Weight],
		GETDATE()
	FROM [Work].[tblSurveyQuestionChoices] wrk
		LEFT JOIN [SurveyMonkey].[tblSurveyQuestionChoices] tgt
			ON wrk.[SurveyQuestionChoiceId] = tgt.[SurveyQuestionChoiceId]
	WHERE tgt.[SurveyQuestionChoiceId] IS NULL

END

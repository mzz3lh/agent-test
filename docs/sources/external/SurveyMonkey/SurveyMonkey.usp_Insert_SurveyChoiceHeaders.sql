CREATE   PROCEDURE [SurveyMonkey].[usp_Insert_SurveyChoiceHeaders]
AS
BEGIN

	INSERT INTO [SurveyMonkey].[tblSurveyChoiceHeaders]
	(
		[SurveyQuestionId],
		[Position],
		[Survey_Id],
		[Header_Text],
		[Header_Type],
		[Visible],
		[LastImportedOn]
	)
	SELECT 
		wrk.[SurveyQuestionId],
		wrk.[Position],
		wrk.[Survey_Id],
		wrk.[Header_Text],
		wrk.[Header_Type],
		wrk.[Visible],
		GETDATE()
	FROM [Work].[tblSurveyChoiceHeaders] wrk
		LEFT JOIN [SurveyMonkey].[tblSurveyChoiceHeaders] tgt
			ON wrk.[SurveyQuestionId] = tgt.[SurveyQuestionId]
				AND wrk.[Survey_Id] = tgt.[Survey_Id]
				AND wrk.[Position] = tgt.[Position]
				AND wrk.[Visible] = tgt.[Visible]
	WHERE tgt.[SurveyQuestionId] IS NULL

END

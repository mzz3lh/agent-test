CREATE   PROCEDURE [SurveyMonkey].[usp_Insert_SurveyQuestions]
AS
BEGIN

	INSERT INTO [SurveyMonkey].[tblSurveyQuestions]
	(
		[SurveyQuestionId],
		[Survey_Id],
		[Link_Id],
		[Heading],
		[Position],
		[Subtype],
		[Visible],
		[LastImportedOn]
	)
	SELECT 
		wrk.[SurveyQuestionId],
		wrk.[Survey_Id],
		wrk.[Link_Id],
		wrk.[Heading],
		wrk.[Position],
		wrk.[Subtype],
		wrk.[Visible],
		GETDATE()
	FROM [Work].[tblSurveyQuestions] wrk
		LEFT JOIN [SurveyMonkey].[tblSurveyQuestions] tgt
			ON wrk.[SurveyQuestionId] = tgt.[SurveyQuestionId]
				AND wrk.[Survey_Id] = tgt.[Survey_Id]
	WHERE tgt.[SurveyQuestionId] IS NULL

END

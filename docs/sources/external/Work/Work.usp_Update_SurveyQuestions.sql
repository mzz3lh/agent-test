CREATE PROCEDURE [Work].[usp_Update_SurveyQuestions]
AS
BEGIN

	UPDATE tgt SET
		tgt.[Link_Id] = src.[Link_Id],
		tgt.[Heading] = src.[Heading],	
		tgt.[Position] = src.[Position],
		tgt.[Subtype] = src.[Subtype],
		tgt.[Visible] = src.[Visible],
		tgt.[BI_Modified] = getdate()
	FROM [SurveyMonkey].[tblSurveyQuestions] tgt
		INNER JOIN
			(
				SELECT
					wrk.[SurveyQuestionId],
					wrk.[Survey_Id],
					wrk.[Link_Id],
					wrk.[Heading],
					wrk.[Position],
					wrk.[Subtype],
					wrk.[Visible]
				FROM [Work].[tblSurveyQuestions] wrk
			) src
			ON tgt.[SurveyQuestionId] = src.[SurveyQuestionId]
				AND tgt.[Survey_Id] = src.[Survey_Id]

END

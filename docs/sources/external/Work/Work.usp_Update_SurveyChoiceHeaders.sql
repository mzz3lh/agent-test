CREATE PROCEDURE [Work].[usp_Update_SurveyChoiceHeaders]
AS
BEGIN

	UPDATE tgt SET
		tgt.[Survey_Id] = src.[Survey_Id],
		tgt.[Header_Text] = src.[Header_Text],
		tgt.[Header_Type] = src.[Header_Type],
		tgt.[Visible] = src.[Visible],
		tgt.[BI_Modified] = getdate()
	FROM [SurveyMonkey].[tblSurveyChoiceHeaders] tgt
		INNER JOIN
			(
				SELECT
					wrk.[SurveyQuestionId],
					wrk.[Position],
					wrk.[Survey_Id],
					wrk.[Header_Text],
					wrk.[Header_Type],
					wrk.[Visible]
				FROM [Work].[tblSurveyChoiceHeaders] wrk
			) src
			ON tgt.[SurveyQuestionId] = src.[SurveyQuestionId]
				AND tgt.[Position] = src.[Position]

END

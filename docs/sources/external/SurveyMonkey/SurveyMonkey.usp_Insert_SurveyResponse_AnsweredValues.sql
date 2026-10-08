CREATE     PROCEDURE [SurveyMonkey].[usp_Insert_SurveyResponse_AnsweredValues]
				  
AS
BEGIN

	DECLARE @survey_id BIGINT

	SELECT @survey_id = MAX(survey_id) FROM work.tblSurveyResponse_AnsweredValues

	--Delete existing
	DELETE FROM [SurveyMonkey].[tblSurveyResponse_AnsweredValues]
	WHERE Survey_Id  =@survey_id

	INSERT INTO [SurveyMonkey].[tblSurveyResponse_AnsweredValues]
	(
		--[SurveyResponseAnsweredValuesId],
		[SurveyResponseAnsweredQuestionsLinkId],
		[Survey_Id],
		[SurveyQuestionChoiceId],
		[Col_Id],
		[Other_Id],
		[Row_Id],
		[Answer_Text],
		[LastImportedOn]
	)
	SELECT 
		--wrk.[SurveyResponseAnsweredValuesId],
		wrk.[SurveyResponseAnsweredQuestionsLinkId],
		wrk.[Survey_Id],
		wrk.[SurveyQuestionChoiceId],
		wrk.[Col_Id],
		wrk.[Other_Id],
		wrk.[Row_Id],
		wrk.[Answer_Text],
		GETDATE()
	FROM [Work].[tblSurveyResponse_AnsweredValues] wrk
--		LEFT JOIN [SurveyMonkey].[tblSurveyResponse_AnsweredValues] tgt
--			ON 	tgt.[SurveyResponseAnsweredValuesId] = wrk.[SurveyResponseAnsweredValuesId]
--	WHERE tgt.[SurveyResponseAnsweredValuesId] IS NULL

	--Update ReadyToLoadResponse flag

END

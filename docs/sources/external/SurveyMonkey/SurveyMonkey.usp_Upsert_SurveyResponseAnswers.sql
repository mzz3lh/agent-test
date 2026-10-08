CREATE   PROCEDURE [SurveyMonkey].[usp_Upsert_SurveyResponseAnswers]
AS
BEGIN

	-- Delete existing responses
	DELETE tgt FROM [SurveyMonkey].[tblSurveyResponseAnswers] tgt
		INNER JOIN [work].[tblSurveyResponseAnswers] src
			ON tgt.[survey_id] = src.[survey_id]
			AND tgt.[survey_response_id] = src.[survey_response_id]

	--Load responses
	INSERT INTO [SurveyMonkey].[tblSurveyResponseAnswers]
	(
		[survey_response_id],
		[survey_id],
		[answer_choice_id],
		[answer_other_id],
		[answer_other_text],
		[answer_text],
		[question_id],
		[question_variable_id],
		[survey_custom_value],
		[survey_date_created],
		[survey_date_modified],    
		[survey_status],
		[survey_custom_variables],
		[survey_recipient_id]
	)
	SELECT 
		src.[survey_response_id],
		src.[survey_id],
		src.[answer_choice_id],
		src.[answer_other_id],
		src.[answer_other_text],
		src.[answer_text],
		src.[question_id],
		src.[question_variable_id],
		src.[survey_custom_value],
		src.[survey_date_created],
		src.[survey_date_modified],    
		src.[survey_status],
		src.[survey_custom_variables],
		src.[survey_recipient_id]

	FROM [Work].[tblSurveyResponseAnswers] src
		
END

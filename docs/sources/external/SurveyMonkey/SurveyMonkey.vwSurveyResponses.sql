CREATE     VIEW [SurveyMonkey].[vwSurveyResponses]
AS
SELECT 
	/*  Modified by Raj on 2024-09-09 ***********

	s.[id] AS [SurveyId],
	s.[Nickname],
	s.[Title] AS [Survey Title],
	s.[Question_Count],
	s.[Response_Count],
	--CONVERT(DATE, s.[Date_Created]) AS [Survey Created Date],
	--CONVERT(DATE, sr.[Date_Created]) AS [Response Date],
	s.[Date_Created] AS [Survey Created Date],
	sr.[Date_Created] AS [Response Date],
	
	sr.[Response_Status],
	sr.[SKUCode],
	CAST(sr.[CourseTitle] AS NVARCHAR(500)) AS [CourseTitle],
	sr.[Trainer],
	sr.[SurveyResponseId],
	saq.[SurveyQuestionId], 
	CAST(sav.[Answer_Text] AS NVARCHAR(600)) AS [Answer_Text],
	sqc.[Choice_Text],
	sqc.[Choice_Score],
	sqc.[Weight],
	sqc.[Position] AS [Question Choice Position], 
	ISNULL(sq.[Processed_Heading], sq1.[Processed_Heading]) AS [Question Heading],
	sq.[Position] AS [Question Position],
	ISNULL(sq.[Subtype], sq1.[Subtype]) AS [Subtype], 
	sch.[Header_Text] AS [Choice Header],
	sr.[Custom_Variables]
	/*
	CASE 
		WHEN CHARINDEX('UID', sr.custom_variables) > 0 THEN 
			SUBSTRING(sr.Custom_Variables, 9, CHARINDEX(',', sr.Custom_Variables)-10)
		ELSE NULL
	END Rics_Contactno--,
	*/
/*
	ROW_NUMBER() OVER(PARTITION BY s.[id] ORDER BY s.[Title]) AS [RowNo]
*/

*/
	s.[id] AS [SurveyId], 
	s.[Nickname], 
	s.[Title] AS [Survey Title], 
	s.[Question_Count], 
	s.[Response_Count], 
	s.[Date_Created] AS [Survey Created Date],
	sr.[survey_date_created] AS [Response Date], 
	sr.[survey_status] AS [Response_Status], 
	NULL AS [SKUCode],
	NULL AS [CourseTitle],
	NULL AS [Trainer],
	sr.[answer_other_text] AS [Other Answer],
	sr.[survey_response_id] AS [SurveyResponseId],
	sr.[question_id] AS [SurveyQuestionId], 
	sr.[answer_text] AS [Answer_Text], 
	ch.[Choice_Text], 
	ch.[Choice_Score], 
	ch.[Position] AS [Question Choice Position], 
	ch.[Weight], 
	qst.[Heading] AS [Question Heading], 
	qst.[Position] AS [Question Position],
	qst.[Subtype], 
	NULL AS [Choice Header], 
	sr.[survey_custom_value] AS [Custom Value], 
	sr.[survey_custom_variables] AS [Custom_Variables]
FROM SurveyMonkey.tblSurveys s
	INNER JOIN SurveyMonkey.tblSurveyResponseAnswers sr
		ON s.id = sr.Survey_Id
	LEFT JOIN [SurveyMonkey].[tblSurveyQuestions] qst
		ON s.[id] = qst.[Survey_Id]
		AND qst.[SurveyQuestionId] = sr.[question_id]
	LEFT JOIN [SurveyMonkey].[tblSurveyQuestionChoices] ch
		ON s.[id] = ch.[Survey_Id]
		AND qst.[SurveyQuestionId] = ch.[SurveyQuestionId]
		AND sr.[answer_choice_id] = ch.[SurveyQuestionChoiceId]
/*
	LEFT JOIN [SurveyMonkey].[tblSurveyChoiceHeaders] sch
		ON s.[id] = sch.[Survey_Id]
		AND qst.[SurveyQuestionId] = sch.[SurveyQuestionId]
		AND ch.[Position] = sch.[Position]
WHERE sr.[survey_response_id] = 00000000000
*/

CREATE PROCEDURE [SurveyMonkey].[usp_Update_SurveyResponses]
AS
BEGIN

	UPDATE tgt SET
		tgt.[Survey_Id] = src.[Survey_Id],
		tgt.[LinkId] = src.[LinkId],
		tgt.[Date_Created] = src.[Date_Created],
		tgt.[Date_Modified] = src.[Date_Modified],
		tgt.[Response_Status] = src.[Response_Status],
		tgt.[Total_Time] = src.[Total_Time],
		tgt.[Custom_Variables] = src.[Custom_Variables],
		tgt.[SKUCode] = src.[SKUCode],
		tgt.[CourseTitle] = src.[CourseTitle],
		tgt.[Trainer] = src.[Trainer],
		tgt.[ip_address] = src.[ip_address],
		tgt.[ReadyToLoadAnswers] = 1,
		tgt.[LastImportedOn] = GETDATE()
	FROM [SurveyMonkey].[tblSurveyResponses] tgt
		INNER JOIN [Work].[tblSurveyResponses] src
			ON tgt.[SurveyResponseId] = src.[SurveyResponseId]

END

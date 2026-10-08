CREATE   PROCEDURE [SurveyMonkey].[usp_Insert_SurveyResponses]
AS
BEGIN

	INSERT INTO [SurveyMonkey].[tblSurveyResponses]
	(
		[SurveyResponseId],
		[Survey_Id],
		[LinkId],
		[Date_Created],
		[Date_Modified],
		[Response_Status],
		[Total_Time],
		[Custom_Variables],
		[SKUCode],
		[CourseTitle],
		[Trainer],
		[ip_address],
		[ReadyToLoadAnswers],
		[LastImportedOn]
	)
	SELECT 
		wrk.[SurveyResponseId],
		wrk.[Survey_Id],
		wrk.[LinkId],
		wrk.[Date_Created],
		wrk.[Date_Modified],
		wrk.[Response_Status],
		wrk.[Total_Time],
		wrk.[Custom_Variables],
		wrk.[SKUCode],
		wrk.[CourseTitle],
		wrk.[Trainer],
		wrk.[ip_address],
		1,
		GETDATE()
	FROM [Work].[tblSurveyResponses] wrk
		LEFT JOIN [SurveyMonkey].[tblSurveyResponses] tgt
			ON wrk.[SurveyResponseId] = tgt.[SurveyResponseId]
	WHERE tgt.[SurveyResponseId] IS NULL

END

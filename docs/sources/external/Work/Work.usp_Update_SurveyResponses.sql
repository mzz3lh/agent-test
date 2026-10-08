CREATE PROCEDURE [Work].[usp_Update_SurveyResponses]
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
		tgt.[BI_Modified] = getdate()
	FROM [SurveyMonkey].[tblSurveyResponses] tgt
		INNER JOIN
			(
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
					wrk.[Trainer]
				FROM [Work].[tblSurveyResponses] wrk
			) src
			ON tgt.[SurveyResponseId] = src.[SurveyResponseId]


END

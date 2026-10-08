CREATE       PROCEDURE [SurveyMonkey].[usp_LoadSurveySummaryResults]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-09-19
	Description: Procedure to load all survey full details to a physical table which is to be source for reporting
*/
BEGIN
	Declare @st int = 0

	
	--Truncate the staging table before loading
	TRUNCATE TABLE [SurveyMonkey].[tblSurveySummaryResults]
	--Insert the results 
	INSERT INTO [SurveyMonkey].[tblSurveySummaryResults]
	(
		[SurveyId],
		[Nickname],
		[Survey Title],
		[Question_Count],
		[Response_Count],
		[Survey Created Date],
		[Response Date],
		[Response_Status],
		[SKUCode],
		[CourseTitle],
		[Trainer],
		[SurveyResponseId],
		[SurveyQuestionId],
		[Answer_Text],
		[Choice_Text],
		[Choice_Score],
		[Weight],
		[Question Choice Position],
		[Question Heading],
		[Question Position],
		[Subtype],
		[Choice Header],
		[Custom_Variables]--,
		--[Rics_Contactno]--,
		--[RowNo]
	)
	SELECT
		src.[SurveyId],
		src.[Nickname],
		src.[Survey Title],
		src.[Question_Count],
		src.[Response_Count],
		src.[Survey Created Date],
		src.[Response Date],
		src.[Response_Status],
		src.[SKUCode],
		src.[CourseTitle],
		src.[Trainer],
		src.[SurveyResponseId],
		src.[SurveyQuestionId],
		src.[Answer_Text],
		src.[Choice_Text],
		src.[Choice_Score],
		src.[Weight],
		src.[Question Choice Position],
		src.[Question Heading],
		src.[Question Position],
		src.[Subtype],
		src.[Choice Header],
		src.[Custom_Variables]--,
		--[Rics_Contactno]--,
		--[RowNo]
	FROM [SurveyMonkey].[vwSurveyResponses] src

	--Split custom variables into fields

	IF OBJECT_ID('tempdb..#testsplitvariables') IS NOT NULL
	BEGIN
		DROP TABLE #testsplitvariables
	END

	IF OBJECT_ID('tempdb..#testsplitfields') IS NOT NULL
	BEGIN
		DROP TABLE #testsplitfields
	END


	IF OBJECT_ID('tempdb..#testsurveysummaryresults') IS NOT NULL
	BEGIN
		DROP TABLE #testsurveysummaryresults
	END

	SELECT surveysummaryid, [value]
	INTO #testsplitvariables
	FROM surveymonkey.tblsurveysummaryresults src
		CROSS APPLY STRING_SPLIT(REPLACE(REPLACE(REPLACE(REPLACE(custom_variables, '","', '|'), '{', ''), '}', ''), '"', ''), '|')
	WHERE Custom_Variables <> '{}'

		--and surveyid = 000000000
 
	SELECT *, 
		IIF(CHARINDEX(':',value) > 0, SUBSTRING(value, 1, CHARINDEX(':',value)-1), '') as FieldName,
		IIF(CHARINDEX(':',value) > 0, SUBSTRING(value, CHARINDEX(':',value)+1, 150), '') as FieldValue
	INTO #testsplitfields
	FROM #testsplitvariables

	SELECT 
		surveysummaryid, 
		MAX(CASE WHEN FieldName='Client' THEN FieldValue END) AS Client,
		MAX(CASE WHEN FieldName='Module' THEN FieldValue END) AS Module,
		MAX(CASE WHEN FieldName='Format' THEN FieldValue END) AS [Format],
		MAX(CASE WHEN FieldName='SKU' THEN FieldValue END) AS SKU,
		MAX(CASE WHEN FieldName='Date' THEN FieldValue END) AS [Date],
		MAX(CASE WHEN FieldName='Event' OR FieldName = 'EV_Code' THEN FieldValue END) AS [Event],
		MAX(CASE WHEN FieldName='Region' THEN FieldValue END) AS Region,
		MAX(CASE WHEN FieldName='Topic' THEN FieldValue END) AS Topic,
		MAX(CASE WHEN FieldName='Trainer_Speaker' OR FieldName = 'Trainer' OR FieldName = 'Speaker_Trainer' THEN FieldValue END) AS Trainer_Speaker,
		MAX(CASE WHEN FieldName='Product' THEN FieldValue END) AS Product,
		MAX(CASE WHEN FieldName='Sector' THEN FieldValue END) AS Sector,
		MAX(CASE WHEN FieldName='TimeZone' THEN FieldValue END) AS TimeZone,
		MAX(CASE WHEN FieldName='Survey' THEN FieldValue END) AS Survey
	INTO #testsurveysummaryresults
	FROM #testsplitfields
	GROUP BY SurveySummaryId


	--Update target with split fields
	UPDATE tgt SET
		tgt.[Client] = tmp.[Client],
		tgt.[Date] = tmp.[Date],
		tgt.[Event] = tmp.[Event],
		tgt.[Format] = tmp.[Format],
		tgt.[Module] = tmp.[Module],
		tgt.[Product] = tmp.[Product],
		tgt.[Region] = tmp.[Region],
		tgt.[Sector] = tmp.[Sector],
		tgt.[SKU] = tmp.[SKU],
		tgt.[Survey] = tmp.[Survey],
		tgt.[TimeZone] = tmp.[TimeZone],
		tgt.[Topic] = tmp.[Topic],
		tgt.[Trainer_Speaker] = tmp.[Trainer_Speaker]
	FROM SurveyMonkey.tblSurveySummaryResults tgt
		INNER JOIN #testsurveysummaryresults tmp
			ON tgt.[SurveySummaryId] = tmp.[SurveySummaryId]


END

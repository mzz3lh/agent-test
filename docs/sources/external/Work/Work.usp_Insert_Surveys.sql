CREATE PROCEDURE [Work].[usp_Insert_Surveys]
AS
BEGIN

	INSERT INTO [SurveyMonkey].[tblSurveys]
	(
		[SurveyId],
		[LinkId],
		[Category],
		[Date_Created],	
		[Date_Modified],
		[Folder_Id],
		[Nickname],
		[Question_Count],
		[Response_Count],
		[Title],
		[ProductGroupId],
		[BI_Created]
	)
	SELECT
		wrk.[SurveyId],
		wrk.[LinkId],
		wrk.[Category],
		wrk.[Date_Created],	
		wrk.[Date_Modified],
		wrk.[Folder_Id],
		wrk.[Nickname],
		wrk.[Question_Count],
		wrk.[Response_Count],
		wrk.[Title],
		ISNULL(pg.ProductGroupId, -1) AS [ProductGroupId],
		GETDATE()
	FROM [Work].[tblSurveys] wrk
		LEFT JOIN dbo.tblProductGroup pg
			ON LTRIM(RTRIM(wrk.[ProductGroup])) = pg.[ProductGroup]
		LEFT JOIN [SurveyMonkey].[tblSurveys] tgt
			ON wrk.[SurveyId] = tgt.[SurveyId]
	WHERE tgt.[SurveyId] IS NULL

END

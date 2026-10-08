CREATE PROCEDURE [Work].[usp_Update_Surveys]
AS
BEGIN

	UPDATE tgt SET
		tgt.[LinkId] = src.[LinkId],
		tgt.[Category] = src.[Category],
		tgt.[Date_Created] = src.[Date_Created],	
		tgt.[Date_Modified] = src.[Date_Modified],
		tgt.[Folder_Id] = src.[Folder_Id],
		tgt.[Nickname] = src.[Nickname],
		tgt.[Question_Count] = src.[Question_Count],
		tgt.[Response_Count] = src.[Response_Count],
		tgt.[Title] = src.[Title],
		tgt.[ProductGroupId] = src.[ProductGroupId],
		tgt.[BI_Modified] = getdate()
	FROM [SurveyMonkey].[tblSurveys] tgt
		INNER JOIN
			(
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
					ISNULL(pg.ProductGroupId, -1) AS [ProductGroupId]
				FROM [Work].[tblSurveys] wrk
					LEFT JOIN dbo.tblProductGroup pg
						ON LTRIM(RTRIM(wrk.[ProductGroup])) = pg.[ProductGroup]
			) src
			ON tgt.[SurveyId] = src.[SurveyId]


END

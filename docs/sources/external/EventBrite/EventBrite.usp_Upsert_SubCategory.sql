CREATE   PROCEDURE [EventBrite].[usp_Upsert_SubCategory]
AS

BEGIN

	MERGE [EventBrite].[tblSubCategory] AS tgt
		USING [Work].[tblSubCategory_EventBrite] AS src
			ON tgt.[Organization_Id] = src.[Organization_Id]
			AND tgt.[SubCategory_Id] = src.[SubCategory_Id]
	WHEN MATCHED THEN UPDATE SET
		tgt.[SubCategory_Name] = src.[SubCategory_Name],
		tgt.[Category_Id]= src.[Category_Id]
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[Organization_id],
		[SubCategory_Name],
		[SubCategory_Id],
		[Category_Id]
	)
	VALUES
	(
		src.[Organization_id],
		src.[SubCategory_Name],
		src.[SubCategory_Id],
		src.[Category_Id]
	);
END

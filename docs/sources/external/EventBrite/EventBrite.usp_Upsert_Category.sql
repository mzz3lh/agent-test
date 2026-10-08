CREATE   PROCEDURE [EventBrite].[usp_Upsert_Category]
AS

BEGIN

	MERGE [EventBrite].[tblCategory] AS tgt
		USING [Work].[tblCategory_EventBrite] AS src
			ON tgt.[Organization_Id] = src.[Organization_Id]
			AND tgt.[Category_Id] = src.[Category_Id]
	WHEN MATCHED THEN UPDATE SET
		tgt.[Category_Name] = src.[Category_Name]
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[Organization_id],
		[Category_Name],
		[Category_Id]
	)
	VALUES
	(
		src.[Organization_id],
		src.[Category_Name],
		src.[Category_Id]
	);
END

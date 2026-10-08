CREATE   PROCEDURE [Adobe].[usp_Upsert_search_engines]
AS
BEGIN
	/*
		Raj Maddala, 2025-02-15

	*/

	MERGE [Adobe].[search_engines] tgt
	USING [Staging_Adobe].[search_engines] src
		ON tgt.[search_engines_id] = CAST(src.[Prop_0] AS INT)
	WHEN MATCHED THEN UPDATE SET
		tgt.[description] = CAST(TRIM(src.[Prop_1]) AS NVARCHAR(50)),
		tgt.[source_file_name] = CAST(src.[source_file_name] AS NVARCHAR(50))
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[search_engines_id],
		[description],
		[source_file_name]
	)
	VALUES
	(
		CAST(src.[Prop_0] AS INT),
		CAST(TRIM(src.[Prop_1]) AS NVARCHAR(50)),
		CAST(src.[source_file_name] AS NVARCHAR(50))
	);

END

CREATE   PROCEDURE [Adobe].[usp_Upsert_browser]
AS
BEGIN
	/*
		Raj Maddala, 2025-02-15

	*/

	MERGE [Adobe].[browser] tgt
	USING [Staging_Adobe].[browser] src
		ON tgt.[browser_id] = CAST(src.[Prop_0] AS BIGINT)
	WHEN MATCHED THEN UPDATE SET
		tgt.[description] = CAST(TRIM(src.[Prop_1]) AS NVARCHAR(100)),
		tgt.[source_file_name] = CAST(src.[source_file_name] AS NVARCHAR(50))
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[browser_id],
		[description],
		[source_file_name]
	)
	VALUES
	(
		CAST(src.[Prop_0] AS BIGINT),
		CAST(TRIM(src.[Prop_1]) AS NVARCHAR(100)),
		CAST(src.[source_file_name] AS NVARCHAR(50))
	);

END

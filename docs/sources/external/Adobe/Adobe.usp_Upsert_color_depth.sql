*/

CREATE   PROCEDURE [Adobe].[usp_Upsert_color_depth]
AS
BEGIN
	/*
		Raj Maddala, 2025-02-15

	*/

	MERGE [Adobe].[color_depth] tgt
	USING [Staging_Adobe].[color_depth] src
		ON tgt.[color_depth_id] = CAST(src.[Prop_0] AS INT)
	WHEN MATCHED THEN UPDATE SET
		tgt.[description] = CAST(TRIM(src.[Prop_1]) AS NVARCHAR(50)),
		tgt.[source_file_name] = CAST(src.[source_file_name] AS NVARCHAR(50))
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[color_depth_id],
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

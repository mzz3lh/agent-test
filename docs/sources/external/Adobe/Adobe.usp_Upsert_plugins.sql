CREATE   PROCEDURE [Adobe].[usp_Upsert_plugins]
AS
BEGIN
	/*
		Raj Maddala, 2025-02-15

	*/

	MERGE [Adobe].[plugins] tgt
	USING [Staging_Adobe].[plugins] src
		ON tgt.[plugins_id] = CAST(src.[Prop_0] AS BIGINT)
	WHEN MATCHED THEN UPDATE SET
		tgt.[description] = CAST(TRIM(src.[Prop_1]) AS NVARCHAR(150)),
		tgt.[source_file_name] = CAST(src.[source_file_name] AS NVARCHAR(50))
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[plugins_id],
		[description],
		[source_file_name]
	)
	VALUES
	(
		CAST(src.[Prop_0] AS BIGINT),
		CAST(TRIM(src.[Prop_1]) AS NVARCHAR(150)),
		CAST(src.[source_file_name] AS NVARCHAR(50))
	);

END

CREATE   PROCEDURE [Adobe].[usp_Upsert_connection_type]
AS
BEGIN
	/*
		Raj Maddala, 2025-02-15

	*/

	MERGE [Adobe].[connection_type] tgt
	USING [Staging_Adobe].[connection_type] src
		ON tgt.[connection_type_id] = CAST(src.[Prop_0] AS INT)
	WHEN MATCHED THEN UPDATE SET
		tgt.[description] = CAST(TRIM(src.[Prop_1]) AS NVARCHAR(25)),
		tgt.[source_file_name] = CAST(src.[source_file_name] AS NVARCHAR(50))
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[connection_type_id],
		[description],
		[source_file_name]
	)
	VALUES
	(
		CAST(src.[Prop_0] AS INT),
		CAST(TRIM(src.[Prop_1]) AS NVARCHAR(25)),
		CAST(src.[source_file_name] AS NVARCHAR(50))
	);

END

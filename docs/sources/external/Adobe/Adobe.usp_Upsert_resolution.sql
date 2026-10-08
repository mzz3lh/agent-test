CREATE   PROCEDURE [Adobe].[usp_Upsert_resolution]
AS
BEGIN
	/*
		Raj Maddala, 2025-02-15

	*/

	MERGE [Adobe].[resolution] tgt
	USING [Staging_Adobe].[resolution] src
		ON tgt.[resolution_id] = CAST(src.[Prop_0] AS NVARCHAR(8))
	WHEN MATCHED THEN UPDATE SET
		tgt.[description] = CAST(TRIM(src.[Prop_1]) AS NVARCHAR(25)),
		tgt.[source_file_name] = CAST(src.[source_file_name] AS NVARCHAR(50))
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[resolution_id],
		[description],
		[source_file_name]
	)
	VALUES
	(
		CAST(src.[Prop_0] AS NVARCHAR(8)),
		CAST(TRIM(src.[Prop_1]) AS NVARCHAR(25)),
		CAST(src.[source_file_name] AS NVARCHAR(50))
	);

END

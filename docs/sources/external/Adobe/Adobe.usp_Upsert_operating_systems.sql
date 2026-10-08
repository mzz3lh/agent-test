CREATE   PROCEDURE [Adobe].[usp_Upsert_operating_systems]
AS
BEGIN
	/*
		Raj Maddala, 2025-02-15

	*/

	MERGE [Adobe].[operating_systems] tgt
	USING [Staging_Adobe].[operating_systems] src
		ON tgt.[operating_systems_id] = CAST(src.[Prop_0] AS BIGINT)
	WHEN MATCHED THEN UPDATE SET
		tgt.[description] = CAST(TRIM(src.[Prop_1]) AS NVARCHAR(100)),
		tgt.[source_file_name] = CAST(src.[source_file_name] AS NVARCHAR(50))
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[operating_systems_id],
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

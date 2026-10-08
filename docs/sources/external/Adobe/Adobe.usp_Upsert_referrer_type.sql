CREATE   PROCEDURE [Adobe].[usp_Upsert_referrer_type]
AS
BEGIN
	/*
		Raj Maddala, 2025-02-15

	*/

	MERGE [Adobe].[referrer_type] tgt
	USING [Staging_Adobe].[referrer_type] src
		ON tgt.[referrer_type_id] = CAST(src.[Prop_0] AS BIGINT)
	WHEN MATCHED THEN UPDATE SET
		tgt.[description] = CAST(TRIM(src.[Prop_1]) AS NVARCHAR(150)),
		tgt.[referrer_source] = CAST(src.[Prop_2] AS NVARCHAR(25)),
		tgt.[source_file_name] = CAST(src.[source_file_name] AS NVARCHAR(50))
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[referrer_type_id],
		[description],
		[referrer_source],
		[source_file_name]
	)
	VALUES
	(
		CAST(src.[Prop_0] AS BIGINT),
		CAST(TRIM(src.[Prop_1]) AS NVARCHAR(150)),
		CAST(TRIM(src.[Prop_1]) AS NVARCHAR(25)),
		CAST(src.[source_file_name] AS NVARCHAR(50))
	);

END

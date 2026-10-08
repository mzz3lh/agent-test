/*
CREATE OR ALTER PROCEDURE [Adobe].[usp_Upsert_carrier]
AS
BEGIN
	--	Raj Maddala, 2025-02-15	

	MERGE [Adobe].[carrier] tgt
	USING [Staging_Adobe].[carrier] src
		ON tgt.carrier_id] = src.[Prop_0]
	WHEN MATCHED THEN UPDATE SET
		tgt.[description] = src.[Prop_1],
		tgt.[source_file_name] = src.[source_file_name]
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[carrier_id],
		[description],
		[source_file_name]
	)
	VALUES
	(
		CAST(src.[Prop_0] AS BIGINT),
		CAST(TRIM(src.[Prop_1]) AS NVARCHAR(20)),
		CAST(src.[source_file_name] AS NVARCHAR(50))
	);

END

CREATE   PROCEDURE [EventBrite].[usp_Upsert_Organization]
AS

BEGIN

	MERGE [EventBrite].[tblOrganization] AS tgt
		USING [work].[tblorganization_eventbrite] AS src
			ON tgt.[Organization_Id] = src.[Organization_Id]
	WHEN MATCHED THEN UPDATE SET
		tgt.[Organization_Name] = src.[Organization_Name],
		tgt.[Token_Id] = src.[Token_Id]
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[Organization_id],
		[Organization_Name],
		[Token_Id]
	)
	VALUES
	(
		src.[Organization_id],
		src.[Organization_Name],
		src.[Token_Id]		
	);
END

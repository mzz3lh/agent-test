CREATE   PROCEDURE [SurveyMonkey].[usp_Upsert_SurveyCollectors]
AS
	/*
		Created by: Raj Maddala
		Created on: 2023-09-05
		Description: Procedure to do UPSERT on survey collectors
	*/
BEGIN

	MERGE [SurveyMonkey].[tblSurveyCollectors] tgt
		USING [Work].[tblSurveyCollectors] src
			ON tgt.[id] = src.[id]

	WHEN MATCHED THEN UPDATE SET
		tgt.[name] = src.[name],
		tgt.[survey_id] = src.[survey_id],
		tgt.[close_date] = src.[close_date],
		tgt.[date_created] = src.[date_created],
		tgt.[date_modified] = src.[date_modified],
		tgt.[sender_email] = src.[sender_email],
		tgt.[status] = src.[status],
		tgt.[response_limit] = src.[response_limit],
		tgt.[LastImportedOn] = getdate()

	WHEN NOT MATCHED THEN 
	INSERT
	(
		[id],
		[name],
		[survey_id],
		[close_date],
		[date_created],
		[date_modified],
		[sender_email],
		[status],
		[response_limit],
		[LastImportedOn]
	)
	VALUES
	(
		src.[id],
		src.[name],
		src.[survey_id],
		src.[close_date],
		src.[date_created],
		src.[date_modified],
		src.[sender_email],
		src.[status],
		src.[response_limit],
		GetDate()
	);

END

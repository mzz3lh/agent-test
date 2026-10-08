CREATE   PROCEDURE [SurveyMonkey].[usp_Upsert_Surveys]
AS
	/*
		Created by: Raj Maddala
		Created on: 2023-09-05
		Description: Procedure to do UPSERT on surveys
	*/
BEGIN

	MERGE [SurveyMonkey].[tblSurveys] tgt
		USING [Work].[tblSurveys] src
			ON tgt.[id] = src.[id]

	WHEN MATCHED THEN UPDATE SET
		tgt.[Category] = src.[Category],
		tgt.[Date_Created] = src.[Date_Created],
		tgt.[Date_Modified] = src.[Date_Modified],
		tgt.[Folder_Id] = src.[Folder_Id],
		tgt.[Nickname] = src.[Nickname],
		tgt.[is_owner] = src.[is_owner],
		tgt.[Question_Count] = src.[Question_Count],
		tgt.[Response_Count] = src.[Response_Count],
		tgt.[Title] = src.[Title],
		tgt.[Page_Count] = src.[Page_Count],
		tgt.[LastImportedOn] = getdate(),
		tgt.[ReadyToLoadResponses] = IIF(src.[Response_Count] > 0, 1,0),
		tgt.[IsOwnerShared] = IIF(tgt.[isownershared]=1, 1, src.[is_owner])
	WHEN NOT MATCHED THEN 
	INSERT
	(
		[id],
		[Category],
		[Date_Created],
		[Date_Modified],
		[Folder_Id],
		[Nickname],
		[is_owner],
		[Question_Count],
		[Response_Count],
		[Title],
		[Page_Count],
		[LastImportedOn],
		[ReadyToLoadResponses],
		[ReadyToUpdateSummary],
		[IsOwnerShared]
	)
	VALUES
	(
		src.[id],
		src.[Category],
		src.[Date_Created],
		src.[Date_Modified],
		src.[Folder_Id],
		src.[Nickname],
		src.[is_owner],
		src.[Question_Count],
		src.[Response_Count],
		src.[Title],
		src.[Page_Count],
		GetDate(),
		IIF(src.[Response_Count] > 0, 1,0),
		0,
		IIF(src.[is_owner] = 1, 1, 0)
	);

END

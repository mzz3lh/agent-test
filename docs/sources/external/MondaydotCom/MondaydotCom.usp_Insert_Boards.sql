CREATE   PROCEDURE [MondaydotCom].[usp_Insert_Boards]
AS
BEGIN
	
	MERGE [MondaydotCom].[Boards] AS tgt
	USING [Work].[Boards_MondaydotCom] AS src
		ON tgt.[id] = src.[id]
	WHEN MATCHED THEN UPDATE SET
		tgt.[name] = src.[name],
		tgt.[board_folder_id] = src.[board_folder_id],
		tgt.[board_kind] = src.[board_kind],
		tgt.[columns_namespace] = src.[columns_namespace],
		tgt.[communication] = src.[communication],
		tgt.[description] = src.[description],
		tgt.[item_terminology] = src.[item_terminology],
		tgt.[items_count] = src.[items_count],
		tgt.[items_limit] = src.[items_limit],
		tgt.[permissions] = src.[permissions],
		tgt.[state] = src.[state],
		tgt.[type] = src.[type],
		tgt.[updated_at] = src.[updated_at],
		tgt.[url] = src.[url],
		tgt.[workspace_id] = src.[workspace_id],
		tgt.[__LinkId] = src.[__LinkId]
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[id],
		[name],
		[board_folder_id],
		[board_kind],
		[columns_namespace],
		[communication],
		[description],
		[item_terminology],
		[items_count],
		[items_limit],
		[permissions],
		[state],
		[type],
		[updated_at],
		[url],
		[workspace_id],
		[__LinkId]
	)
	VALUES
	(
		src.[id],
		src.[name],
		src.[board_folder_id],
		src.[board_kind],
		src.[columns_namespace],
		src.[communication],
		src.[description],
		src.[item_terminology],
		src.[items_count],
		src.[items_limit],
		src.[permissions],
		src.[state],
		src.[type],
		src.[updated_at],
		src.[url],
		src.[workspace_id],
		src.[__LinkId]
	);
END

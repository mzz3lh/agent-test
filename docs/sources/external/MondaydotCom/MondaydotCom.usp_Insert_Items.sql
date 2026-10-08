CREATE    PROCEDURE [MondaydotCom].[usp_Insert_Items]
AS
BEGIN
	
	MERGE [MondaydotCom].[items] AS tgt
	USING [Work].[Items_MondaydotCom] AS src
		ON tgt.[id] = src.[id]
		AND tgt.[board_id] = src.[board_id]
	WHEN MATCHED THEN UPDATE SET
		tgt.[created_at] = src.[created_at],
		tgt.[creator_id] = src.[creator_id],
		tgt.[email] = src.[email],
		tgt.[name] = src.[name],
		tgt.[relative_link] = src.[relative_link],
		tgt.[state] = src.[state],
		tgt.[updated_at] = src.[updated_at],
		tgt.[url] = src.[url],
		tgt.[ColumnValues_LinkId] = src.[ColumnValues_LinkId],
		tgt.[group_id] = src.[group_id]
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[id],
		[board_id],
		[created_at],
		[creator_id],
		[email],
		[name],
		[relative_link],
		[state],
		[updated_at],
		[url],
		[ColumnValues_LinkId],
		[group_id]
	)
	VALUES
	(
		src.[id],
		src.[board_id],
		src.[created_at],
		src.[creator_id],
		src.[email],
		src.[name],
		src.[relative_link],
		src.[state],
		src.[updated_at],
		src.[url],
		src.[ColumnValues_LinkId],
		src.[group_id]
	);
END

CREATE    PROCEDURE [MondaydotCom].[usp_Insert_Groups]
AS
BEGIN
	
	MERGE [MondaydotCom].[Groups] AS tgt
	USING [Work].[Groups_MondaydotCom] AS src
		ON tgt.[id] = src.[id]
		AND tgt.[boardid] = src.[boardid]
	WHEN MATCHED THEN UPDATE SET
		tgt.[_boards._LinkId] = src.[_boards._LinkId],
		tgt.[archived] = src.[archived],
		tgt.[color] = src.[color],
		tgt.[deleted] = src.[deleted],
		tgt.[position] = src.[position],
		tgt.[title] = src.[title]
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[id],
		[_boards._LinkId],
		[boardid],
		[archived],
		[color],
		[deleted],
		[position],
		[title]
	)
	VALUES
	(
		src.[id],
		src.[_boards._LinkId],
		src.[boardid],
		src.[archived],
		src.[color],
		src.[deleted],
		src.[position],
		src.[title]
	);
END

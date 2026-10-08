CREATE    PROCEDURE [MondaydotCom].[usp_Insert_ItemValues]
AS
BEGIN

	--TRUNCATE TABLE [MondaydotCom].[ItemValues]

	DELETE tgt FROM [MondaydotCom].[ItemValues] tgt
		INNER JOIN [Work].[ItemValues_MondaydotCom] src
			ON tgt.[board_id] = src.[board_id]
			AND tgt.[item_id] = src.[item_id]


	INSERT INTO [MondaydotCom].[ItemValues]
	(
		[item_id]
		,[board_id]
		,[column_title]
		,[column_text]
		,[column_value]
		,[updated_at]
		,[index]
		,[is_done]
	)
	SELECT 
		src.[item_id]
		,src.[board_id]
		,src.[column_title]
		,src.[column_text]
		,src.[column_value]
		,src.[updated_at]
		,src.[index]
		,src.[is_done]
	FROM [work].[ItemValues_MondaydotCom] src


END

CREATE   PROCEDURE [Drupal].[usp_Update_commerce_line_item]
AS
BEGIN

	UPDATE tgt SET
		tgt.[order_id] = src.[order_id],
		tgt.[type] = src.[type],
		tgt.[line_item_label] = src.[line_item_label],
		tgt.[quantity] = src.[quantity],
		tgt.[created] = src.[created],
		tgt.[changed] = src.[changed]
	FROM [Drupal].[commerce_line_item] tgt
		INNER JOIN [work].[commerce_line_item] src
			ON src.[line_item_id] = tgt.[line_item_id]

END

CREATE   PROCEDURE [Drupal].[usp_Insert_commerce_line_item]
AS
BEGIN

	INSERT INTO [Drupal].[commerce_line_item]
	(
		[line_item_id],
		[order_id],
		[type],
		[line_item_label],
		[quantity],
		[created],
		[changed]
	)
	SELECT
		src.[line_item_id],
		src.[order_id],
		src.[type],
		src.[line_item_label],
		src.[quantity],
		src.[created],
		src.[changed]
	FROM [work].[commerce_line_item] src
		LEFT JOIN [Drupal].[commerce_line_item] tgt
			ON src.[line_item_id] = tgt.[line_item_id]
	WHERE tgt.[line_item_id] IS NULL

END

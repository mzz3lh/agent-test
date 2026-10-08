CREATE   PROCEDURE [Drupal].[usp_Insert_commerce_order]
AS
BEGIN

	INSERT INTO [Drupal].[commerce_order]
	(
		[order_id],
		[order_number],
		[revision_id],
		[type],
		[uid],
		[mail],
		[status],
		[created],
		[changed],
		[hostname],
		[placed]
	)
	SELECT
		src.[order_id],
		src.[order_number],
		src.[revision_id],
		src.[type],
		src.[uid],
		src.[mail],
		src.[status],
		src.[created],
		src.[changed],
		src.[hostname],
		src.[placed]
	FROM [work].[commerce_order] src
		LEFT JOIN [Drupal].[commerce_order] tgt
			ON src.[order_id] = tgt.[order_id]
	WHERE tgt.[order_id] IS NULL

END

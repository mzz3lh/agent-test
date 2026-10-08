CREATE   PROCEDURE [Drupal].[usp_Update_commerce_order]
AS
BEGIN

	UPDATE tgt SET
		tgt.[order_number] = src.[order_number],
		tgt.[revision_id] = src.[revision_id],
		tgt.[type] = src.[type],
		tgt.[uid] = src.[uid],
		tgt.[mail] = src.[mail],
		tgt.[status] = src.[status],
		tgt.[created] = src.[created],
		tgt.[changed] = src.[changed],
		tgt.[hostname] = src.[hostname],
		tgt.[placed] = src.[placed]
	FROM [Drupal].[commerce_order] tgt
		INNER JOIN [work].[commerce_order] src
			ON src.[order_id] = tgt.[order_id]

END

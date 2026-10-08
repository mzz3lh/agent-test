CREATE   PROCEDURE [Drupal].[usp_Update_node]
As

BEGIN

	UPDATE tgt SET 
		tgt.[vid] = src.[vid],
		tgt.[type] = src.[type],
		tgt.[language] = src.[language],
		tgt.[title] = src.[title],
		tgt.[uid] = src.[uid],
		tgt.[status] = src.[status],
		tgt.[created] = src.[created],
		tgt.[changed] = src.[changed],
		tgt.[comment] = src.[comment],
		tgt.[promote] = src.[promote],
		tgt.[sticky] = src.[sticky],
		tgt.[tnid] = src.[tnid],
		tgt.[translate] = src.[translate],
		tgt.[rh_action] = src.[rh_action],
		tgt.[rh_redirect] = src.[rh_redirect],
		tgt.[rh_redirect_response] = src.[rh_redirect_response]
	FROM [Drupal].[node] tgt
		INNER JOIN [Work].[node] src
			ON src.[nid] = tgt.[nid]

END

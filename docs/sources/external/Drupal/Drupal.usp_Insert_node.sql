CREATE   PROCEDURE [Drupal].[usp_Insert_node]
As
BEGIN

	INSERT INTO [Drupal].[node]
	(
		[nid],
		[vid],
		[type],
		[language],
		[title],
		[uid],
		[status],
		[created],
		[changed],
		[comment],
		[promote],
		[sticky],
		[tnid],
		[translate],
		[rh_action],
		[rh_redirect],
		[rh_redirect_response]
	)
	SELECT
		src.[nid],
		src.[vid],
		src.[type],
		src.[language],
		src.[title],
		src.[uid],
		src.[status],
		src.[created],
		src.[changed],
		src.[comment],
		src.[promote],
		src.[sticky],
		src.[tnid],
		src.[translate],
		src.[rh_action],
		src.[rh_redirect],
		src.[rh_redirect_response]
	FROM [Work].[node] src
		LEFT JOIN [Drupal].[node] tgt
			ON src.[nid] = tgt.[nid]
	WHERE tgt.[nid] IS NULL


END

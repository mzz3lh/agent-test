CREATE   PROCEDURE [Sharedstore].[usp_Insert_users]
AS
BEGIN

	INSERT INTO [Sharedstore].[users]
	(
		[uid],
		[name],
		[mail],
		[created],
		[access],
		[login],
		[status],
		[timezone],
		[language],
		[init],
		[rh_action],
		[rh_redirect],
		[rh_redirect_response],
		[lr_raas_uid],
		[changed]
	)
	SELECT
		src.[uid],
		src.[name],
		src.[mail],
		src.[created],
		src.[access],
		src.[login],
		src.[status],
		src.[timezone],
		src.[language],
		src.[init],
		src.[rh_action],
		src.[rh_redirect],
		src.[rh_redirect_response],
		src.[lr_raas_uid],
		src.[changed]
	FROM [work].[users] src
		LEFT JOIN [Sharedstore].[users] tgt
			ON src.[uid] = tgt.[uid]
	WHERE tgt.[uid]  IS NULL
END

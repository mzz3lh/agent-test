CREATE   PROCEDURE [Sharedstore].[usp_Update_users]
AS
BEGIN

	UPDATE tgt SET 
		tgt.[name] = src.[name],
		tgt.[mail] = src.[mail],
		tgt.[created] = src.[created],
		tgt.[access] = src.[access],
		tgt.[login] = src.[login],
		tgt.[status] = src.[status],
		tgt.[timezone] = src.[timezone],
		tgt.[language] = src.[language],
		tgt.[init] = src.[init],
		tgt.[rh_action] = src.[rh_action],
		tgt.[rh_redirect] = src.[rh_redirect],
		tgt.[rh_redirect_response] = src.[rh_redirect_response],
		tgt.[lr_raas_uid] = src.[lr_raas_uid],
		tgt.[changed] = src.[changed]
	FROM [Sharedstore].[users] tgt
		INNER JOIN [work].[users] src
			ON src.[uid] = tgt.[uid]

END

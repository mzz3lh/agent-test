CREATE   PROCEDURE [synapse_fo].[usp_Update_TAXTABLE]
AS
BEGIN
	
	UPDATE tgt SET
		tgt.[SinkCreatedOn]  =src.[SinkCreatedOn],
		tgt.[SinkModifiedOn]  =src.[SinkModifiedOn],
		tgt.[taxcode]  =src.[taxcode],
		tgt.[printcode]  =src.[printcode],
		tgt.[taxcurrencycode]  =src.[taxcurrencycode],
		tgt.[taxaccountgroup]  =src.[taxaccountgroup],
		tgt.[taxname]  =src.[taxname],
		tgt.[taxperiod]  =src.[taxperiod]
	FROM [synapse_fo].[TAXTABLE] tgt
		INNER JOIN [staging_fo].[TAXTABLE] src
			ON src.[recid] = tgt.[recid]
			AND src.[dataareaid] = tgt.[dataareaid]

END

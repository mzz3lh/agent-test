CREATE   PROCEDURE [synapse_fo].[usp_Insert_TAXTABLE]
AS
BEGIN

	INSERT INTO [synapse_fo].[TAXTABLE]
	(
		[recid],
		[SinkCreatedOn],
		[SinkModifiedOn],
		[taxcode],
		[printcode],
		[taxcurrencycode],
		[taxaccountgroup],
		[taxname],
		[taxperiod],
		[dataareaid]
	)
	SELECT
		src.[recid],
		src.[SinkCreatedOn],
		src.[SinkModifiedOn],
		src.[taxcode],
		src.[printcode],
		src.[taxcurrencycode],
		src.[taxaccountgroup],
		src.[taxname],
		src.[taxperiod],
		src.[dataareaid]
	FROM [staging_fo].[TAXTABLE] src
		LEFT JOIN [synapse_fo].[TAXTABLE] tgt
			ON src.[recid] = tgt.[recid]
			AND src.[dataareaid] = tgt.[dataareaid]
	WHERE tgt.[recid] IS NULL

END

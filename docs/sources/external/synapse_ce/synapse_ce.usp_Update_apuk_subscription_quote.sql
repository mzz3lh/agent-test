CREATE   PROCEDURE [synapse_ce].[usp_Update_apuk_subscription_quote]
AS
BEGIN

	;WITH cte AS
	(
		SELECT 
			stg.[apuk_subscription_quoteid],
			stg.[apuk_subscriptionid],
			stg.[Id],
			stg.[quoteid],
			stg.[SinkCreatedOn],
			stg.[SinkModifiedOn],
			stg.[versionnumber],
			ROW_NUMBER() OVER(PARTITION BY ID ORDER BY ID DESC) AS RowNo
		FROM [staging_ce].[apuk_subscription_quote] stg
	)


	UPDATE tgt SET 
		tgt.[apuk_subscription_quoteid] = stg.[apuk_subscription_quoteid],
		tgt.[apuk_subscriptionid] = stg.[apuk_subscriptionid],
		tgt.[quoteid] = stg.[quoteid],
		tgt.[SinkCreatedOn] = stg.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = stg.[SinkModifiedOn],
		tgt.[versionnumber] = stg.[versionnumber]
	 FROM [synapse_ce].[apuk_subscription_quote] tgt
		INNER JOIN cte stg--[staging_ce].[apuk_subscription_quote] stg
			ON tgt.[id] = stg.[id]
	WHERE stg.RowNo = 1

END

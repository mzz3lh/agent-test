CREATE   PROCEDURE [synapse_ce].[usp_Insert_apuk_subscription_quote]
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


	INSERT INTO [synapse_ce].[apuk_subscription_quote]
	(
		[apuk_subscription_quoteid],
		[apuk_subscriptionid],
		[Id],
		[quoteid],
		[SinkCreatedOn],
		[SinkModifiedOn],
		[versionnumber]
	)
	SELECT 
		stg.[apuk_subscription_quoteid],
		stg.[apuk_subscriptionid],
		stg.[Id],
		stg.[quoteid],
		stg.[SinkCreatedOn],
		stg.[SinkModifiedOn],
		stg.[versionnumber]	
	FROM cte stg--[staging_ce].[apuk_subscription_quote] stg
		LEFT JOIN [synapse_ce].[apuk_subscription_quote] tgt
			ON tgt.[id] = stg.[id]
	WHERE stg.RowNo = 1
		AND tgt.[id] IS NULL
END

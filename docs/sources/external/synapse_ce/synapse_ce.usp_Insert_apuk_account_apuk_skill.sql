CREATE   PROCEDURE [synapse_ce].[usp_Insert_apuk_account_apuk_skill]
AS
BEGIN

	;WITH cte AS
	(
		SELECT 
			stg.[Id],
			stg.[SinkCreatedOn],
			stg.[SinkModifiedOn],
			stg.[accountid],
			stg.[versionnumber],
			stg.[apuk_account_apuk_skillid],
			stg.[apuk_skillid],
			ROW_NUMBER() OVER(PARTITION BY ID ORDER BY ID DESC) AS RowNo
		FROM [staging_ce].[apuk_account_apuk_skill] stg
	)


	INSERT INTO [synapse_ce].[apuk_account_apuk_skill]
	(
		[Id],
		[SinkCreatedOn],
		[SinkModifiedOn],
		[accountid],
		[versionnumber],
		[apuk_account_apuk_skillid],
		[apuk_skillid]
	)
	SELECT 
			stg.[Id],
			stg.[SinkCreatedOn],
			stg.[SinkModifiedOn],
			stg.[accountid],
			stg.[versionnumber],
			stg.[apuk_account_apuk_skillid],
			stg.[apuk_skillid]
	FROM cte stg --[staging_ce].[apuk_assessor_areaofpractice] stg
		LEFT JOIN [synapse_ce].[apuk_account_apuk_skill] tgt
			ON tgt.[id] = stg.[id]
	WHERE stg.[RowNo] = 1
		AND tgt.[id] IS NULL
END

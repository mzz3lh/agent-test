CREATE   PROCEDURE [synapse_ce].[usp_Update_apuk_account_apuk_skill]
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


	UPDATE tgt SET 
		tgt.[SinkCreatedOn] = stg.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = stg.[SinkModifiedOn],
		tgt.[accountid] = stg.[accountid],
		tgt.[versionnumber] = stg.[versionnumber],
		tgt.[apuk_account_apuk_skillid] = stg.[apuk_account_apuk_skillid],
		tgt.[apuk_skillid] = stg.[apuk_skillid]
	 FROM [synapse_ce].[apuk_account_apuk_skill] tgt
		INNER JOIN cte stg--[staging_ce].[apuk_assessor_areaofpractice] stg
			ON tgt.[id] = stg.[id]
	WHERE stg.[rowno] = 1

END

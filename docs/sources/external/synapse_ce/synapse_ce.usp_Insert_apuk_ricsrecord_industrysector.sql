CREATE   PROCEDURE [synapse_ce].[usp_Insert_apuk_ricsrecord_industrysector]
AS
BEGIN

	;WITH cte AS
	(
		SELECT 
			stg.[apuk_industrysectorid],
			stg.[apuk_ricsrecord_industrysectorid],
			stg.[apuk_ricsrecordid],
			stg.[Id],
			stg.[SinkCreatedOn],
			stg.[SinkModifiedOn],
			stg.[versionnumber],	
			ROW_NUMBER() OVER(PARTITION BY ID ORDER BY ID DESC) AS RowNo
		FROM [staging_ce].[apuk_ricsrecord_industrysector] stg
	)


	INSERT INTO [synapse_ce].[apuk_ricsrecord_industrysector]
	(
		[apuk_industrysectorid],
		[apuk_ricsrecord_industrysectorid],
		[apuk_ricsrecordid],
		[Id],
		[SinkCreatedOn],
		[SinkModifiedOn],
		[versionnumber]
	)
	SELECT 
		stg.[apuk_industrysectorid],
		stg.[apuk_ricsrecord_industrysectorid],
		stg.[apuk_ricsrecordid],
		stg.[Id],
		stg.[SinkCreatedOn],
		stg.[SinkModifiedOn],
		stg.[versionnumber]	
	FROM cte stg --[staging_ce].[apuk_ricsrecord_industrysector] stg
		LEFT JOIN [synapse_ce].[apuk_ricsrecord_industrysector] tgt
			ON tgt.[id] = stg.[id]
	WHERE stg.[RowNo] = 1
		AND tgt.[id] IS NULL
END

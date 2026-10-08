CREATE   PROCEDURE [synapse_ce].[usp_Insert_apuk_industrysector_apuk_assessment]
AS
BEGIN

	;WITH cte AS
	(
		SELECT 
			stg.[apuk_assessmentid],
			stg.[apuk_industrysector_apuk_assessmentid],
			stg.[apuk_industrysectorid],
			stg.[Id],
			stg.[SinkCreatedOn],
			stg.[SinkModifiedOn],
			stg.[versionnumber],
			ROW_NUMBER() OVER(PARTITION BY ID ORDER BY ID DESC) AS RowNo
		FROM [staging_ce].[apuk_industrysector_apuk_assessment] stg
	)



	INSERT INTO [synapse_ce].[apuk_industrysector_apuk_assessment]
	(
		[apuk_assessmentid],
		[apuk_industrysector_apuk_assessmentid],
		[apuk_industrysectorid],
		[Id],
		[SinkCreatedOn],
		[SinkModifiedOn],
		[versionnumber]
	)
	SELECT 
		stg.[apuk_assessmentid],
		stg.[apuk_industrysector_apuk_assessmentid],
		stg.[apuk_industrysectorid],
		stg.[Id],
		stg.[SinkCreatedOn],
		stg.[SinkModifiedOn],
		stg.[versionnumber]	
	FROM cte stg
	--[staging_ce].[apuk_industrysector_apuk_assessment] stg
		LEFT JOIN [synapse_ce].[apuk_industrysector_apuk_assessment] tgt
			ON tgt.[id] = stg.[id]
	WHERE stg.[RowNo] = 1
		AND tgt.[id] IS NULL
END

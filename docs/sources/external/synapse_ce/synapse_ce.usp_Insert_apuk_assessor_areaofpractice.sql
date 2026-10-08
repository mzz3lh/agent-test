/****** Object:  StoredProcedure [synapse_ce].[usp_Insert_apuk_assessor_areaofpractice]    Script Date: 24/10/2022 14:57:04 ******/
CREATE   PROCEDURE [synapse_ce].[usp_Insert_apuk_assessor_areaofpractice]
AS
BEGIN

	;WITH cte AS
	(
		SELECT 
			stg.[apuk_areaofpracticeid],
			stg.[apuk_assessor_areaofpracticeid],
			stg.[apuk_assessorid],
			stg.[Id],
			stg.[SinkCreatedOn],
			stg.[SinkModifiedOn],
			stg.[versionnumber],
			ROW_NUMBER() OVER(PARTITION BY ID ORDER BY ID DESC) AS RowNo
		FROM [staging_ce].[apuk_assessor_areaofpractice] stg
	)


	INSERT INTO [synapse_ce].[apuk_assessor_areaofpractice]
	(
		[apuk_areaofpracticeid],
		[apuk_assessor_areaofpracticeid],
		[apuk_assessorid],
		[Id],
		[SinkCreatedOn],
		[SinkModifiedOn],
		[versionnumber]
	)
	SELECT 
		stg.[apuk_areaofpracticeid],
		stg.[apuk_assessor_areaofpracticeid],
		stg.[apuk_assessorid],
		stg.[Id],
		stg.[SinkCreatedOn],
		stg.[SinkModifiedOn],
		stg.[versionnumber]	
	FROM cte stg --[staging_ce].[apuk_assessor_areaofpractice] stg
		LEFT JOIN [synapse_ce].[apuk_assessor_areaofpractice] tgt
			ON tgt.[id] = stg.[id]
	WHERE stg.[RowNo] = 1
		AND tgt.[id] IS NULL
END

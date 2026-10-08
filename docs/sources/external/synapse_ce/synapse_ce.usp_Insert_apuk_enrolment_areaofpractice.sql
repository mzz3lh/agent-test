CREATE   PROCEDURE [synapse_ce].[usp_Insert_apuk_enrolment_areaofpractice]
AS
BEGIN


	;WITH cte AS
	(
		SELECT 
			stg.[apuk_areaofpracticeid],
			stg.[apuk_enrolment_areaofpracticeid],
			stg.[apuk_enrolmentid],
			stg.[Id],
			stg.[SinkCreatedOn],
			stg.[SinkModifiedOn],
			stg.[versionnumber],	
			ROW_NUMBER() OVER(PARTITION BY ID ORDER BY ID DESC) AS RowNo
		FROM [staging_ce].[apuk_enrolment_areaofpractice] stg
	)


	INSERT INTO [synapse_ce].[apuk_enrolment_areaofpractice]
	(
		[apuk_areaofpracticeid],
		[apuk_enrolment_areaofpracticeid],
		[apuk_enrolmentid],
		[Id],
		[SinkCreatedOn],
		[SinkModifiedOn],
		[versionnumber]
	)
	SELECT 
		stg.[apuk_areaofpracticeid],
		stg.[apuk_enrolment_areaofpracticeid],
		stg.[apuk_enrolmentid],
		stg.[Id],
		stg.[SinkCreatedOn],
		stg.[SinkModifiedOn],
		stg.[versionnumber]	
	FROM cte stg --[staging_ce].[apuk_enrolment_areaofpractice] stg
		LEFT JOIN [synapse_ce].[apuk_enrolment_areaofpractice] tgt
			ON tgt.[id] = stg.[id]
	WHERE stg.[RowNo] = 1 
		AND tgt.[id] IS NULL

END

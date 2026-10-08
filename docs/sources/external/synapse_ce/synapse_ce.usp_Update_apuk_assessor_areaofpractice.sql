CREATE   PROCEDURE [synapse_ce].[usp_Update_apuk_assessor_areaofpractice]
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


	UPDATE tgt SET 
		tgt.[apuk_areaofpracticeid] = stg.[apuk_areaofpracticeid],
		tgt.[apuk_assessor_areaofpracticeid] = stg.[apuk_assessor_areaofpracticeid],
		tgt.[apuk_assessorid] = stg.[apuk_assessorid],
		tgt.[SinkCreatedOn] = stg.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = stg.[SinkModifiedOn],
		tgt.[versionnumber] = stg.[versionnumber]
	 FROM [synapse_ce].[apuk_assessor_areaofpractice] tgt
		INNER JOIN cte stg--[staging_ce].[apuk_assessor_areaofpractice] stg
			ON tgt.[id] = stg.[id]
	WHERE stg.[rowno] = 1

END

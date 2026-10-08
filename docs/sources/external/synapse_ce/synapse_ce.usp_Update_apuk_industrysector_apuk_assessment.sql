CREATE   PROCEDURE [synapse_ce].[usp_Update_apuk_industrysector_apuk_assessment]
AS
BEGIN
	UPDATE tgt SET 
		tgt.[apuk_assessmentid] = stg.[apuk_assessmentid],
		tgt.[apuk_industrysector_apuk_assessmentid] = stg.[apuk_industrysector_apuk_assessmentid],
		tgt.[apuk_industrysectorid] = stg.[apuk_industrysectorid],
		tgt.[SinkCreatedOn] = stg.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = stg.[SinkModifiedOn],
		tgt.[versionnumber] = stg.[versionnumber]
	 FROM [synapse_ce].[apuk_industrysector_apuk_assessment] tgt
		INNER JOIN [staging_ce].[apuk_industrysector_apuk_assessment] stg
			ON tgt.[id] = stg.[id]
END

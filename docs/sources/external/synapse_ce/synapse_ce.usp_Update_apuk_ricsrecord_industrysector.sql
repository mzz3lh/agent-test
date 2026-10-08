CREATE   PROCEDURE [synapse_ce].[usp_Update_apuk_ricsrecord_industrysector]
AS
BEGIN
	UPDATE tgt SET 
		tgt.[apuk_industrysectorid] = stg.[apuk_industrysectorid],
		tgt.[apuk_ricsrecord_industrysectorid] = stg.[apuk_ricsrecord_industrysectorid],
		tgt.[apuk_ricsrecordid] = stg.[apuk_ricsrecordid],
		tgt.[SinkCreatedOn] = stg.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = stg.[SinkModifiedOn],
		tgt.[versionnumber] = stg.[versionnumber]
	 FROM [synapse_ce].[apuk_ricsrecord_industrysector] tgt
		INNER JOIN [staging_ce].[apuk_ricsrecord_industrysector] stg
			ON tgt.[id] = stg.[id]
END

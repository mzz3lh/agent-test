CREATE   PROCEDURE [synapse_ce].[usp_Update_apuk_enrolment_areaofpractice]
AS
BEGIN
	UPDATE tgt SET 
		tgt.[apuk_areaofpracticeid] = stg.[apuk_areaofpracticeid],
		tgt.[apuk_enrolment_areaofpracticeid] = stg.[apuk_enrolment_areaofpracticeid],
		tgt.[apuk_enrolmentid] = stg.[apuk_enrolmentid],
		tgt.[SinkCreatedOn] = stg.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = stg.[SinkModifiedOn],
		tgt.[versionnumber] = stg.[versionnumber]
	 FROM [synapse_ce].[apuk_enrolment_areaofpractice] tgt
		INNER JOIN [staging_ce].[apuk_enrolment_areaofpractice] stg
			ON tgt.[id] = stg.[id]
END

CREATE   PROCEDURE [synapse_ce].[usp_Update_apuk_charge_caseinvestigation]
AS
BEGIN

	;WITH cte AS
	(
		SELECT 
			stg.[Id],
			stg.[SinkCreatedOn],
			stg.[SinkModifiedOn],
			stg.[versionnumber],
			stg.[apuk_charge_caseinvestigationid],
			stg.[apuk_caseinvestigationid],
			stg.[apuk_chargeid],
			ROW_NUMBER() OVER(PARTITION BY ID ORDER BY ID DESC) AS RowNo
		FROM [staging_ce].[apuk_charge_caseinvestigation] stg
	)


	UPDATE tgt SET 
		tgt.[SinkCreatedOn] = stg.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = stg.[SinkModifiedOn],
		tgt.[versionnumber] = stg.[versionnumber],
		tgt.[apuk_charge_caseinvestigationid] = stg.[apuk_charge_caseinvestigationid],
		tgt.[apuk_caseinvestigationid] = stg.[apuk_caseinvestigationid],
		tgt.[apuk_chargeid] = stg.[apuk_chargeid]
	FROM [synapse_ce].[apuk_charge_caseinvestigation] tgt
		INNER JOIN cte stg--[staging_ce].[apuk_assessor_areaofpractice] stg
			ON tgt.[id] = stg.[id]
	WHERE stg.[rowno] = 1

END

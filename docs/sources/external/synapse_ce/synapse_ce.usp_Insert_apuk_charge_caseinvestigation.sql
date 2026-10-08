CREATE   PROCEDURE [synapse_ce].[usp_Insert_apuk_charge_caseinvestigation]
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


	INSERT INTO [synapse_ce].[apuk_charge_caseinvestigation]
	(
		[Id],
		[SinkCreatedOn],
		[SinkModifiedOn],
		[versionnumber],
		[apuk_charge_caseinvestigationid],
		[apuk_caseinvestigationid],
		[apuk_chargeid]
	)
	SELECT 
			stg.[Id],
			stg.[SinkCreatedOn],
			stg.[SinkModifiedOn],
			stg.[versionnumber],
			stg.[apuk_charge_caseinvestigationid],
			stg.[apuk_caseinvestigationid],
			stg.[apuk_chargeid]
	FROM cte stg --[staging_ce].[apuk_assessor_areaofpractice] stg
		LEFT JOIN [synapse_ce].[apuk_charge_caseinvestigation] tgt
			ON tgt.[id] = stg.[id]
	WHERE stg.[RowNo] = 1
		AND tgt.[id] IS NULL
END

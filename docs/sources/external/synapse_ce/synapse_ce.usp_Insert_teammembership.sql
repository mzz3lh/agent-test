CREATE   PROCEDURE [synapse_ce].[usp_Insert_teammembership]
AS
BEGIN

	;WITH cteSource AS
	(
		SELECT
			Id
			,SinkCreatedOn
			,SinkModifiedOn
			,versionnumber
			,teammembershipid
			,teamid
			,systemuserid
			,ROW_NUMBER() OVER(PARTITION BY ID ORDER BY ID) AS RowNo
		FROM Staging_ce.teammembership

	)

	INSERT INTO [synapse_ce].[teammembership]
	(
		[Id],
		[SinkCreatedOn],
		[SinkModifiedOn],
		[systemuserid],
		[teamid],
		[teammembershipid],
		[versionnumber]
	)
	SELECT 
		stg.[Id],
		stg.[SinkCreatedOn],
		stg.[SinkModifiedOn],
		stg.[systemuserid],
		stg.[teamid],
		stg.[teammembershipid],
		stg.[versionnumber]	
	FROM cteSource stg
		LEFT JOIN [synapse_ce].[teammembership] tgt
			ON tgt.[id] = stg.[id]
	WHERE stg.[RowNo] = 1
		AND tgt.[id] IS NULL

END

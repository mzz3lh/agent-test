CREATE   PROCEDURE [synapse_ce].[usp_Update_teammembership]
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

	UPDATE tgt SET 
		tgt.[SinkCreatedOn] = stg.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = stg.[SinkModifiedOn],
		tgt.[systemuserid] = stg.[systemuserid],
		tgt.[teamid] = stg.[teamid],
		tgt.[teammembershipid] = stg.[teammembershipid],
		tgt.[versionnumber] = stg.[versionnumber]
	 FROM [synapse_ce].[teammembership] tgt
		INNER JOIN cteSource stg
			ON tgt.[id] = stg.[id]
	WHERE stg.[RowNo] = 1

END

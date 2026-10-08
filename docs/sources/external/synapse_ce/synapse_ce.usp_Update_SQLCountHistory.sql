CREATE   PROCEDURE [synapse_ce].[usp_Update_SQLCountHistory]
AS
BEGIN
	UPDATE tgt SET 
		tgt.[Count] = stg.[Count],
		tgt.[EntityName] = stg.[EntityName],
		tgt.[UpdateTime] = stg.[UpdateTime]
	 FROM [synapse_ce].[SQLCountHistory] tgt
		INNER JOIN [staging].[SQLCountHistory] stg
			ON tgt.[id] = stg.[id]
END

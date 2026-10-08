CREATE   PROCEDURE [synapse_ce].[usp_Update_CrmCountHistory]
AS
BEGIN
	UPDATE tgt SET 
		tgt.[Count] = stg.[Count],
		tgt.[EntityName] = stg.[EntityName],
		tgt.[UpdateTime] = stg.[UpdateTime]
	 FROM [synapse_ce].[CrmCountHistory] tgt
		INNER JOIN [staging].[CrmCountHistory] stg
			ON tgt.[id] = stg.[id]
END

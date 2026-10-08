CREATE   PROCEDURE [synapse_ce].[usp_Insert_CrmCountHistory]
AS
BEGIN
	INSERT INTO [synapse_ce].[CrmCountHistory]
	(
		[Id],
		[EntityName],
		[Count],
		[UpdateTime]
	)
	SELECT 
		stg.[Id],
		stg.[EntityName],
		stg.[Count],
		stg.[UpdateTime]	
	FROM [staging].[CrmCountHistory] stg
		LEFT JOIN [synapse_ce].[CrmCountHistory] tgt
			ON tgt.[id] = stg.[id]
	WHERE tgt.[id] IS NULL
END

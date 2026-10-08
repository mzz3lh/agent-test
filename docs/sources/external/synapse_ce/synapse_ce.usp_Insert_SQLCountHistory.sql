CREATE   PROCEDURE [synapse_ce].[usp_Insert_SQLCountHistory]
AS
BEGIN
	INSERT INTO [synapse_ce].[SQLCountHistory]
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
	FROM [staging].[SQLCountHistory] stg
		LEFT JOIN [synapse_ce].[SQLCountHistory] tgt
			ON tgt.[id] = stg.[id]
	WHERE tgt.[id] IS NULL
END

CREATE   PROCEDURE [synapse_ce].[usp_Insert_DeleteLog]
AS
BEGIN
	INSERT INTO [synapse_ce].[DeleteLog]
	(
		[Id],
		[EntityName],
		[RecordId],
		[SinkDeleteTime],
		[VersionNumber]
	)
	SELECT 
		stg.[Id],
		stg.[EntityName],
		stg.[RecordId],
		stg.[SinkDeleteTime],
		stg.[VersionNumber]	
	FROM [staging].[DeleteLog] stg
		LEFT JOIN [synapse_ce].[DeleteLog] tgt
			ON tgt.[id] = stg.[id]
	WHERE tgt.[id] IS NULL
END

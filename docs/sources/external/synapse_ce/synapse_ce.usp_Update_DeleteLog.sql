CREATE   PROCEDURE [synapse_ce].[usp_Update_DeleteLog]
AS
BEGIN
	UPDATE tgt SET 
		tgt.[EntityName] = stg.[EntityName],
		tgt.[RecordId] = stg.[RecordId],
		tgt.[SinkDeleteTime] = stg.[SinkDeleteTime],
		tgt.[VersionNumber] = stg.[VersionNumber]
	 FROM [synapse_ce].[DeleteLog] tgt
		INNER JOIN [staging].[DeleteLog] stg
			ON tgt.[id] = stg.[id]
END

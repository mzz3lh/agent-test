CREATE   PROCEDURE [synapse_ce].[usp_Insert_AttributeMetadata]
AS
BEGIN
	INSERT INTO [synapse_ce].[AttributeMetadata]
	(
		[Id],
		[EntityName],
		[AttributeName],
		[AttributeType],
		[AttributeTypeCode],
		[Version],
		[Timestamp],
		[MetadataId],
		[Precision]
	)
	SELECT 
		stg.[Id],
		stg.[EntityName],
		stg.[AttributeName],
		stg.[AttributeType],
		stg.[AttributeTypeCode],
		stg.[Version],
		stg.[Timestamp],
		stg.[MetadataId],
		stg.[Precision]	
	FROM [staging].[AttributeMetadata] stg
		LEFT JOIN [synapse_ce].[AttributeMetadata] tgt
			ON tgt.[id] = stg.[id]
	WHERE tgt.[id] IS NULL
END

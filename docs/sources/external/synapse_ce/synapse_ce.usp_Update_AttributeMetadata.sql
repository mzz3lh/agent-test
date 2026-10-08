CREATE   PROCEDURE [synapse_ce].[usp_Update_AttributeMetadata]
AS
BEGIN
	UPDATE tgt SET 
		tgt.[AttributeName] = stg.[AttributeName],
		tgt.[AttributeType] = stg.[AttributeType],
		tgt.[AttributeTypeCode] = stg.[AttributeTypeCode],
		tgt.[EntityName] = stg.[EntityName],
		tgt.[MetadataId] = stg.[MetadataId],
		tgt.[Precision] = stg.[Precision],
		tgt.[Timestamp] = stg.[Timestamp],
		tgt.[Version] = stg.[Version]
	 FROM [synapse_ce].[AttributeMetadata] tgt
		INNER JOIN [staging].[AttributeMetadata] stg
			ON tgt.[id] = stg.[id]
END

CREATE   VIEW [synapse_ce].[vwOptionSetMetadata]
AS

	SELECT	
			EntityName
			,OptionSetName
			,[Option]
			,LocalizedLabel
	FROM synapse_ce.OptionSetMetadata

CREATE   VIEW [synapse_ce].[vwGlobalOptionSetMetadata]
AS

	SELECT	OptionSetName
			,[Option]
			,LocalizedLabel

	FROM synapse_ce.GlobalOptionSetMetadata

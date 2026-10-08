CREATE   VIEW [synapse_ce].[vwStateMetadata]
AS

	SELECT EntityName,	[State],	LocalizedLabel
	FROM synapse_ce.StateMetadata

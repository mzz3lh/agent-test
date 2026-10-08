CREATE   VIEW [synapse_ce].[vwStatusMetadata]
AS

	SELECT EntityName,	[Status],	LocalizedLabel
	FROM synapse_ce.StatusMetadata

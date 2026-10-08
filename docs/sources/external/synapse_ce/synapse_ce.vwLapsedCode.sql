CREATE   VIEW [synapse_ce].[vwLapsedCode]
AS
SELECT 
	[Option] AS [LapsedCode_Code],
	[LocalizedLabel] AS [LapsedCode_Description]
FROM synapse_ce.GlobalOptionSetMetadata
WHERE [OptionSetName] = 'apuk_lapsecode'
	AND EntityName = 'apuk_ricsrecord'

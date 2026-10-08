CREATE   VIEW [synapse_ce].[vwEthnicity]
AS
SELECT 
	[Option] AS [Ethnicity_Code],
	[LocalizedLabel] AS [Ethnicity_Description]
FROM synapse_ce.GlobalOptionSetMetadata
WHERE [OptionSetName] = 'apuk_ethnicity'
	AND EntityName = 'contact'

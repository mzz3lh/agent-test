CREATE   VIEW [CE].[vwDisability_LU] AS

SELECT 
 [Option] AS Disability_Code
,[LocalizedLabel] AS Disability
FROM [synapse_ce].[GlobalOptionSetMetadata]
WHERE OptionSetName = 'apuk_disabilities'
	AND EntityName = 'contact'

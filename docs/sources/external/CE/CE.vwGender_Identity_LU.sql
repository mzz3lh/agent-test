CREATE   VIEW [CE].[vwGender_Identity_LU] AS

SELECT 
 [Option] AS Gender_Identity_Code
,[LocalizedLabel] AS Gender_Identity
FROM [synapse_ce].[GlobalOptionSetMetadata]
WHERE OptionSetName = 'apuk_genderidentity'
	AND EntityName = 'contact'

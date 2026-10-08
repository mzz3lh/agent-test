CREATE   VIEW [CE].[vwSexual_Orientation_LU] AS

SELECT 
 [Option] AS Sexual_Orientation_Code
,[LocalizedLabel] AS Sexual_Orientation
FROM [synapse_ce].[GlobalOptionSetMetadata]
WHERE OptionSetName = 'apuk_sexualorientation'
	AND EntityName = 'contact'

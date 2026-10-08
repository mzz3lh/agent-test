CREATE   VIEW [CE].[vwStatusMetadata]
AS

SELECT 
	[EntityName]
	,[Status]
	,[LocalizedLabel] 
FROM [synapse_ce].[StatusMetadata]

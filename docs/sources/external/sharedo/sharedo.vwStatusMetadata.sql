CREATE   VIEW [Sharedo].[vwStatusMetadata]
AS

SELECT 
	[EntityName]
	,[Status]
	,[LocalizedLabel]
FROM [synapse_ce].[StatusMetadata]

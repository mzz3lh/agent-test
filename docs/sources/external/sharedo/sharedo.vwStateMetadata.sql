CREATE   VIEW [Sharedo].[vwStateMetadata]
AS

SELECT 
	[EntityName]
	,[State]
	,[LocalizedLabel]
FROM [synapse_ce].[StateMetadata]

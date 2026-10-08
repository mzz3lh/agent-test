CREATE   VIEW [CE].[vwStateMetadata]
AS

SELECT 
	[EntityName]
	,[State]
	,[LocalizedLabel] 
FROM [synapse_ce].[StateMetadata]

CREATE   VIEW [Sharedo].[vwGlobalOptionSetMetadata]
AS

SELECT 
	[EntityName]
	,[OptionSetName]
	,[Option]
	,[LocalizedLabel]
FROM [synapse_ce].[GlobalOptionSetMetadata]

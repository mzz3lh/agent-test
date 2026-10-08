CREATE   VIEW [CE].[vwGlobalOptionSetMetadata]
AS

SELECT [OptionSetName]
      ,[Option]
      ,[LocalizedLabel]
	  ,[EntityName]
FROM [synapse_ce].[GlobalOptionSetMetadata]

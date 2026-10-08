CREATE   VIEW [CE].[vwOptionSetMetadata]
AS

SELECT [EntityName]
      ,[OptionSetName]
      ,[Option]
      ,[LocalizedLabel]
FROM [synapse_ce].[OptionSetMetadata]

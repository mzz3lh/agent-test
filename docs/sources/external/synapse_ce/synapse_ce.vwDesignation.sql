CREATE   VIEW [synapse_ce].[vwDesignation]
AS
SELECT 
	[Option] AS [Designation_Code],
	[LocalizedLabel] AS [Designation_Description]
FROM synapse_ce.GlobalOptionSetMetadata
WHERE [OptionSetName] = 'apuk_designation'
	AND EntityName = 'apuk_ricsrecord'

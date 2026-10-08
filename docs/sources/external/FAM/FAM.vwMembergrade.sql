/****** Object:  View [FAM].[vwMembergrade]    Script Date: 25/10/2022 13:03:38 ******/
CREATE   VIEW [FAM].[vwMembergrade]
AS
SELECT 
	[Option] AS [Designation_Code],
	[LocalizedLabel] AS [Designation_Description]
FROM [synapse_ce].[GlobalOptionSetMetadata]
WHERE [OptionSetName] = 'apuk_designation'
	AND [EntityName] = 'apuk_ricsrecord'

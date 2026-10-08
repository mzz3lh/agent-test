CREATE   VIEW [synapse_ce].[vwMemberGrade]
AS
SELECT 
	[Option] AS [MemberGrade_Code],
	[LocalizedLabel] AS [MemberGrade_Description]
FROM synapse_ce.GlobalOptionSetMetadata
WHERE [OptionSetName] = 'apuk_membergrade'
	AND EntityName = 'apuk_ricsrecord'

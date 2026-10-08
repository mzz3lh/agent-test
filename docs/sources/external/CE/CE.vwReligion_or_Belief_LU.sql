CREATE   VIEW [CE].[vwReligion_or_Belief_LU] AS

SELECT 
 [Option] AS Religion_or_Belief_Code
,CASE WHEN [Option] = 200000003 THEN 'Christian' ELSE LocalizedLabel END AS Religion_or_Belief
FROM [synapse_ce].[GlobalOptionSetMetadata]
WHERE OptionSetName = 'apuk_religionorbelief'
	AND EntityName = 'contact'
UNION
SELECT -1, 'NULL'

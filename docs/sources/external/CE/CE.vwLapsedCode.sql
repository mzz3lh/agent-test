CREATE   VIEW [CE].[vwLapsedCode]
AS
SELECT
	-1 AS [LapsedCode_Code],
	'N/A' AS [LapsedCode_Description]

UNION ALL 

SELECT 
	[LapsedCode_Code],
	[LapsedCode_Description]
FROM [synapse_ce].[vwLapsedCode]

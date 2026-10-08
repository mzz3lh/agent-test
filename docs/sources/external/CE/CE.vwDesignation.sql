CREATE   VIEW [CE].[vwDesignation]
AS
SELECT
	-1 AS [Designation_Code],
	'N/A' AS [Designation_Description]

UNION ALL 

SELECT 
	[Designation_Code],
	[Designation_Description]
FROM [synapse_ce].[vwDesignation]

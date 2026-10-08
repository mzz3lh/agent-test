CREATE   VIEW [CE].[vwOCECompetencies]
AS
SELECT 
	[apuk_competencyid],
	[Name],
	[IsTechnical]
FROM [synapse_ce].[vwOCECompetencies]

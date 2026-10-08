CREATE   VIEW [synapse_ce].[vwOCECompetencies]
AS
SELECT   
	apuk_competencyid,
	apuk_name AS [Name],
	apuk_istechnical AS [IsTechnical]
FROM [synapse_ce].[apuk_competency] cmt

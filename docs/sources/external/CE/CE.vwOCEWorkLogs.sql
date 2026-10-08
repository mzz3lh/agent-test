CREATE   VIEW [CE].[vwOCEWorkLogs]
AS
SELECT 
	[ID],
	[ContactId],
	[CompetencyId],
	[StartDate],
	[Days],
	[Title],
	[Level],
	[Notes]
FROM [synapse_ce].[vwOCEWorkLogs]

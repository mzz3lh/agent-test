CREATE   VIEW [CE].[vwOCEUserCompetencies]
AS
SELECT 
	[ContactID],
	[CompetencyId],
	[Level],
	[CompetencyType],
	[CompetencyType_Description],
	[createdon],
	[createdby],
	[LastUpdated],
	[modifiedby],
	[StateCode],
	[StateCode_Description],
	[StatusCode],
	[StatusCode_Description]
FROM [synapse_ce].[vwOCEUserCompetencies]

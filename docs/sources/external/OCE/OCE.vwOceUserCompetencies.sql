CREATE VIEW [OCE].[vwOceUserCompetencies]
AS
SELECT
	[ContactId],
	[CompetencyId],
	[Level],
	[CompetencyType],
	[IsCurrentlyActive],
	[LastUpdated],
	[CompetencySlot]
FROM [OCE].[tblOceUserCompetencies]

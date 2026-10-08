CREATE PROCEDURE [OCE].[usp_Insert_OceUserCompetencies]
AS
BEGIN
	
	INSERT INTO [OCE].[tblOceUserCompetencies]
	(
		[ContactId],
		[CompetencyId],
		[Level],
		[CompetencyType],
		[IsCurrentlyActive],
		[LastUpdated],
		[CompetencySlot],
		[BI_Created]
	)
	SELECT 
		wrk.[ContactId],
		wrk.[CompetencyId],
		wrk.[Level],
		wrk.[CompetencyType],
		wrk.[IsCurrentlyActive],
		wrk.[LastUpdated],
		wrk.[CompetencySlot],
		GETDATE()
	FROM [Work].[tblOceUserCompetencies] wrk
		LEFT JOIN [OCE].[tblOceUserCompetencies] tgt
			ON wrk.[ContactId] = tgt.[ContactId]
			AND wrk.[CompetencyId] = tgt.[CompetencyId]
			AND wrk.[Level] = tgt.[Level]
	WHERE tgt.[ContactId] IS NULL
END

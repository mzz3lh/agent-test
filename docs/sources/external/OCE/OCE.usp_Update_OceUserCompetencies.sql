CREATE PROCEDURE [OCE].[usp_Update_OceUserCompetencies]
AS
BEGIN
	
	UPDATE tgt SET
		tgt.[CompetencyType] = src.[CompetencyType],
		tgt.[IsCurrentlyActive] = src.[IsCurrentlyActive],
		tgt.[LastUpdated] = src.[LastUpdated],
		tgt.[CompetencySlot] = src.[CompetencySlot],
		tgt.[BI_Modified] = GETDATE()
	FROM [OCE].[tblOceUserCompetencies] tgt
		INNER JOIN
			(
				SELECT 
					wrk.[ContactId],
					wrk.[CompetencyId],
					wrk.[Level],
					wrk.[CompetencyType],
					wrk.[IsCurrentlyActive],
					wrk.[LastUpdated],
					wrk.[CompetencySlot]
				FROM [Work].[tblOceUserCompetencies] wrk
			) src
				ON src.[ContactId] = tgt.[ContactId]
				AND src.[CompetencyId] = tgt.[CompetencyId]
				AND src.[Level] = tgt.[Level]
END

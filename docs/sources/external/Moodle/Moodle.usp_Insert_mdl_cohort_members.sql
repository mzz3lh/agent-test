CREATE   PROCEDURE [Moodle].[usp_Insert_mdl_cohort_members]
AS
BEGIN

	INSERT INTO [Moodle].[mdl_cohort_members]
	(
		[id],
		[cohortid],
		[userid],
		[timeadded]
	)
	SELECT
		src.[id],
		src.[cohortid],
		src.[userid],
		src.[timeadded]
	FROM [work].[mdl_cohort_members] src
		LEFT JOIN [Moodle].[mdl_cohort_members] tgt
			ON src.[id] = tgt.[id]
	WHERE tgt.[id]  IS NULL
END

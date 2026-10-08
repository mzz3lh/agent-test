CREATE   PROCEDURE [Moodle].[usp_Update_mdl_cohort_members]
AS
BEGIN

	UPDATE tgt SET 
		tgt.[cohortid] = src.[cohortid],
		tgt.[userid] = src.[userid],
		tgt.[timeadded] = src.[timeadded]
	FROM [Moodle].[mdl_cohort_members] tgt
		INNER JOIN [work].[mdl_cohort_members] src
			ON src.[id] = tgt.[id]
END

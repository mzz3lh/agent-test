CREATE   PROCEDURE [Moodle].[usp_Update_mdl_course_completions]
AS
BEGIN

	UPDATE tgt SET 
		tgt.[userid] = src.[userid],
		tgt.[course] = src.[course],
		tgt.[timeenrolled] = src.[timeenrolled],
		tgt.[timestarted] = src.[timestarted],
		tgt.[timecompleted] = src.[timecompleted],
		tgt.[reaggregate] = src.[reaggregate]
	FROM [Moodle].[mdl_course_completions] tgt
		INNER JOIN [work].[mdl_course_completions] src
			ON src.[id] = tgt.[id]
END

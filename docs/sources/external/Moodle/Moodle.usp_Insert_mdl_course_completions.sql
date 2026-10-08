CREATE   PROCEDURE [Moodle].[usp_Insert_mdl_course_completions]
AS
BEGIN

	INSERT INTO [Moodle].[mdl_course_completions]
	(
		[id],
		[userid],
		[course],
		[timeenrolled],
		[timestarted],
		[timecompleted],
		[reaggregate]
	)
	SELECT
		src.[id],
		src.[userid],
		src.[course],
		src.[timeenrolled],
		src.[timestarted],
		src.[timecompleted],
		src.[reaggregate]
	FROM [work].[mdl_course_completions] src
		LEFT JOIN [Moodle].[mdl_course_completions] tgt
			ON src.[id] = tgt.[id]
	WHERE tgt.[id]  IS NULL
END

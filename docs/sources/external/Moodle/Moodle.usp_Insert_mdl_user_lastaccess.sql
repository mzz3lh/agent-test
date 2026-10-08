CREATE   PROCEDURE [Moodle].[usp_Insert_mdl_user_lastaccess]
AS
BEGIN

	INSERT INTO [Moodle].[mdl_user_lastaccess]
	(
		[id],
		[userid],
		[courseid],
		[timeaccess]
	)
	SELECT
		src.[id],
		src.[userid],
		src.[courseid],
		src.[timeaccess]
	FROM [work].[mdl_user_lastaccess] src
		LEFT JOIN [Moodle].[mdl_user_lastaccess] tgt
			ON src.[id] = tgt.[id]
	WHERE tgt.[id]  IS NULL
END

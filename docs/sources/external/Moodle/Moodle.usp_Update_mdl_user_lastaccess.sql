CREATE   PROCEDURE [Moodle].[usp_Update_mdl_user_lastaccess]
AS
BEGIN

	UPDATE tgt SET 
		tgt.[userid] = src.[userid],
		tgt.[courseid] = src.[courseid],
		tgt.[timeaccess] = src.[timeaccess]
	FROM [Moodle].[mdl_user_lastaccess] tgt
		INNER JOIN [work].[mdl_user_lastaccess] src
			ON src.[id] = tgt.[id]
END

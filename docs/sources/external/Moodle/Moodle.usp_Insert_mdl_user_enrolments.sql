CREATE   PROCEDURE [Moodle].[usp_Insert_mdl_user_enrolments]
AS
BEGIN

	INSERT INTO [Moodle].[mdl_user_enrolments]
	(
		[id],
		[status],
		[enrolid],
		[userid],
		[timestart],
		[timeend],
		[modifierid],
		[timecreated],
		[timemodified]
	)
	SELECT
		src.[id],
		src.[status],
		src.[enrolid],
		src.[userid],
		src.[timestart],
		src.[timeend],
		src.[modifierid],
		src.[timecreated],
		src.[timemodified]
	FROM [work].[mdl_user_enrolments] src
		LEFT JOIN [Moodle].[mdl_user_enrolments] tgt
			ON src.[id] = tgt.[id]
	WHERE tgt.[id] IS NULL

END

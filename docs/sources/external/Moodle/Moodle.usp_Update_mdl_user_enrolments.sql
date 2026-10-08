CREATE   PROCEDURE [Moodle].[usp_Update_mdl_user_enrolments]
AS
BEGIN

	UPDATE tgt SET
		tgt.[status] = src.[status],
		tgt.[enrolid] = src.[enrolid],
		tgt.[userid] = src.[userid],
		tgt.[timestart] = src.[timestart],
		tgt.[timeend] = src.[timeend],
		tgt.[modifierid] = src.[modifierid],
		tgt.[timecreated] = src.[timecreated],
		tgt.[timemodified] = src.[timemodified]

	FROM [Moodle].[mdl_user_enrolments] tgt
		INNER JOIN [work].[mdl_user_enrolments] src
			ON src.[id] = tgt.[id]

END

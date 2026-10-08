CREATE   PROCEDURE [Moodle].[usp_Update_mdl_enrol]
AS
BEGIN

	UPDATE tgt SET
		tgt.[enrol] = src.[enrol],
		tgt.[status] = src.[status],
		tgt.[courseid] = src.[courseid],
		tgt.[sortorder] = src.[sortorder],
		tgt.[name] = src.[name],
		tgt.[enrolperiod] = src.[enrolperiod],
		tgt.[enrolstartdate] = src.[enrolstartdate],
		tgt.[enrolenddate] = src.[enrolenddate],
		tgt.[expirynotify] = src.[expirynotify],
		tgt.[expirythreshold] = src.[expirythreshold],
		tgt.[notifyall] = src.[notifyall],
		tgt.[password] = src.[password],
		tgt.[cost] = src.[cost],
		tgt.[currency] = src.[currency],
		tgt.[roleid] = src.[roleid],
		tgt.[customint1] = src.[customint1],
		tgt.[customint2] = src.[customint2],
		tgt.[customint3] = src.[customint3],
		tgt.[customint4] = src.[customint4],
		tgt.[customint5] = src.[customint5],
		tgt.[customint6] = src.[customint6],
		tgt.[customint7] = src.[customint7],
		tgt.[customint8] = src.[customint8],
		tgt.[customchar1] = src.[customchar1],
		tgt.[customdec1] = src.[customdec1],
		tgt.[customdec2] = src.[customdec2],
		tgt.[customtext2] = src.[customtext2],
		tgt.[timecreated] = src.[timecreated],
		tgt.[timemodified] = src.[timemodified]
	FROM [Moodle].[mdl_enrol] tgt
		INNER JOIN [work].[mdl_enrol] src
			ON src.[id] = tgt.[id]

END

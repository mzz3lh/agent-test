/****    END: New Drupal procedures *************/


CREATE   PROCEDURE [Moodle].[usp_Insert_mdl_enrol]
AS
BEGIN

	INSERT INTO [Moodle].[mdl_enrol]
	(
		[id],
		[enrol],
		[status],
		[courseid],
		[sortorder],
		[name],
		[enrolperiod],
		[enrolstartdate],
		[enrolenddate],
		[expirynotify],
		[expirythreshold],
		[notifyall],
		[password],
		[cost],
		[currency],
		[roleid],
		[customint1],
		[customint2],
		[customint3],
		[customint4],
		[customint5],
		[customint6],
		[customint7],
		[customint8],
		[customchar1],
		[customdec1],
		[customdec2],
		[customtext2],
		[timecreated],
		[timemodified]
	)
	SELECT
		src.[id],
		src.[enrol],
		src.[status],
		src.[courseid],
		src.[sortorder],
		src.[name],
		src.[enrolperiod],
		src.[enrolstartdate],
		src.[enrolenddate],
		src.[expirynotify],
		src.[expirythreshold],
		src.[notifyall],
		src.[password],
		src.[cost],
		src.[currency],
		src.[roleid],
		src.[customint1],
		src.[customint2],
		src.[customint3],
		src.[customint4],
		src.[customint5],
		src.[customint6],
		src.[customint7],
		src.[customint8],
		src.[customchar1],
		src.[customdec1],
		src.[customdec2],
		src.[customtext2],
		src.[timecreated],
		src.[timemodified]
	FROM [work].[mdl_enrol] src
		LEFT JOIN [Moodle].[mdl_enrol] tgt
			ON src.[id] = tgt.[id]
	WHERE tgt.[id] IS NULL

END

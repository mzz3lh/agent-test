CREATE   PROCEDURE [Moodle].[usp_Update_mdl_course]
AS
BEGIN

	UPDATE tgt SET
		tgt.[category] = src.[category],
		tgt.[sortorder] = src.[sortorder],
		tgt.[fullname] = src.[fullname],
		tgt.[shortname] = src.[shortname],
		tgt.[idnumber] = src.[idnumber],
		tgt.[summary] = src.[summary],
		tgt.[summaryformat] = src.[summaryformat],
		tgt.[format] = src.[format],
		tgt.[showgrades] = src.[showgrades],
		tgt.[newsitems] = src.[newsitems],
		tgt.[startdate] = src.[startdate],
		tgt.[enddate] = src.[enddate],
		tgt.[relativedatesmode] = src.[relativedatesmode],
		tgt.[marker] = src.[marker],
		tgt.[maxbytes] = src.[maxbytes],
		tgt.[legacyfiles] = src.[legacyfiles],
		tgt.[showreports] = src.[showreports],
		tgt.[visible] = src.[visible],
		tgt.[visibleold] = src.[visibleold],
		tgt.[downloadcontent] = src.[downloadcontent],
		tgt.[groupmode] = src.[groupmode],
		tgt.[groupmodeforce] = src.[groupmodeforce],
		tgt.[defaultgroupingid] = src.[defaultgroupingid],
		tgt.[lang] = src.[lang],
		tgt.[calendartype] = src.[calendartype],
		tgt.[theme] = src.[theme],
		tgt.[timecreated] = src.[timecreated],
		tgt.[timemodified] = src.[timemodified],
		tgt.[welcomemessage] = src.[welcomemessage],
		tgt.[requested] = src.[requested],
		tgt.[enablecompletion] = src.[enablecompletion],
		tgt.[completionnotify] = src.[completionnotify],
		tgt.[defaultgroupid] = src.[defaultgroupid],
		tgt.[originalcourseid] = src.[originalcourseid],
		tgt.[showactivitydates] = src.[showactivitydates],
		tgt.[showcompletionconditions] = src.[showcompletionconditions]
	FROM [Moodle].[mdl_course] tgt
		INNER JOIN [work].[mdl_course] src
			ON src.[id] = tgt.[id]

END

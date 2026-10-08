CREATE   PROCEDURE [Moodle].[usp_Update_mdl_customfield_field]
AS
BEGIN

	UPDATE tgt SET
		tgt.[shortname] = src.[shortname],
		tgt.[name] = src.[name],
		tgt.[type] = src.[type],
		tgt.[description] = src.[description],
		tgt.[descriptionformat] = src.[descriptionformat],
		tgt.[sortorder] = src.[sortorder],
		tgt.[categoryid] = src.[categoryid],
		tgt.[configdata] = src.[configdata],
		tgt.[timecreated] = src.[timecreated],
		tgt.[timemodified] = src.[timemodified]
	FROM [Moodle].[mdl_customfield_field] tgt
		INNER JOIN [work].[mdl_customfield_field] src
			ON src.[id] = tgt.[id]

END

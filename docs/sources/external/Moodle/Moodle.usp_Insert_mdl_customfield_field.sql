CREATE    PROCEDURE [Moodle].[usp_Insert_mdl_customfield_field]
AS
BEGIN

	INSERT INTO [Moodle].[mdl_customfield_field]
	(
		[id],
		[shortname],
		[name],
		[type],
		[description],
		[descriptionformat],
		[sortorder],
		[categoryid],
		[configdata],
		[timecreated],
		[timemodified]
	)
	SELECT
		src.[id],
		src.[shortname],
		src.[name],
		src.[type],
		src.[description],
		src.[descriptionformat],
		src.[sortorder],
		src.[categoryid],
		src.[configdata],
		src.[timecreated],
		src.[timemodified]
	FROM [work].[mdl_customfield_field] src
		LEFT JOIN [Moodle].[mdl_customfield_field] tgt
			ON src.[id] = tgt.[id]
	WHERE tgt.[id] IS NULL

END

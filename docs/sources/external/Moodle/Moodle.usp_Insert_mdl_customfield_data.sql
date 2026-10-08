CREATE   PROCEDURE [Moodle].[usp_Insert_mdl_customfield_data]
AS
BEGIN

	INSERT INTO [Moodle].[mdl_customfield_data]
	(
		[id],
		[fieldid],
		[instanceid],
		[intvalue],
		[decvalue],
		[shortcharvalue],
		[charvalue],
		[value],
		[valueformat],
		[timecreated],
		[timemodified],
		[contextid]
	)
	SELECT
		src.[id],
		src.[fieldid],
		src.[instanceid],
		src.[intvalue],
		src.[decvalue],
		src.[shortcharvalue],
		src.[charvalue],
		src.[value],
		src.[valueformat],
		src.[timecreated],
		src.[timemodified],
		src.[contextid]
	FROM [work].[mdl_customfield_data] src
		LEFT JOIN [Moodle].[mdl_customfield_data] tgt
			ON src.[id] = tgt.[id]
	WHERE tgt.[id]  IS NULL
END

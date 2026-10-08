CREATE   PROCEDURE [Moodle].[usp_Update_mdl_customfield_data]
AS
BEGIN

	UPDATE tgt SET 
		tgt.[fieldid] = src.[fieldid],
		tgt.[instanceid] = src.[instanceid],
		tgt.[intvalue] = src.[intvalue],
		tgt.[decvalue] = src.[decvalue],
		tgt.[shortcharvalue] = src.[shortcharvalue],
		tgt.[charvalue] = src.[charvalue],
		tgt.[value] = src.[value],
		tgt.[valueformat] = src.[valueformat],
		tgt.[timecreated] = src.[timecreated],
		tgt.[timemodified] = src.[timemodified],
		tgt.[contextid] = src.[contextid]
	FROM [Moodle].[mdl_customfield_data] tgt
		INNER JOIN [work].[mdl_customfield_data] src
			ON src.[id] = tgt.[id]
END

CREATE   PROCEDURE [Moodle].[usp_Insert_mdl_local_ricsfunctions_orders]
AS
BEGIN

	INSERT INTO [Moodle].[mdl_local_ricsfunctions_orders]
	(
		[id],
		[userenrolid],
		[orderid]
	)
	SELECT
		src.[id],
		src.[userenrolid],
		src.[orderid]
	FROM [work].[mdl_local_ricsfunctions_orders] src
		LEFT JOIN [Moodle].[mdl_local_ricsfunctions_orders] tgt
			ON src.[id] = tgt.[id]
	WHERE tgt.[id]  IS NULL
END

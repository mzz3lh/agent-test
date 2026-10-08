CREATE   PROCEDURE [Moodle].[usp_Update_mdl_local_ricsfunctions_orders]
AS
BEGIN

	UPDATE tgt SET 
		tgt.[userenrolid] = src.[userenrolid],
		tgt.[orderid] = src.[orderid]
	FROM [Moodle].[mdl_local_ricsfunctions_orders] tgt
		INNER JOIN [work].[mdl_local_ricsfunctions_orders] src
			ON src.[id] = tgt.[id]
END

CREATE   PROCEDURE [synapse_fo].[usp_Insert_BUDGETTRANSACTIONCODE]
AS
BEGIN
	--Raj Maddala, 2025-02-06, Insert stored procedure for Budgettransactioncode

	INSERT INTO [synapse_fo].[BUDGETTRANSACTIONCODE]
	(
		[SinkCreatedOn],
		[SinkModifiedOn],
		[budgettransactiontype],
		[isdefault],
		[sysdatastatecode],
		[description],
		[name],
		[reason],
		[workflowtablesequencenumber],
		[modifieddatetime],
		[modifiedby],
		[modifiedtransactionid],
		[createddatetime],
		[createdby],
		[createdtransactionid],
		[dataareaid],
		[recversion],
		[partition],
		[sysrowversion],
		[recid],
		[tableid],
		[versionnumber],
		[createdon],
		[modifiedon],
		[IsDelete],
		[PartitionId]
	)
	SELECT
		src.[SinkCreatedOn],
		src.[SinkModifiedOn],
		src.[budgettransactiontype],
		src.[isdefault],
		src.[sysdatastatecode],
		src.[description],
		src.[name],
		src.[reason],
		src.[workflowtablesequencenumber],
		src.[modifieddatetime],
		src.[modifiedby],
		src.[modifiedtransactionid],
		src.[createddatetime],
		src.[createdby],
		src.[createdtransactionid],
		src.[dataareaid],
		src.[recversion],
		src.[partition],
		src.[sysrowversion],
		src.[recid],
		src.[tableid],
		src.[versionnumber],
		src.[createdon],
		src.[modifiedon],
		src.[IsDelete],
		src.[PartitionId]
	FROM [staging_fo].[BUDGETTRANSACTIONCODE] src
		LEFT JOIN [synapse_fo].[BUDGETTRANSACTIONCODE] tgt
			ON src.[recid] = tgt.[recid]
	WHERE tgt.[recid] IS NULL

END

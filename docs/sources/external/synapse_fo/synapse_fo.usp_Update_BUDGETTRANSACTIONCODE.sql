CREATE   PROCEDURE [synapse_fo].[usp_Update_BUDGETTRANSACTIONCODE]
AS
BEGIN
	--Raj Maddala, 2025-02-06, Insert stored procedure for Budgettransactioncode

	UPDATE tgt SET
		tgt.[SinkCreatedOn] = src.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = src.[SinkModifiedOn],
		tgt.[budgettransactiontype] = src.[budgettransactiontype],
		tgt.[isdefault] = src.[isdefault],
		tgt.[sysdatastatecode] = src.[sysdatastatecode],
		tgt.[description] = src.[description],
		tgt.[name] = src.[name],
		tgt.[reason] = src.[reason],
		tgt.[workflowtablesequencenumber] = src.[workflowtablesequencenumber],
		tgt.[modifieddatetime] = src.[modifieddatetime],
		tgt.[modifiedby] = src.[modifiedby],
		tgt.[modifiedtransactionid] = src.[modifiedtransactionid],
		tgt.[createddatetime] = src.[createddatetime],
		tgt.[createdby] = src.[createdby],
		tgt.[createdtransactionid] = src.[createdtransactionid],
		tgt.[dataareaid] = src.[dataareaid],
		tgt.[recversion] = src.[recversion],
		tgt.[partition] = src.[partition],
		tgt.[sysrowversion] = src.[sysrowversion],
		tgt.[tableid] = src.[tableid],
		tgt.[versionnumber] = src.[versionnumber],
		tgt.[createdon] = src.[createdon],
		tgt.[modifiedon] = src.[modifiedon],
		tgt.[IsDelete] = src.[IsDelete],
		tgt.[PartitionId] = src.[PartitionId]
	FROM [synapse_fo].[BUDGETTRANSACTIONCODE] tgt
		INNER JOIN [staging_fo].[BUDGETTRANSACTIONCODE] src
			ON src.[recid] = tgt.[recid]

END

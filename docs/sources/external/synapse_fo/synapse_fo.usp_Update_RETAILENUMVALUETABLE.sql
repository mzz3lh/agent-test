CREATE   PROCEDURE [synapse_fo].[usp_Update_RETAILENUMVALUETABLE]
AS
BEGIN
	--Raj Maddala, 2025-02-06, Insert stored procedure for RETAILENUMVALUETABLE

	UPDATE tgt SET
		tgt.[Id] = src.[Id],
		tgt.[SinkCreatedOn] = src.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = src.[SinkModifiedOn],
		tgt.[sysdatastatecode] = src.[sysdatastatecode],
		tgt.[enumname] = src.[enumname],
		tgt.[membername] = src.[membername],
		tgt.[value] = src.[value],
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
	FROM [synapse_fo].[RETAILENUMVALUETABLE] tgt
		INNER JOIN [staging_fo].[RETAILENUMVALUETABLE] src
			ON src.[recid] = tgt.[recid]

END

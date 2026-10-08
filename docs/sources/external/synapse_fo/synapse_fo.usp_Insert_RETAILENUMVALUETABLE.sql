CREATE   PROCEDURE [synapse_fo].[usp_Insert_RETAILENUMVALUETABLE]
AS
BEGIN
	--Raj Maddala, 2025-02-06, Insert stored procedure for RETAILENUMVALUETABLE

	INSERT INTO [synapse_fo].[RETAILENUMVALUETABLE]
	(
		[Id],
		[SinkCreatedOn],
		[SinkModifiedOn],
		[sysdatastatecode],
		[enumname],
		[membername],
		[value],
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
		src.[Id],
		src.[SinkCreatedOn],
		src.[SinkModifiedOn],
		src.[sysdatastatecode],
		src.[enumname],
		src.[membername],
		src.[value],
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
	FROM [staging_fo].[RETAILENUMVALUETABLE] src
		LEFT JOIN [synapse_fo].[RETAILENUMVALUETABLE] tgt
			ON src.[recid] = tgt.[recid]
	WHERE tgt.[recid] IS NULL

END

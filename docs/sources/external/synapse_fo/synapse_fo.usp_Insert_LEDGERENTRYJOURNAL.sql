CREATE   PROCEDURE [synapse_fo].[usp_Insert_LEDGERENTRYJOURNAL]
AS
BEGIN

	INSERT INTO [synapse_fo].[LEDGERENTRYJOURNAL]
	(
		[Id],
		[SinkCreatedOn],
		[SinkModifiedOn],
		[sysdatastatecode],
		[journalnumber],
		[ledgerjournaltabledataareaid],
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
		wrk.[Id],
		wrk.[SinkCreatedOn],
		wrk.[SinkModifiedOn],
		wrk.[sysdatastatecode],
		wrk.[journalnumber],
		wrk.[ledgerjournaltabledataareaid],
		wrk.[modifieddatetime],
		wrk.[modifiedby],
		wrk.[modifiedtransactionid],
		wrk.[createddatetime],
		wrk.[createdby],
		wrk.[createdtransactionid],
		wrk.[dataareaid],
		wrk.[recversion],
		wrk.[partition],
		wrk.[sysrowversion],
		wrk.[recid],
		wrk.[tableid],
		wrk.[versionnumber],
		wrk.[createdon],
		wrk.[modifiedon],
		wrk.[IsDelete],
		wrk.[PartitionId]
	FROM [staging_fo].[LEDGERENTRYJOURNAL] wrk
		LEFT JOIN [synapse_fo].[LEDGERENTRYJOURNAL] tgt
			ON wrk.[recid] = tgt.[recid]
	WHERE tgt.[recid] IS NULL

END

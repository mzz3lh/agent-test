CREATE   PROCEDURE [synapse_fo].[usp_Update_LEDGERENTRYJOURNAL]
AS
BEGIN

	UPDATE tgt SET
		tgt.[Id] = wrk.[id],
		tgt.[SinkCreatedOn] = wrk.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = wrk.[SinkModifiedOn],
		tgt.[sysdatastatecode] = wrk.[sysdatastatecode],
		tgt.[journalnumber] = wrk.[journalnumber],
		tgt.[ledgerjournaltabledataareaid] = wrk.[ledgerjournaltabledataareaid],
		tgt.[modifieddatetime] = wrk.[modifieddatetime],
		tgt.[modifiedby] = wrk.[modifiedby],
		tgt.[modifiedtransactionid] = wrk.[modifiedtransactionid],
		tgt.[createddatetime] = wrk.[createddatetime],
		tgt.[createdby] = wrk.[createdby],
		tgt.[createdtransactionid] = wrk.[createdtransactionid],
		tgt.[dataareaid] = wrk.[dataareaid],
		tgt.[recversion] = wrk.[recversion],
		tgt.[partition] = wrk.[partition],
		tgt.[sysrowversion] = wrk.[sysrowversion],
		tgt.[tableid] = wrk.[tableid],
		tgt.[versionnumber] = wrk.[versionnumber],
		tgt.[createdon] = wrk.[createdon],
		tgt.[modifiedon] = wrk.[modifiedon],
		tgt.[IsDelete] = wrk.[IsDelete],
		tgt.[PartitionId] = wrk.[PartitionId]
	FROM [synapse_fo].[LEDGERENTRYJOURNAL] tgt
		INNER JOIN [staging_fo].[LEDGERENTRYJOURNAL] wrk
			ON wrk.[recid] = tgt.[recid]

END

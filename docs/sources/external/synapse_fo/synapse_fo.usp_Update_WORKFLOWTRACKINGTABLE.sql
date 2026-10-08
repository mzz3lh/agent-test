CREATE   PROCEDURE [synapse_fo].[usp_Update_WORKFLOWTRACKINGTABLE]
AS
BEGIN

	UPDATE tgt SET
		tgt.[Id]  =wrk.[Id],
		tgt.[SinkCreatedOn]  =wrk.[SinkCreatedOn],
		tgt.[SinkModifiedOn]  =wrk.[SinkModifiedOn],
		tgt.[trackingcontext]  =wrk.[trackingcontext],
		tgt.[trackingtype]  =wrk.[trackingtype],
		tgt.[sysdatastatecode]  =wrk.[sysdatastatecode],
		tgt.[elementid]  =wrk.[elementid],
		tgt.[name]  =wrk.[name],
		tgt.[stepid]  =wrk.[stepid],
		tgt.[trackingdatetimetickcount]  =wrk.[trackingdatetimetickcount],
		tgt.[trackingid]  =wrk.[trackingid],
		tgt.[user]  =wrk.[user],
		tgt.[workflowelementtable]  =wrk.[workflowelementtable],
		tgt.[workflowparallelbranchtable]  =wrk.[workflowparallelbranchtable],
		tgt.[workflowsteptable]  =wrk.[workflowsteptable],
		tgt.[workflowsubworkflow]  =wrk.[workflowsubworkflow],
		tgt.[workflowtrackingstatustable]  =wrk.[workflowtrackingstatustable],
		tgt.[modifieddatetime]  =wrk.[modifieddatetime],
		tgt.[modifiedby]  =wrk.[modifiedby],
		tgt.[modifiedtransactionid]  =wrk.[modifiedtransactionid],
		tgt.[createddatetime]  =wrk.[createddatetime],
		tgt.[createdby]  =wrk.[createdby],
		tgt.[createdtransactionid]  =wrk.[createdtransactionid],
		tgt.[dataareaid]  =wrk.[dataareaid],
		tgt.[recversion]  =wrk.[recversion],
		tgt.[partition]  =wrk.[partition],
		tgt.[sysrowversion]  =wrk.[sysrowversion],
		tgt.[tableid]  =wrk.[tableid],
		tgt.[versionnumber]  =wrk.[versionnumber],
		tgt.[createdon]  =wrk.[createdon],
		tgt.[modifiedon]  =wrk.[modifiedon],
		tgt.[IsDelete]  =wrk.[IsDelete],
		tgt.[PartitionId]  =wrk.[PartitionId]
	FROM [synapse_fo].[WORKFLOWTRACKINGTABLE] tgt
		INNER JOIN [staging_fo].[WORKFLOWTRACKINGTABLE] wrk
			ON wrk.[recid] = tgt.[recid]

END

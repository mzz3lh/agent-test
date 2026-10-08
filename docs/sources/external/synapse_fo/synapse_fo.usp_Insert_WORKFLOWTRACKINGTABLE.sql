CREATE   PROCEDURE [synapse_fo].[usp_Insert_WORKFLOWTRACKINGTABLE]
AS
BEGIN

	INSERT INTO [synapse_fo].[WORKFLOWTRACKINGTABLE]
	(
		[Id],
		[SinkCreatedOn],
		[SinkModifiedOn],
		[trackingcontext],
		[trackingtype],
		[sysdatastatecode],
		[elementid],
		[name],
		[stepid],
		[trackingdatetimetickcount],
		[trackingid],
		[user],
		[workflowelementtable],
		[workflowparallelbranchtable],
		[workflowsteptable],
		[workflowsubworkflow],
		[workflowtrackingstatustable],
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
		wrk.[trackingcontext],
		wrk.[trackingtype],
		wrk.[sysdatastatecode],
		wrk.[elementid],
		wrk.[name],
		wrk.[stepid],
		wrk.[trackingdatetimetickcount],
		wrk.[trackingid],
		wrk.[user],
		wrk.[workflowelementtable],
		wrk.[workflowparallelbranchtable],
		wrk.[workflowsteptable],
		wrk.[workflowsubworkflow],
		wrk.[workflowtrackingstatustable],
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
	FROM [staging_fo].[WORKFLOWTRACKINGTABLE] wrk
		LEFT JOIN [synapse_fo].[WORKFLOWTRACKINGTABLE] tgt
			ON wrk.[recid] = tgt.[recid]
	WHERE tgt.[recid] IS NULL

END

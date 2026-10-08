CREATE   PROCEDURE [synapse_fo].[usp_Update_WORKFLOWTRACKINGSTATUSTABLE]
AS
BEGIN

	UPDATE tgt SET
		tgt.[Id]  =wrk.[Id],
		tgt.[SinkCreatedOn]  =wrk.[SinkCreatedOn],
		tgt.[SinkModifiedOn]  =wrk.[SinkModifiedOn],
		tgt.[trackingstatus]  =wrk.[trackingstatus],
		tgt.[workflowtype]  =wrk.[workflowtype],
		tgt.[sysdatastatecode]  =wrk.[sysdatastatecode],
		tgt.[instancenumber]  =wrk.[instancenumber],
		tgt.[configurationname]  =wrk.[configurationname],
		tgt.[configurationnumber]  =wrk.[configurationnumber],
		tgt.[configurationversionid]  =wrk.[configurationversionid],
		tgt.[contextcompanyid]  =wrk.[contextcompanyid],
		tgt.[contextrecid]  =wrk.[contextrecid],
		tgt.[contexttableid]  =wrk.[contexttableid],
		tgt.[correlationid]  =wrk.[correlationid],
		tgt.[document]  =wrk.[document],
		tgt.[documenttype]  =wrk.[documenttype],
		tgt.[originator]  =wrk.[originator],
		tgt.[owner]  =wrk.[owner],
		tgt.[parentcorrelationid]  =wrk.[parentcorrelationid],
		tgt.[rootcorrelationid]  =wrk.[rootcorrelationid],
		tgt.[subworkflowid]  =wrk.[subworkflowid],
		tgt.[workflowversiontable]  =wrk.[workflowversiontable],
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
	FROM [synapse_fo].[WORKFLOWTRACKINGSTATUSTABLE] tgt
		INNER JOIN [staging_fo].[WORKFLOWTRACKINGSTATUSTABLE] wrk
			ON wrk.[recid] = tgt.[recid]

END

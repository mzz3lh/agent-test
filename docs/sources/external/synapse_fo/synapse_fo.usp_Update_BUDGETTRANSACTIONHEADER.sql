CREATE   PROCEDURE [synapse_fo].[usp_Update_BUDGETTRANSACTIONHEADER]
AS
BEGIN
	--Raj Maddala, 2025-02-06, Update stored procedure for Budgettransactionheader

	UPDATE tgt SET
		tgt.[Id] = src.[Id],
		tgt.[SinkCreatedOn] = src.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = src.[SinkModifiedOn],
		tgt.[budgetmodeltype] = src.[budgetmodeltype],
		tgt.[budgettransactiontype] = src.[budgettransactiontype],
		tgt.[isonetimeamendment] = src.[isonetimeamendment],
		tgt.[transactionstatus] = src.[transactionstatus],
		tgt.[workflowstatus] = src.[workflowstatus],
		tgt.[sysdatastatecode] = src.[sysdatastatecode],
		tgt.[budgetmodeldataareaid] = src.[budgetmodeldataareaid],
		tgt.[budgetmodelid] = src.[budgetmodelid],
		tgt.[budgetsubmodelid] = src.[budgetsubmodelid],
		tgt.[budgettransactioncode] = src.[budgettransactioncode],
		tgt.[date] = src.[date],
		tgt.[inuseby] = src.[inuseby],
		tgt.[primaryledger] = src.[primaryledger],
		tgt.[reasontableref] = src.[reasontableref],
		tgt.[transactionnumber] = src.[transactionnumber],
		tgt.[transfersourcenumber] = src.[transfersourcenumber],
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
	FROM [synapse_fo].[BUDGETTRANSACTIONHEADER] tgt
		INNER JOIN [staging_fo].[BUDGETTRANSACTIONHEADER] src
			ON src.[recid] = tgt.[recid]

END

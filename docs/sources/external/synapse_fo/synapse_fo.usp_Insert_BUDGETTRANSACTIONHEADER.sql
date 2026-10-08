CREATE   PROCEDURE [synapse_fo].[usp_Insert_BUDGETTRANSACTIONHEADER]
AS
BEGIN
	--Raj Maddala, 2025-02-06, Insert stored procedure for Budgettransactionheader

	INSERT INTO [synapse_fo].[BUDGETTRANSACTIONHEADER]
	(
		[Id],
		[SinkCreatedOn],
		[SinkModifiedOn],
		[budgetmodeltype],
		[budgettransactiontype],
		[isonetimeamendment],
		[transactionstatus],
		[workflowstatus],
		[sysdatastatecode],
		[budgetmodeldataareaid],
		[budgetmodelid],
		[budgetsubmodelid],
		[budgettransactioncode],
		[date],
		[inuseby],
		[primaryledger],
		[reasontableref],
		[transactionnumber],
		[transfersourcenumber],
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
		src.[budgetmodeltype],
		src.[budgettransactiontype],
		src.[isonetimeamendment],
		src.[transactionstatus],
		src.[workflowstatus],
		src.[sysdatastatecode],
		src.[budgetmodeldataareaid],
		src.[budgetmodelid],
		src.[budgetsubmodelid],
		src.[budgettransactioncode],
		src.[date],
		src.[inuseby],
		src.[primaryledger],
		src.[reasontableref],
		src.[transactionnumber],
		src.[transfersourcenumber],
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
	FROM [staging_fo].[BUDGETTRANSACTIONHEADER] src
		LEFT JOIN [synapse_fo].[BUDGETTRANSACTIONHEADER] tgt
			ON src.[recid] = tgt.[recid]
	WHERE tgt.[recid] IS NULL

END

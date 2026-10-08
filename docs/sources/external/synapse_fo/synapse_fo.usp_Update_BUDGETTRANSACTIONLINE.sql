CREATE   PROCEDURE [synapse_fo].[usp_Update_BUDGETTRANSACTIONLINE]
AS
BEGIN
	--Raj Maddala, 2025-02-06, Update stored procedure for Budgettransactionline

	UPDATE tgt SET
		tgt.[Id] = src.[Id],
		tgt.[SinkCreatedOn] = src.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = src.[SinkModifiedOn],
		tgt.[budgettype] = src.[budgettype],
		tgt.[includeincashflowforecast] = src.[includeincashflowforecast],
		tgt.[workflowstatus] = src.[workflowstatus],
		tgt.[sysdatastatecode] = src.[sysdatastatecode],
		tgt.[accountingcurrencyamount] = src.[accountingcurrencyamount],
		tgt.[assetbudget] = src.[assetbudget],
		tgt.[budgettransactionheader] = src.[budgettransactionheader],
		tgt.[comment] = src.[comment],
		tgt.[date] = src.[date],
		tgt.[generaljournalentry] = src.[generaljournalentry],
		tgt.[ledgerdimension] = src.[ledgerdimension],
		tgt.[linenumber] = src.[linenumber],
		tgt.[price] = src.[price],
		tgt.[projtransbudgettransid] = src.[projtransbudgettransid],
		tgt.[quantity] = src.[quantity],
		tgt.[taxgroup] = src.[taxgroup],
		tgt.[transactioncurrency] = src.[transactioncurrency],
		tgt.[transactioncurrencyamount] = src.[transactioncurrencyamount],
		tgt.[assetbudget_ru] = src.[assetbudget_ru],
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
	FROM [synapse_fo].[BUDGETTRANSACTIONLINE] tgt
		INNER JOIN [staging_fo].[BUDGETTRANSACTIONLINE] src
			ON src.[recid] = tgt.[recid]

END

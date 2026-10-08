CREATE   VIEW [synapse_fo].[vwBudgetTransactionHeader]
AS
	SELECT 
		hdr.[recid]
		,hdr.[transactionnumber]
		,hdr.[createdon]
		,hdr.[createdby]
		,hdr.[modifiedon]
		,hdr.[modifiedby]
		,tc.[Name] AS [Budget Code]
		,tc.[Description] AS [Budget Type]
		--,enst.[MemberName] AS [Budget Status]
		,hdr.[budgetmodelid]
		,hdr.[budgetsubmodelid]
		,hdr.[date]
		,hdr.[primaryledger]
		,hdr.[dataareaid]
		,hdr.[budgetmodeltype]
		,hdr.[budgettransactiontype]
		,trantype.[membername] AS [{budgettransactiontypeName]
		,hdr.[transactionstatus]
		,enst.[membername] AS [transactionstatusName]
		,hdr.[workflowstatus]
		,reasonref.[ReasonComment] AS [Reason Comment]
		,reasonref.[Reason] AS [Reason Code]

	FROM [synapse_fo].[BUDGETTRANSACTIONHEADER] hdr
		LEFT JOIN [synapse_fo].[BUDGETTRANSACTIONCODE] tc
			ON hdr.[budgettransactioncode] = tc.[recid]
		LEFT JOIN [synapse_fo].[RetailEnumValueTable] enst
			ON hdr.[transactionstatus] = enst.Value
			AND enst.EnumName = 'BudgetTransactionStatus'
		LEFT JOIN [synapse_fo].[ReasonTableRef] reasonref
			ON hdr.ReasonTableRef = reasonref.RECID
		LEFT JOIN [synapse_fo].[RetailEnumValueTable] trantype
			ON hdr.[budgettransactiontype] = trantype.Value
			AND trantype.EnumName = 'BudgetTransactionType'

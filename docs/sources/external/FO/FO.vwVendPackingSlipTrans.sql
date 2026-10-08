CREATE    VIEW [FO].[vwVendPackingSlipTrans]
AS

	WITH cteJournal AS(
		SELECT packingslipid, purchid, orderaccount, dataareaid
		FROM synapse_fo.VENDPACKINGSLIPJOUR
		GROUP BY packingslipid, purchid, orderaccount, dataareaid
	)

	SELECT
		vpst.[AcceptedQty_IN],
		vpst.[AccountingDate],
		vpst.[CostLedgerVoucher],
		vpst.[CurrencyCode_W],
		--vpsj.[DeliveryDate],
		vpst.[DestCountryRegionId],
		vpst.[DestCounty],
		--vpsj.[DestState],
		vpst.[DeviationQty_RU],
		--vpsj.[DlvMode],
		vpst.[ExciseAmount_RU],
		vpst.[ExciseValue_RU],
		vpst.[ExternalItemId],
		IIF(vpst.[FullyMatched] =1,'Yes',NULL) AS [FullyMatched],
		vpst.[InterCompanyInventTransId],
		--vpst.[IntrastatCommodity],
		--vpst.[IntrastatDispatchId],
		--vpst.[IntrastatFulfillmentDate_HU],
		vpst.[InventDate],
		vpst.[InventDimId],
		vpst.[InventQty],
		vpst.[InventRefId],
		vpst.[InventRefTransId],
		vpst.[InventRefType],
		vpst.[InventTransId],
		vpst.[ItemId],
		vpst.[LineAmount_W],
		vpst.[LineNum],
		vpst.[Name],
		vpst.[NGPCodesTable_FR],
		--vpst.[NumberSequenceGroup],
		vpst.[Ordered],
		vpst.[OrigCountryRegionId],
		vpst.[OrigPurchid] AS [Purchase Order No],
		vpst.[OrigStateId],
		vpsj.[PackingSlipId],
		vpst.[PdsCWOrdered],
		vpst.[PdsCWQty],
		vpst.[PdsCWRemain],
		vpst.[Port],
		vpst.[PriceUnit],
		--vpst.[ProcurementCategory],
		cat.[NAME] AS [ProcurementCategory],
		vpst.[PurchaseLineExpectedDeliveryDate],
		vpst.[PurchaseLineLineNumber],
		vpst.[PurchUnit],
		vpst.[Qty],
		vpst.[ReceivedQty_IN],
		vpst.[RejectedQty_IN],
		vpst.[Remain],
		vpst.[ReturnActionId],
		vpst.[StatisticValue_LT],
		vpst.[StatProcId],
		vpst.[StockedProduct],
		vpst.[TaxAmount_RU],
		vpst.[TransactionCode],
		vpst.[Transport],
		vpst.[ValueMST],
		vpst.[VATAmount_RU],
		vpst.[VatValue_RU],
		vpst.[Weight],
		vpst.[WorkerPurchaser],
		vpst.[dataAreaId],
		--vpsj.[RecId] AS [Journal_RecId],
		vpst.[recid] AS [Trans_RecId],
		vpsj.[orderaccount] AS [VendAccount]

	FROM [synapse_fo].[VENDPACKINGSLIPTRANS] vpst
		LEFT JOIN cteJournal vpsj
			ON vpsj.PackingSlipId = vpst.PackingSlipId
			AND vpsj.PurchId = vpst.origpurchid
			AND vpsj.DataAreaId = vpst.DataAreaId
		LEFT JOIN synapse_fo.ECORESCATEGORY cat
			ON vpst.[procurementcategory] = cat.[RECID]
--	WHERE vpst.[recid] = 0000000000

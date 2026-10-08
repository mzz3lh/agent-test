CREATE       PROCEDURE [synapse_fo].[usp_Update_SubBillDeferralScheduleTable]
AS
/*
	Created by: Raj Maddala
	Created on: 2024-04-24 15:00:00
	Description: Update stored procedure for SubBillDeferralScheduleTable from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[SubBillDeferralConsolidatePriorPeriods] = stg.[SubBillDeferralConsolidatePriorPeriods],
		tgt.[SubBillDeferralAccount] = stg.[SubBillDeferralAccount],
		tgt.[SubBillDeferralAmount] = stg.[SubBillDeferralAmount],
		tgt.[SubBillDeferralEqualPerPeriod] = stg.[SubBillDeferralEqualPerPeriod],
		tgt.[SubBillDeferralEventAllocationType] = stg.[SubBillDeferralEventAllocationType],
		tgt.[SubBillDeferralEventPerUnit] = stg.[SubBillDeferralEventPerUnit],
		tgt.[SubBillDeferralEventTemplateId] = stg.[SubBillDeferralEventTemplateId],
		tgt.[SubBillDeferralExpirationAccount] = stg.[SubBillDeferralExpirationAccount],
		tgt.[SubBillDeferralOnHoldAccount] = stg.[SubBillDeferralOnHoldAccount],
		tgt.[SubBillDeferralOnHoldTransferred] = stg.[SubBillDeferralOnHoldTransferred],
		tgt.[SubBillDeferralRecognitionAccount] = stg.[SubBillDeferralRecognitionAccount],
		tgt.[SubBillDeferralRecognitionType] = stg.[SubBillDeferralRecognitionType],
		tgt.[SubBillDeferralScheduleCreationSource] = stg.[SubBillDeferralScheduleCreationSource],
		tgt.[SubBillDeferralScheduleNumber] = stg.[SubBillDeferralScheduleNumber],
		tgt.[SubBillDeferralScheduleStatus] = stg.[SubBillDeferralScheduleStatus],
		tgt.[SubBillDeferralScheduleType] = stg.[SubBillDeferralScheduleType],
		tgt.[SubBillDeferralSourceRecType] = stg.[SubBillDeferralSourceRecType],
		tgt.[SubBillDeferralTransactionType] = stg.[SubBillDeferralTransactionType],
		tgt.[Description] = stg.[Description],
		tgt.[SourceRecId] = stg.[SourceRecId],
		tgt.[SourceTransLineDefRecId] = stg.[SourceTransLineDefRecId],
		tgt.[TransDate] = stg.[TransDate],
		tgt.[SubBillDeferralDistributionType] = stg.[SubBillDeferralDistributionType],
		tgt.[SubBillScheduleDtlRecId] = stg.[SubBillScheduleDtlRecId],
		tgt.[SubBillDeferralShortTermAmount] = stg.[SubBillDeferralShortTermAmount],
		tgt.[SubBillDeferralShortTermAccount] = stg.[SubBillDeferralShortTermAccount],
		tgt.[SubBillDeferralOriginalScheduleAmount] = stg.[SubBillDeferralOriginalScheduleAmount],
		tgt.[SubBillDeferralOriginalStartDate] = stg.[SubBillDeferralOriginalStartDate],
		tgt.[SubBillDeferralOriginalEndDate] = stg.[SubBillDeferralOriginalEndDate],
		tgt.[SubBillDeferralReclassificationDate] = stg.[SubBillDeferralReclassificationDate],
		tgt.[SubBillDeferralInitialRecAcct] = stg.[SubBillDeferralInitialRecAcct],
		tgt.[SubBillDeferralRecOffAcct] = stg.[SubBillDeferralRecOffAcct],
		tgt.[ExternalItemId] = stg.[ExternalItemId],
		tgt.[CustomerLineNum] = stg.[CustomerLineNum],
		tgt.[CustInvoiceAccount] = stg.[CustInvoiceAccount],
		tgt.[InvoiceId] = stg.[InvoiceId],
		tgt.[ItemId] = stg.[ItemId],
		tgt.[SalesId] = stg.[SalesId],
		tgt.[DataAreaId] = stg.[DataAreaId],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[ProjTransId] = stg.[ProjTransId],
		tgt.[ProjFundingSource] = stg.[ProjFundingSource]
	 FROM [synapse_fo].[SubBillDeferralScheduleTable] tgt
		INNER JOIN [staging_fo].[SubBillDeferralScheduleTable] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

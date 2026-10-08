CREATE       PROCEDURE [synapse_fo].[usp_Update_SubBillDeferralScheduleLine]
AS
/*
	Created by: Raj Maddala
	Created on: 2024-04-24 15:00:00
	Description: Update stored procedure for SubBillDeferralScheduleLine from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[Amount] = stg.[Amount],
		tgt.[SubBillDeferralEndDate] = stg.[SubBillDeferralEndDate],
		tgt.[SubBillDeferralStartDate] = stg.[SubBillDeferralStartDate],
		tgt.[SubBillDeferralEventDescription] = stg.[SubBillDeferralEventDescription],
		tgt.[SubBillDeferralRecognitionAccount] = stg.[SubBillDeferralRecognitionAccount],
		tgt.[SubBillDeferralRecognized] = stg.[SubBillDeferralRecognized],
		tgt.[SubBillDeferralRecognizeOnPost] = stg.[SubBillDeferralRecognizeOnPost],
		tgt.[SubBillDeferralScheduleNumber] = stg.[SubBillDeferralScheduleNumber],
		tgt.[SubBillDeferralStubbed] = stg.[SubBillDeferralStubbed],
		tgt.[ExpirationDate] = stg.[ExpirationDate],
		tgt.[Line] = stg.[Line],
		tgt.[RecognitionLedgerJournalTrans] = stg.[RecognitionLedgerJournalTrans],
		tgt.[SubBillDeferralIsAdjustment] = stg.[SubBillDeferralIsAdjustment],
		tgt.[SubBillDeferralQty] = stg.[SubBillDeferralQty],
		tgt.[SubBillCustInvoiceTransRecId] = stg.[SubBillCustInvoiceTransRecId],
		tgt.[DataAreaId] = stg.[DataAreaId],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[CREATEDBY] = stg.[CREATEDBY]
	 FROM [synapse_fo].[SubBillDeferralScheduleLine] tgt
		INNER JOIN [staging_fo].[SubBillDeferralScheduleLine] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

CREATE       PROCEDURE [synapse_fo].[usp_Insert_SubBillDeferralScheduleLine]
AS
/*
	Created by: Raj Maddala
	Created on: 2024-04-24 15:00:00
	Description: Insert stored procedure for SubBillDeferralScheduleLine from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[SubBillDeferralScheduleLine]
	(
		[$FileName],
		[_SysRowId],
		--[LSN],
		[LastProcessedChange_DateTime],
		[DataLakeModified_DateTime],
		[RECID],
		[Amount],
		[SubBillDeferralEndDate],
		[SubBillDeferralStartDate],
		[SubBillDeferralEventDescription],
		[SubBillDeferralRecognitionAccount],
		[SubBillDeferralRecognized],
		[SubBillDeferralRecognizeOnPost],
		[SubBillDeferralScheduleNumber],
		[SubBillDeferralStubbed],
		[ExpirationDate],
		[Line],
		[RecognitionLedgerJournalTrans],
		[SubBillDeferralIsAdjustment],
		[SubBillDeferralQty],
		[SubBillCustInvoiceTransRecId],
		[DataAreaId],
		[PARTITION],
		[RECVERSION],
		[CREATEDBY]
	)
	SELECT 
		stg.[$FileName],
		stg.[_SysRowId],
		--stg.--[LSN],
		stg.[LastProcessedChange_DateTime],
		stg.[DataLakeModified_DateTime],
		stg.[RECID],
		stg.[Amount],
		stg.[SubBillDeferralEndDate],
		stg.[SubBillDeferralStartDate],
		stg.[SubBillDeferralEventDescription],
		stg.[SubBillDeferralRecognitionAccount],
		stg.[SubBillDeferralRecognized],
		stg.[SubBillDeferralRecognizeOnPost],
		stg.[SubBillDeferralScheduleNumber],
		stg.[SubBillDeferralStubbed],
		stg.[ExpirationDate],
		stg.[Line],
		stg.[RecognitionLedgerJournalTrans],
		stg.[SubBillDeferralIsAdjustment],
		stg.[SubBillDeferralQty],
		stg.[SubBillCustInvoiceTransRecId],
		stg.[DataAreaId],
		stg.[PARTITION],
		stg.[RECVERSION],
		stg.[CREATEDBY]
	FROM [staging_fo].[SubBillDeferralScheduleLine] stg
		LEFT JOIN [synapse_fo].[SubBillDeferralScheduleLine] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL

END

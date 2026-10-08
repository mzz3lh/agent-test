CREATE PROCEDURE [synapse_fo].[usp_Update_SubBillDeferralScheduleTableImport]
AS
/*
	Created by: Raj Maddala
	Created on: 2024-04-24 15:00:00
	Description: Update stored procedure for SubBillDeferralScheduleTableImport from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[SubBillDeferralScheduleNumber] = stg.[SubBillDeferralScheduleNumber],
		tgt.[CustAccount] = stg.[CustAccount],
		tgt.[VendAccount] = stg.[VendAccount],
		tgt.[ItemId] = stg.[ItemId],
		tgt.[SubBillDeferralOriginalTransactionRef] = stg.[SubBillDeferralOriginalTransactionRef],
		tgt.[SubBillBillingScheduleNumber] = stg.[SubBillBillingScheduleNumber],
		tgt.[DataAreaId] = stg.[DataAreaId],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECVERSION] = stg.[RECVERSION]
	 FROM [synapse_fo].[SubBillDeferralScheduleTableImport] tgt
		INNER JOIN [staging_fo].[SubBillDeferralScheduleTableImport] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

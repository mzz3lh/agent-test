CREATE PROCEDURE [synapse_fo].[usp_Insert_SubBillDeferralScheduleTableImport]
AS
/*
	Created by: Raj Maddala
	Created on: 2024-04-24 15:00:00
	Description: Insert stored procedure for SubBillDeferralScheduleTableImport from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[SubBillDeferralScheduleTableImport]
	(
		[$FileName],
		[_SysRowId],
		[LSN],
		[LastProcessedChange_DateTime],
		[DataLakeModified_DateTime],
		[RECID],
		[SubBillDeferralScheduleNumber],
		[CustAccount],
		[VendAccount],
		[ItemId],
		[SubBillDeferralOriginalTransactionRef],
		[SubBillBillingScheduleNumber],
		[DataAreaId],
		[PARTITION],
		[RECVERSION]
	)
	SELECT 
		stg.[$FileName],
		stg.[_SysRowId],
		stg.[LSN],
		stg.[LastProcessedChange_DateTime],
		stg.[DataLakeModified_DateTime],
		stg.[RECID],
		stg.[SubBillDeferralScheduleNumber],
		stg.[CustAccount],
		stg.[VendAccount],
		stg.[ItemId],
		stg.[SubBillDeferralOriginalTransactionRef],
		stg.[SubBillBillingScheduleNumber],
		stg.[DataAreaId],
		stg.[PARTITION],
		stg.[RECVERSION]
	FROM [staging_fo].[SubBillDeferralScheduleTableImport] stg
		LEFT JOIN [synapse_fo].[SubBillDeferralScheduleTableImport] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL

END

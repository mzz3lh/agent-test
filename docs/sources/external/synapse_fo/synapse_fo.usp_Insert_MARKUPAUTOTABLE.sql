CREATE     PROCEDURE [synapse_fo].[usp_Insert_MARKUPAUTOTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:54
	Description: Insert stored procedure for MARKUPAUTOTABLE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[MARKUPAUTOTABLE]
	(
		[ACCOUNTCODE],
		[ACCOUNTRELATION],
		[AUTOCHARGESCONCURRENCYMODE],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		[DLVMODECODE],
		[DLVMODERELATION],
		[FileName],
		[ISGUPMARKUPAUTO],
		[ITEMCODE],
		[ITEMRELATION],
		[LastProcessedChange_DateTime],
		[LSN],
		[MARKUPRETURN],
		[MODULECATEGORY],
		[MODULETYPE],
		[PARTITION],
		[PRICEATTRIBUTEGROUPCOMBINATIONRECID],
		[PRICECOMPONENTCODENAME],
		[PRICECOMPONENTTYPE],
		[PRICINGGROUPCODEHEADER],
		[PRICINGGROUPCODELINE],
		[PRICINGRULEHEADER],
		[PRICINGRULELINE],
		[RECID],
		[RECVERSION],
		[RETAILADVANCEDCHARGESDELIVERYPRORATE],
		[RETAILCHANNELCODE],
		[RETAILCHANNELRELATION],
		[RETAILCONCESSIONFEELEGACY],
		[RETURNRELATION],
		[SHA256HASH],
		[SysRowId]
	)
	SELECT 
		stg.[ACCOUNTCODE],
		stg.[ACCOUNTRELATION],
		stg.[AUTOCHARGESCONCURRENCYMODE],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		stg.[DLVMODECODE],
		stg.[DLVMODERELATION],
		stg.[FileName],
		stg.[ISGUPMARKUPAUTO],
		stg.[ITEMCODE],
		stg.[ITEMRELATION],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[MARKUPRETURN],
		stg.[MODULECATEGORY],
		stg.[MODULETYPE],
		stg.[PARTITION],
		stg.[PRICEATTRIBUTEGROUPCOMBINATIONRECID],
		stg.[PRICECOMPONENTCODENAME],
		stg.[PRICECOMPONENTTYPE],
		stg.[PRICINGGROUPCODEHEADER],
		stg.[PRICINGGROUPCODELINE],
		stg.[PRICINGRULEHEADER],
		stg.[PRICINGRULELINE],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[RETAILADVANCEDCHARGESDELIVERYPRORATE],
		stg.[RETAILCHANNELCODE],
		stg.[RETAILCHANNELRELATION],
		stg.[RETAILCONCESSIONFEELEGACY],
		stg.[RETURNRELATION],
		stg.[SHA256HASH],
		stg.[SysRowId]	
	FROM [staging_fo].[MARKUPAUTOTABLE] stg
		LEFT JOIN [synapse_fo].[MARKUPAUTOTABLE] tgt
			ON stg.[AccountCode] = tgt.[AccountCode] 
			AND stg.[AccountRelation] = tgt.[AccountRelation] 
			AND stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[DlvModeCode] = tgt.[DlvModeCode] 
			AND stg.[DlvModeRelation] = tgt.[DlvModeRelation] 
			AND stg.[ItemCode] = tgt.[ItemCode] 
			AND stg.[ItemRelation] = tgt.[ItemRelation] 
			AND stg.[MarkupReturn] = tgt.[MarkupReturn] 
			AND stg.[ModuleCategory] = tgt.[ModuleCategory] 
			AND stg.[ModuleType] = tgt.[ModuleType] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
			AND stg.[RetailChannelCode] = tgt.[RetailChannelCode] 
			AND stg.[RetailChannelRelation] = tgt.[RetailChannelRelation] 
			AND stg.[ReturnRelation] = tgt.[ReturnRelation] 
			AND stg.[SHA256Hash] = tgt.[SHA256Hash] 
		
	WHERE tgt.[RECID] IS NULL
END

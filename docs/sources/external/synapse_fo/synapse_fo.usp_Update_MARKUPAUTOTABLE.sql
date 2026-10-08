CREATE     PROCEDURE [synapse_fo].[usp_Update_MARKUPAUTOTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:47
	Description: Update stored procedure for MARKUPAUTOTABLE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[ACCOUNTCODE] = stg.[ACCOUNTCODE],
		tgt.[ACCOUNTRELATION] = stg.[ACCOUNTRELATION],
		tgt.[AUTOCHARGESCONCURRENCYMODE] = stg.[AUTOCHARGESCONCURRENCYMODE],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		tgt.[DLVMODECODE] = stg.[DLVMODECODE],
		tgt.[DLVMODERELATION] = stg.[DLVMODERELATION],
		tgt.[FileName] = stg.[FileName],
		tgt.[ISGUPMARKUPAUTO] = stg.[ISGUPMARKUPAUTO],
		tgt.[ITEMCODE] = stg.[ITEMCODE],
		tgt.[ITEMRELATION] = stg.[ITEMRELATION],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[MARKUPRETURN] = stg.[MARKUPRETURN],
		tgt.[MODULECATEGORY] = stg.[MODULECATEGORY],
		tgt.[MODULETYPE] = stg.[MODULETYPE],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PRICEATTRIBUTEGROUPCOMBINATIONRECID] = stg.[PRICEATTRIBUTEGROUPCOMBINATIONRECID],
		tgt.[PRICECOMPONENTCODENAME] = stg.[PRICECOMPONENTCODENAME],
		tgt.[PRICECOMPONENTTYPE] = stg.[PRICECOMPONENTTYPE],
		tgt.[PRICINGGROUPCODEHEADER] = stg.[PRICINGGROUPCODEHEADER],
		tgt.[PRICINGGROUPCODELINE] = stg.[PRICINGGROUPCODELINE],
		tgt.[PRICINGRULEHEADER] = stg.[PRICINGRULEHEADER],
		tgt.[PRICINGRULELINE] = stg.[PRICINGRULELINE],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[RETAILADVANCEDCHARGESDELIVERYPRORATE] = stg.[RETAILADVANCEDCHARGESDELIVERYPRORATE],
		tgt.[RETAILCHANNELCODE] = stg.[RETAILCHANNELCODE],
		tgt.[RETAILCHANNELRELATION] = stg.[RETAILCHANNELRELATION],
		tgt.[RETAILCONCESSIONFEELEGACY] = stg.[RETAILCONCESSIONFEELEGACY],
		tgt.[RETURNRELATION] = stg.[RETURNRELATION],
		tgt.[SHA256HASH] = stg.[SHA256HASH],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[MARKUPAUTOTABLE] tgt
		INNER JOIN [staging_fo].[MARKUPAUTOTABLE] stg
			ON  stg.[AccountCode] = tgt.[AccountCode] 
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
		
END

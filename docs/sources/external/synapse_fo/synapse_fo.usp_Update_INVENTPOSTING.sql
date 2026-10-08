CREATE     PROCEDURE [synapse_fo].[usp_Update_INVENTPOSTING]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:43
	Description: Update stored procedure for INVENTPOSTING from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CATEGORYRELATION] = stg.[CATEGORYRELATION],
		tgt.[COSTCODE] = stg.[COSTCODE],
		tgt.[COSTRELATION] = stg.[COSTRELATION],
		tgt.[CUSTVENDCODE] = stg.[CUSTVENDCODE],
		tgt.[CUSTVENDRELATION] = stg.[CUSTVENDRELATION],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[INVENTACCOUNTTYPE] = stg.[INVENTACCOUNTTYPE],
		tgt.[INVENTPROFILEID_RU] = stg.[INVENTPROFILEID_RU],
		tgt.[INVENTPROFILETYPE_RU] = stg.[INVENTPROFILETYPE_RU],
		tgt.[INVENTPROFILETYPEALL_RU] = stg.[INVENTPROFILETYPEALL_RU],
		tgt.[ITEMCODE] = stg.[ITEMCODE],
		tgt.[ITEMRELATION] = stg.[ITEMRELATION],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LEDGERDIMENSION] = stg.[LEDGERDIMENSION],
		--tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SHA256HASH] = stg.[SHA256HASH],
		tgt.[SITECODE_CN] = stg.[SITECODE_CN],
		tgt.[SITERELATION_CN] = stg.[SITERELATION_CN],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TAXGROUPID] = stg.[TAXGROUPID]
	 FROM [synapse_fo].[INVENTPOSTING] tgt
		INNER JOIN [staging_fo].[INVENTPOSTING] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

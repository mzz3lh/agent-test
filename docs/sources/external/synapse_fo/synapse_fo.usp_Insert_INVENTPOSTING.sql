CREATE     PROCEDURE [synapse_fo].[usp_Insert_INVENTPOSTING]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:51
	Description: Insert stored procedure for INVENTPOSTING from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[INVENTPOSTING]
	(
		[CATEGORYRELATION],
		[COSTCODE],
		[COSTRELATION],
		[CUSTVENDCODE],
		[CUSTVENDRELATION],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		--[FileName],
		[INVENTACCOUNTTYPE],
		[INVENTPROFILEID_RU],
		[INVENTPROFILETYPE_RU],
		[INVENTPROFILETYPEALL_RU],
		[ITEMCODE],
		[ITEMRELATION],
		[LastProcessedChange_DateTime],
		[LEDGERDIMENSION],
		--[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SHA256HASH],
		[SITECODE_CN],
		[SITERELATION_CN],
		--[SysRowId],
		[TAXGROUPID]
	)
	SELECT 
		stg.[CATEGORYRELATION],
		stg.[COSTCODE],
		stg.[COSTRELATION],
		stg.[CUSTVENDCODE],
		stg.[CUSTVENDRELATION],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[INVENTACCOUNTTYPE],
		stg.[INVENTPROFILEID_RU],
		stg.[INVENTPROFILETYPE_RU],
		stg.[INVENTPROFILETYPEALL_RU],
		stg.[ITEMCODE],
		stg.[ITEMRELATION],
		stg.[LastProcessedChange_DateTime],
		stg.[LEDGERDIMENSION],
		--stg.--[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SHA256HASH],
		stg.[SITECODE_CN],
		stg.[SITERELATION_CN],
		--stg.--[SysRowId],
		stg.[TAXGROUPID]	
	FROM [staging_fo].[INVENTPOSTING] stg
		LEFT JOIN [synapse_fo].[INVENTPOSTING] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

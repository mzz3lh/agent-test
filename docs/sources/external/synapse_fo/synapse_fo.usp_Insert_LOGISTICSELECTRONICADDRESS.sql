CREATE     PROCEDURE [synapse_fo].[usp_Insert_LOGISTICSELECTRONICADDRESS]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:53
	Description: Insert stored procedure for LOGISTICSELECTRONICADDRESS from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[LOGISTICSELECTRONICADDRESS]
	(
		[CHANNELREFERENCEID],
		[COUNTRYREGIONCODE],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		[ELECTRONICADDRESSID],
		[ELECTRONICADDRESSROLES],
		--[FileName],
		[ISINSTANTMESSAGE],
		[ISMOBILEPHONE],
		[ISPRIMARY],
		[ISPRIVATE],
		[LastProcessedChange_DateTime],
		[LOCATION],
		[LOCATOR],
		[LOCATOREXTENSION],
		--[LSN],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[PARTITION],
		[PRIVATEFORPARTY],
		[RECID],
		[RECVERSION],
		[RETAILMARKETINGOPTIN],
		--[SysRowId],
		[TYPE]
	)
	SELECT 
		stg.[CHANNELREFERENCEID],
		stg.[COUNTRYREGIONCODE],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		stg.[ELECTRONICADDRESSID],
		stg.[ELECTRONICADDRESSROLES],
		--stg.--[FileName],
		stg.[ISINSTANTMESSAGE],
		stg.[ISMOBILEPHONE],
		stg.[ISPRIMARY],
		stg.[ISPRIVATE],
		stg.[LastProcessedChange_DateTime],
		stg.[LOCATION],
		stg.[LOCATOR],
		stg.[LOCATOREXTENSION],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[PARTITION],
		stg.[PRIVATEFORPARTY],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[RETAILMARKETINGOPTIN],
		--stg.--[SysRowId],
		stg.[TYPE]	
	FROM [staging_fo].[LOGISTICSELECTRONICADDRESS] stg
		LEFT JOIN [synapse_fo].[LOGISTICSELECTRONICADDRESS] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

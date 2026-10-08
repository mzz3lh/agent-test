CREATE     PROCEDURE [synapse_fo].[usp_Update_LOGISTICSELECTRONICADDRESS]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:45
	Description: Update stored procedure for LOGISTICSELECTRONICADDRESS from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CHANNELREFERENCEID] = stg.[CHANNELREFERENCEID],
		tgt.[COUNTRYREGIONCODE] = stg.[COUNTRYREGIONCODE],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		tgt.[ELECTRONICADDRESSID] = stg.[ELECTRONICADDRESSID],
		tgt.[ELECTRONICADDRESSROLES] = stg.[ELECTRONICADDRESSROLES],
		--tgt.[FileName] = stg.[FileName],
		tgt.[ISINSTANTMESSAGE] = stg.[ISINSTANTMESSAGE],
		tgt.[ISMOBILEPHONE] = stg.[ISMOBILEPHONE],
		tgt.[ISPRIMARY] = stg.[ISPRIMARY],
		tgt.[ISPRIVATE] = stg.[ISPRIVATE],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LOCATION] = stg.[LOCATION],
		tgt.[LOCATOR] = stg.[LOCATOR],
		tgt.[LOCATOREXTENSION] = stg.[LOCATOREXTENSION],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PRIVATEFORPARTY] = stg.[PRIVATEFORPARTY],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[RETAILMARKETINGOPTIN] = stg.[RETAILMARKETINGOPTIN],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TYPE] = stg.[TYPE]
	 FROM [synapse_fo].[LOGISTICSELECTRONICADDRESS] tgt
		INNER JOIN [staging_fo].[LOGISTICSELECTRONICADDRESS] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

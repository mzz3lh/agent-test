CREATE     PROCEDURE [synapse_fo].[usp_Update_LOGISTICSPOSTALADDRESS]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:46
	Description: Update stored procedure for LOGISTICSPOSTALADDRESS from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[ADDRESS] = stg.[ADDRESS],
		tgt.[APARTMENT_RU] = stg.[APARTMENT_RU],
		tgt.[BUILDING_RU] = stg.[BUILDING_RU],
		tgt.[BUILDINGCOMPLIMENT] = stg.[BUILDINGCOMPLIMENT],
		tgt.[CHANNELREFERENCEID] = stg.[CHANNELREFERENCEID],
		tgt.[CITY] = stg.[CITY],
		tgt.[CITYKANA_JP] = stg.[CITYKANA_JP],
		tgt.[CITYRECID] = stg.[CITYRECID],
		tgt.[COUNTRYREGIONID] = stg.[COUNTRYREGIONID],
		tgt.[COUNTY] = stg.[COUNTY],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DISTRICT] = stg.[DISTRICT],
		tgt.[DISTRICTNAME] = stg.[DISTRICTNAME],
		--tgt.[FileName] = stg.[FileName],
		tgt.[FLATID_RU] = stg.[FLATID_RU],
		tgt.[HOUSEID_RU] = stg.[HOUSEID_RU],
		tgt.[ISPRIVATE] = stg.[ISPRIVATE],
		tgt.[ISSIMPLIFIEDADDRESS_RU] = stg.[ISSIMPLIFIEDADDRESS_RU],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LATITUDE] = stg.[LATITUDE],
		tgt.[LOCALITYRECID] = stg.[LOCALITYRECID],
		tgt.[LOCATION] = stg.[LOCATION],
		tgt.[LONGITUDE] = stg.[LONGITUDE],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[POSTBOX] = stg.[POSTBOX],
		tgt.[PRIVATEFORPARTY] = stg.[PRIVATEFORPARTY],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SETTLEMENTRECID] = stg.[SETTLEMENTRECID],
		tgt.[STATE] = stg.[STATE],
		tgt.[STEADID_RU] = stg.[STEADID_RU],
		tgt.[STREET] = stg.[STREET],
		tgt.[STREETID_RU] = stg.[STREETID_RU],
		tgt.[STREETKANA_JP] = stg.[STREETKANA_JP],
		tgt.[STREETNUMBER] = stg.[STREETNUMBER],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TIMEZONE] = stg.[TIMEZONE],
		tgt.[VALIDFROM] = stg.[VALIDFROM],
		--tgt.[VALIDFROMTZID] = stg.[VALIDFROMTZID],
		tgt.[VALIDTO] = stg.[VALIDTO],
		--tgt.[VALIDTOTZID] = stg.[VALIDTOTZID],
		tgt.[ZIPCODE] = stg.[ZIPCODE],
		tgt.[ZIPCODERECID] = stg.[ZIPCODERECID]
	 FROM [synapse_fo].[LOGISTICSPOSTALADDRESS] tgt
		INNER JOIN [staging_fo].[LOGISTICSPOSTALADDRESS] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

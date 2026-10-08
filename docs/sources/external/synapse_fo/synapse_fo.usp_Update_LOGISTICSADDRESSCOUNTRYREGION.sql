CREATE     PROCEDURE [synapse_fo].[usp_Update_LOGISTICSADDRESSCOUNTRYREGION]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:45
	Description: Update stored procedure for LOGISTICSADDRESSCOUNTRYREGION from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[ADDRESSUSEZIPPLUS4] = stg.[ADDRESSUSEZIPPLUS4],
		tgt.[ADDRFORMAT] = stg.[ADDRFORMAT],
		tgt.[BACENCODE_BR] = stg.[BACENCODE_BR],
		tgt.[COUNTRYREGIONID] = stg.[COUNTRYREGIONID],
		tgt.[CURRENCYCODE] = stg.[CURRENCYCODE],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[ISIMMUTABLE] = stg.[ISIMMUTABLE],
		tgt.[ISOCODE] = stg.[ISOCODE],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MCRIOR_FACILITY_ID] = stg.[MCRIOR_FACILITY_ID],
		tgt.[MEMBEROFCUSTOMSUNION_RU] = stg.[MEMBEROFCUSTOMSUNION_RU],
		tgt.[OKSMCODE_RU] = stg.[OKSMCODE_RU],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[RPAYPARENTCOUNTRYREGIONID] = stg.[RPAYPARENTCOUNTRYREGIONID],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TIMEZONE] = stg.[TIMEZONE]
	 FROM [synapse_fo].[LOGISTICSADDRESSCOUNTRYREGION] tgt
		INNER JOIN [staging_fo].[LOGISTICSADDRESSCOUNTRYREGION] stg
			ON  stg.[CountryRegionId] = tgt.[CountryRegionId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
END

CREATE     PROCEDURE [synapse_fo].[usp_Insert_LOGISTICSADDRESSCOUNTRYREGION]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:53
	Description: Insert stored procedure for LOGISTICSADDRESSCOUNTRYREGION from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[LOGISTICSADDRESSCOUNTRYREGION]
	(
		[ADDRESSUSEZIPPLUS4],
		[ADDRFORMAT],
		[BACENCODE_BR],
		[COUNTRYREGIONID],
		[CURRENCYCODE],
		[DataLakeModified_DateTime],
		--[FileName],
		[ISIMMUTABLE],
		[ISOCODE],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MCRIOR_FACILITY_ID],
		[MEMBEROFCUSTOMSUNION_RU],
		[OKSMCODE_RU],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[RPAYPARENTCOUNTRYREGIONID],
		--[SysRowId],
		[TIMEZONE]
	)
	SELECT 
		stg.[ADDRESSUSEZIPPLUS4],
		stg.[ADDRFORMAT],
		stg.[BACENCODE_BR],
		stg.[COUNTRYREGIONID],
		stg.[CURRENCYCODE],
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[ISIMMUTABLE],
		stg.[ISOCODE],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MCRIOR_FACILITY_ID],
		stg.[MEMBEROFCUSTOMSUNION_RU],
		stg.[OKSMCODE_RU],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[RPAYPARENTCOUNTRYREGIONID],
		--stg.--[SysRowId],
		stg.[TIMEZONE]	
	FROM [staging_fo].[LOGISTICSADDRESSCOUNTRYREGION] stg
		LEFT JOIN [synapse_fo].[LOGISTICSADDRESSCOUNTRYREGION] tgt
			ON stg.[CountryRegionId] = tgt.[CountryRegionId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
	WHERE tgt.[RECID] IS NULL
END

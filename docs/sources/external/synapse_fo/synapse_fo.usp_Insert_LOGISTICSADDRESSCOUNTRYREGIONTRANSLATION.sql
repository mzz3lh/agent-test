CREATE     PROCEDURE [synapse_fo].[usp_Insert_LOGISTICSADDRESSCOUNTRYREGIONTRANSLATION]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:53
	Description: Insert stored procedure for LOGISTICSADDRESSCOUNTRYREGIONTRANSLATION from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[LOGISTICSADDRESSCOUNTRYREGIONTRANSLATION]
	(
		[COUNTRYREGIONID],
		[DataLakeModified_DateTime],
		--[FileName],
		[LANGUAGEID],
		[LastProcessedChange_DateTime],
		[LONGNAME],
		--[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SHORTNAME]
		--[SysRowId]
	)
	SELECT 
		stg.[COUNTRYREGIONID],
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[LANGUAGEID],
		stg.[LastProcessedChange_DateTime],
		stg.[LONGNAME],
		--stg.--[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SHORTNAME]
		--stg.--[SysRowId]	
	FROM [staging_fo].[LOGISTICSADDRESSCOUNTRYREGIONTRANSLATION] stg
		LEFT JOIN [synapse_fo].[LOGISTICSADDRESSCOUNTRYREGIONTRANSLATION] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

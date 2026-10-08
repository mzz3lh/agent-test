CREATE     PROCEDURE [synapse_fo].[usp_Update_LOGISTICSADDRESSCOUNTRYREGIONTRANSLATION]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:45
	Description: Update stored procedure for LOGISTICSADDRESSCOUNTRYREGIONTRANSLATION from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[COUNTRYREGIONID] = stg.[COUNTRYREGIONID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LANGUAGEID] = stg.[LANGUAGEID],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LONGNAME] = stg.[LONGNAME],
		--tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SHORTNAME] = stg.[SHORTNAME]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[LOGISTICSADDRESSCOUNTRYREGIONTRANSLATION] tgt
		INNER JOIN [staging_fo].[LOGISTICSADDRESSCOUNTRYREGIONTRANSLATION] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

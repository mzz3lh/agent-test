CREATE     PROCEDURE [synapse_fo].[usp_Update_HSNCODETABLE_IN]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:42
	Description: Update stored procedure for HSNCODETABLE_IN from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CHAPTER] = stg.[CHAPTER],
		tgt.[CODE] = stg.[CODE],
		tgt.[COUNTRYEXTENSION] = stg.[COUNTRYEXTENSION],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		tgt.[FileName] = stg.[FileName],
		tgt.[HEADING] = stg.[HEADING],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[STATISTICALSUFFIX] = stg.[STATISTICALSUFFIX],
		tgt.[SUBHEADING] = stg.[SUBHEADING],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[HSNCODETABLE_IN] tgt
		INNER JOIN [staging_fo].[HSNCODETABLE_IN] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

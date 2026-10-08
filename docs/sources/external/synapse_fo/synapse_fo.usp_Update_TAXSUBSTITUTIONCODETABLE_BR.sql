CREATE     PROCEDURE [synapse_fo].[usp_Update_TAXSUBSTITUTIONCODETABLE_BR]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:53
	Description: Update stored procedure for TAXSUBSTITUTIONCODETABLE_BR from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[FileName] = stg.[FileName],
		tgt.[ITEMID] = stg.[ITEMID],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TAXFISCALCLASSIFICATION] = stg.[TAXFISCALCLASSIFICATION],
		tgt.[TAXSUBSTITUTIONCODE] = stg.[TAXSUBSTITUTIONCODE]
	 FROM [synapse_fo].[TAXSUBSTITUTIONCODETABLE_BR] tgt
		INNER JOIN [staging_fo].[TAXSUBSTITUTIONCODETABLE_BR] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

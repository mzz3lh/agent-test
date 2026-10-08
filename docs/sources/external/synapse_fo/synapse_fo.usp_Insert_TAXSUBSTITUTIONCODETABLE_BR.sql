CREATE     PROCEDURE [synapse_fo].[usp_Insert_TAXSUBSTITUTIONCODETABLE_BR]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:01
	Description: Insert stored procedure for TAXSUBSTITUTIONCODETABLE_BR from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[TAXSUBSTITUTIONCODETABLE_BR]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[FileName],
		[ITEMID],
		[LastProcessedChange_DateTime],
		[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SysRowId],
		[TAXFISCALCLASSIFICATION],
		[TAXSUBSTITUTIONCODE]
	)
	SELECT 
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[FileName],
		stg.[ITEMID],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId],
		stg.[TAXFISCALCLASSIFICATION],
		stg.[TAXSUBSTITUTIONCODE]	
	FROM [staging_fo].[TAXSUBSTITUTIONCODETABLE_BR] stg
		LEFT JOIN [synapse_fo].[TAXSUBSTITUTIONCODETABLE_BR] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

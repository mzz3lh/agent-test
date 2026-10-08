CREATE      PROCEDURE [synapse_fo].[usp_Insert_ECORESPRODUCTTRANSLATION]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:47
	Description: Insert stored procedure for ECORESPRODUCTTRANSLATION from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[ECORESPRODUCTTRANSLATION]
	(
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		--[FileName],
		[LANGUAGEID],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDBY],
		[NAME],
		[PARTITION],
		[PRODUCT],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		--stg.[FileName],
		stg.[LANGUAGEID],
		stg.[LastProcessedChange_DateTime],
		--stg.[LSN],
		stg.[MODIFIEDBY],
		stg.[NAME],
		stg.[PARTITION],
		stg.[PRODUCT],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.[SysRowId]	
	FROM [staging_fo].[ECORESPRODUCTTRANSLATION] stg
		LEFT JOIN [synapse_fo].[ECORESPRODUCTTRANSLATION] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

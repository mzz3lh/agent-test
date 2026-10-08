CREATE     PROCEDURE [synapse_fo].[usp_Update_ECORESPRODUCTTRANSLATION]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:40
	Description: Update stored procedure for ECORESPRODUCTTRANSLATION from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LANGUAGEID] = stg.[LANGUAGEID],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PRODUCT] = stg.[PRODUCT],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[ECORESPRODUCTTRANSLATION] tgt
		INNER JOIN [staging_fo].[ECORESPRODUCTTRANSLATION] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

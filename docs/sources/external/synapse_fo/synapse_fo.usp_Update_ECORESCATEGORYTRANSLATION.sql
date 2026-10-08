CREATE      PROCEDURE [synapse_fo].[usp_Update_ECORESCATEGORYTRANSLATION]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:39
	Description: Update stored procedure for ECORESCATEGORYTRANSLATION from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CATEGORY] = stg.[CATEGORY],
		tgt.[CREATEDBY] = stg.[CREATEDBY],
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		--tgt.[FileName] = stg.[FileName],
		tgt.[FRIENDLYNAME] = stg.[FRIENDLYNAME],
		tgt.[LANGUAGEID] = stg.[LANGUAGEID],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SEARCHTEXT] = stg.[SEARCHTEXT]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[ECORESCATEGORYTRANSLATION] tgt
		INNER JOIN [staging_fo].[ECORESCATEGORYTRANSLATION] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

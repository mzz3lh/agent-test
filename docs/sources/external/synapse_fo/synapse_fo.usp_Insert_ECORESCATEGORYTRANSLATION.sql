CREATE     PROCEDURE [synapse_fo].[usp_Insert_ECORESCATEGORYTRANSLATION]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:46
	Description: Insert stored procedure for ECORESCATEGORYTRANSLATION from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[ECORESCATEGORYTRANSLATION]
	(
		[CATEGORY],
		[CREATEDBY],
		[CREATEDDATETIME],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		--[FileName],
		[FRIENDLYNAME],
		[LANGUAGEID],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SEARCHTEXT]
		--[SysRowId]
	)
	SELECT 
		stg.[CATEGORY],
		stg.[CREATEDBY],
		stg.[CREATEDDATETIME],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		--stg.--[FileName],
		stg.[FRIENDLYNAME],
		stg.[LANGUAGEID],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SEARCHTEXT]
		--stg.--[SysRowId]	
	FROM [staging_fo].[ECORESCATEGORYTRANSLATION] stg
		LEFT JOIN [synapse_fo].[ECORESCATEGORYTRANSLATION] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

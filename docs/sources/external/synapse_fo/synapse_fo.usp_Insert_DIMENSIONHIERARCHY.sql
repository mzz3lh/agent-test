CREATE     PROCEDURE [synapse_fo].[usp_Insert_DIMENSIONHIERARCHY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:44
	Description: Insert stored procedure for DIMENSIONHIERARCHY from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[DIMENSIONHIERARCHY]
	(
		[CREATEDBY],
		[CREATEDDATETIME],
		[DataLakeModified_DateTime],
		[DELETEDVERSION],
		[DESCRIPTION],
		[DRAFTDESCRIPTION],
		[DRAFTNAME],
		--[FileName],
		[FOCUSISAUTOMATICUPDATESIM_IT],
		[FOCUSSTATE],
		[FOCUSSTATESIM_IT],
		[HASHKEY],
		[ISDRAFT],
		[ISSYSTEMGENERATED],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[NAME],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[STRUCTURETYPE]
		--[SysRowId]
	)
	SELECT 
		stg.[CREATEDBY],
		stg.[CREATEDDATETIME],
		stg.[DataLakeModified_DateTime],
		stg.[DELETEDVERSION],
		stg.[DESCRIPTION],
		stg.[DRAFTDESCRIPTION],
		stg.[DRAFTNAME],
		--stg.--[FileName],
		stg.[FOCUSISAUTOMATICUPDATESIM_IT],
		stg.[FOCUSSTATE],
		stg.[FOCUSSTATESIM_IT],
		stg.[HASHKEY],
		stg.[ISDRAFT],
		stg.[ISSYSTEMGENERATED],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[NAME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[STRUCTURETYPE]
		--stg.--[SysRowId]	
	FROM [staging_fo].[DIMENSIONHIERARCHY] stg
		LEFT JOIN [synapse_fo].[DIMENSIONHIERARCHY] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

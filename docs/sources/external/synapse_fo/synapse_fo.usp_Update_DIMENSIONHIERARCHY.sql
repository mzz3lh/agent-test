CREATE     PROCEDURE [synapse_fo].[usp_Update_DIMENSIONHIERARCHY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:36
	Description: Update stored procedure for DIMENSIONHIERARCHY from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CREATEDBY] = stg.[CREATEDBY],
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DELETEDVERSION] = stg.[DELETEDVERSION],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		tgt.[DRAFTDESCRIPTION] = stg.[DRAFTDESCRIPTION],
		tgt.[DRAFTNAME] = stg.[DRAFTNAME],
		--tgt.[FileName] = stg.[FileName],
		tgt.[FOCUSISAUTOMATICUPDATESIM_IT] = stg.[FOCUSISAUTOMATICUPDATESIM_IT],
		tgt.[FOCUSSTATE] = stg.[FOCUSSTATE],
		tgt.[FOCUSSTATESIM_IT] = stg.[FOCUSSTATESIM_IT],
		tgt.[HASHKEY] = stg.[HASHKEY],
		tgt.[ISDRAFT] = stg.[ISDRAFT],
		tgt.[ISSYSTEMGENERATED] = stg.[ISSYSTEMGENERATED],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[STRUCTURETYPE] = stg.[STRUCTURETYPE]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[DIMENSIONHIERARCHY] tgt
		INNER JOIN [staging_fo].[DIMENSIONHIERARCHY] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

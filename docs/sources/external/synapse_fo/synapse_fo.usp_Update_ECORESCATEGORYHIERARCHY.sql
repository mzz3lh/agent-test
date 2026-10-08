CREATE     PROCEDURE [synapse_fo].[usp_Update_ECORESCATEGORYHIERARCHY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:38
	Description: Update stored procedure for ECORESCATEGORYHIERARCHY from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CREATEDBY] = stg.[CREATEDBY],
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[HIERARCHYMODIFIER] = stg.[HIERARCHYMODIFIER],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[ECORESCATEGORYHIERARCHY] tgt
		INNER JOIN [staging_fo].[ECORESCATEGORYHIERARCHY] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

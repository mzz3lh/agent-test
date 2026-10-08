CREATE     PROCEDURE [synapse_fo].[usp_Insert_ECORESCATEGORYHIERARCHY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:46
	Description: Insert stored procedure for ECORESCATEGORYHIERARCHY from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[ECORESCATEGORYHIERARCHY]
	(
		[CREATEDBY],
		[CREATEDDATETIME],
		[DataLakeModified_DateTime],
		--[FileName],
		[HIERARCHYMODIFIER],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[NAME],
		[PARTITION],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[CREATEDBY],
		stg.[CREATEDDATETIME],
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[HIERARCHYMODIFIER],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[NAME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[ECORESCATEGORYHIERARCHY] stg
		LEFT JOIN [synapse_fo].[ECORESCATEGORYHIERARCHY] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

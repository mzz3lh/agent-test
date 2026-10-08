CREATE     PROCEDURE [synapse_fo].[usp_Insert_ECORESCATEGORYHIERARCHYROLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:46
	Description: Insert stored procedure for ECORESCATEGORYHIERARCHYROLE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[ECORESCATEGORYHIERARCHYROLE]
	(
		[CATEGORYHIERARCHY],
		[DataLakeModified_DateTime],
		--[FileName],
		[LastProcessedChange_DateTime],
		--[LSN],
		[NAMEDCATEGORYHIERARCHYROLE],
		[PARTITION],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[CATEGORYHIERARCHY],
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[NAMEDCATEGORYHIERARCHYROLE],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[ECORESCATEGORYHIERARCHYROLE] stg
		LEFT JOIN [synapse_fo].[ECORESCATEGORYHIERARCHYROLE] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

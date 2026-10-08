CREATE     PROCEDURE [synapse_fo].[usp_Insert_ECORESSTORAGEDIMENSIONGROUPITEM]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:48
	Description: Insert stored procedure for ECORESSTORAGEDIMENSIONGROUPITEM from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[ECORESSTORAGEDIMENSIONGROUPITEM]
	(
		[DataLakeModified_DateTime],
		--[FileName],
		[ITEMDATAAREAID],
		[ITEMID],
		[LastProcessedChange_DateTime],
		--[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[STORAGEDIMENSIONGROUP]
		--[SysRowId]
	)
	SELECT 
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[ITEMDATAAREAID],
		stg.[ITEMID],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[STORAGEDIMENSIONGROUP]
		--stg.--[SysRowId]	
	FROM [staging_fo].[ECORESSTORAGEDIMENSIONGROUPITEM] stg
		LEFT JOIN [synapse_fo].[ECORESSTORAGEDIMENSIONGROUPITEM] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

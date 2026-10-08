CREATE     PROCEDURE [synapse_fo].[usp_Insert_INVENTMODELGROUPITEM]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:51
	Description: Insert stored procedure for INVENTMODELGROUPITEM from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[INVENTMODELGROUPITEM]
	(
		[DataLakeModified_DateTime],
		--[FileName],
		[ITEMDATAAREAID],
		[ITEMID],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODELGROUPDATAAREAID],
		[MODELGROUPID],
		[PARTITION],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[ITEMDATAAREAID],
		stg.[ITEMID],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODELGROUPDATAAREAID],
		stg.[MODELGROUPID],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[INVENTMODELGROUPITEM] stg
		LEFT JOIN [synapse_fo].[INVENTMODELGROUPITEM] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

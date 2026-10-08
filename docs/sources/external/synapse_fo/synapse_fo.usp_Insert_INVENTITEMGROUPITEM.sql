CREATE     PROCEDURE [synapse_fo].[usp_Insert_INVENTITEMGROUPITEM]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:51
	Description: Insert stored procedure for INVENTITEMGROUPITEM from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[INVENTITEMGROUPITEM]
	(
		[DataLakeModified_DateTime],
		--[FileName],
		[ITEMDATAAREAID],
		[ITEMGROUPDATAAREAID],
		[ITEMGROUPID],
		[ITEMID],
		[LastProcessedChange_DateTime],
		--[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[ITEMDATAAREAID],
		stg.[ITEMGROUPDATAAREAID],
		stg.[ITEMGROUPID],
		stg.[ITEMID],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[INVENTITEMGROUPITEM] stg
		LEFT JOIN [synapse_fo].[INVENTITEMGROUPITEM] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

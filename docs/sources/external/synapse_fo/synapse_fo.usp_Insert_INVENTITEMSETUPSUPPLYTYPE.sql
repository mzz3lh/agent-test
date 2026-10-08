CREATE     PROCEDURE [synapse_fo].[usp_Insert_INVENTITEMSETUPSUPPLYTYPE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:51
	Description: Insert stored procedure for INVENTITEMSETUPSUPPLYTYPE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[INVENTITEMSETUPSUPPLYTYPE]
	(
		[DataLakeModified_DateTime],
		[DEFAULTORDERTYPE],
		--[FileName],
		[ITEMDATAAREAID],
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
		stg.[DEFAULTORDERTYPE],
		--stg.--[FileName],
		stg.[ITEMDATAAREAID],
		stg.[ITEMID],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[INVENTITEMSETUPSUPPLYTYPE] stg
		LEFT JOIN [synapse_fo].[INVENTITEMSETUPSUPPLYTYPE] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

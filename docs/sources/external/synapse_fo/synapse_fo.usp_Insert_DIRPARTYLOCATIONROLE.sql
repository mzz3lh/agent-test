CREATE     PROCEDURE [synapse_fo].[usp_Insert_DIRPARTYLOCATIONROLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:45
	Description: Insert stored procedure for DIRPARTYLOCATIONROLE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[DIRPARTYLOCATIONROLE]
	(
		[DataLakeModified_DateTime],
		--[FileName],
		[LastProcessedChange_DateTime],
		[LOCATIONROLE],
		--[LSN],
		[PARTITION],
		[PARTYLOCATION],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[LastProcessedChange_DateTime],
		stg.[LOCATIONROLE],
		--stg.--[LSN],
		stg.[PARTITION],
		stg.[PARTYLOCATION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[DIRPARTYLOCATIONROLE] stg
		LEFT JOIN [synapse_fo].[DIRPARTYLOCATIONROLE] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

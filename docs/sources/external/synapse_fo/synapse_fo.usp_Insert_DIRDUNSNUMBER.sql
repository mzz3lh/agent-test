CREATE     PROCEDURE [synapse_fo].[usp_Insert_DIRDUNSNUMBER]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:44
	Description: Insert stored procedure for DIRDUNSNUMBER from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[DIRDUNSNUMBER]
	(
		[DataLakeModified_DateTime],
		[DUNSNUMBER],
		--[FileName],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDBY],
		[PARTITION],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[DataLakeModified_DateTime],
		stg.[DUNSNUMBER],
		--stg.--[FileName],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[DIRDUNSNUMBER] stg
		LEFT JOIN [synapse_fo].[DIRDUNSNUMBER] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

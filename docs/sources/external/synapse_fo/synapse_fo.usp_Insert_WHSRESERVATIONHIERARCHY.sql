CREATE     PROCEDURE [synapse_fo].[usp_Insert_WHSRESERVATIONHIERARCHY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:04
	Description: Insert stored procedure for WHSRESERVATIONHIERARCHY from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[WHSRESERVATIONHIERARCHY]
	(
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		[FileName],
		[LastProcessedChange_DateTime],
		[LSN],
		[NAME],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SysRowId]
	)
	SELECT 
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		stg.[FileName],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[NAME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId]	
	FROM [staging_fo].[WHSRESERVATIONHIERARCHY] stg
		LEFT JOIN [synapse_fo].[WHSRESERVATIONHIERARCHY] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

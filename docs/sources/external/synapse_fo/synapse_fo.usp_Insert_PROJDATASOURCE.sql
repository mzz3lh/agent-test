CREATE     PROCEDURE [synapse_fo].[usp_Insert_PROJDATASOURCE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:56
	Description: Insert stored procedure for PROJDATASOURCE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[PROJDATASOURCE]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[FileName],
		[LastProcessedChange_DateTime],
		[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SOURCEID],
		[SysRowId]
	)
	SELECT 
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[FileName],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SOURCEID],
		stg.[SysRowId]	
	FROM [staging_fo].[PROJDATASOURCE] stg
		LEFT JOIN [synapse_fo].[PROJDATASOURCE] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

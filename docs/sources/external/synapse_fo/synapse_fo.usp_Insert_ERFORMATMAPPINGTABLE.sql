CREATE     PROCEDURE [synapse_fo].[usp_Insert_ERFORMATMAPPINGTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:48
	Description: Insert stored procedure for ERFORMATMAPPINGTABLE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[ERFORMATMAPPINGTABLE]
	(
		[BASE],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		--[FileName],
		[FORMAT],
		[GUID],
		[ISDEFAULT],
		[LastProcessedChange_DateTime],
		--[LSN],
		[NAME],
		[PARTITION],
		[PRIORBASE],
		[PUBLICOBJECTREFERENCES],
		[RECID],
		[RECVERSION],
		[SOLUTION]
		--[SysRowId]
	)
	SELECT 
		stg.[BASE],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		--stg.--[FileName],
		stg.[FORMAT],
		stg.[GUID],
		stg.[ISDEFAULT],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[NAME],
		stg.[PARTITION],
		stg.[PRIORBASE],
		stg.[PUBLICOBJECTREFERENCES],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SOLUTION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[ERFORMATMAPPINGTABLE] stg
		LEFT JOIN [synapse_fo].[ERFORMATMAPPINGTABLE] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

CREATE     PROCEDURE [synapse_fo].[usp_Insert_CONFIRMINGPO]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:40
	Description: Insert stored procedure for CONFIRMINGPO from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[CONFIRMINGPO]
	(
		[CONFIRMINGPOID],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		[FileName],
		[LANGUAGEID],
		[LastProcessedChange_DateTime],
		[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SysRowId]
	)
	SELECT 
		stg.[CONFIRMINGPOID],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		stg.[FileName],
		stg.[LANGUAGEID],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId]	
	FROM [staging_fo].[CONFIRMINGPO] stg
		LEFT JOIN [synapse_fo].[CONFIRMINGPO] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

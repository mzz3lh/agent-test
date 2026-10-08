CREATE     PROCEDURE [synapse_fo].[usp_Insert_PURCHLINE_INTRASTAT]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:57
	Description: Insert stored procedure for PURCHLINE_INTRASTAT from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[PURCHLINE_INTRASTAT]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[FileName],
		[LastProcessedChange_DateTime],
		[LSN],
		[PARTITION],
		[PURCHLINE],
		[RECID],
		[RECVERSION],
		[SPECIALMOVEMENT_CZ],
		[SysRowId]
	)
	SELECT 
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[FileName],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[PARTITION],
		stg.[PURCHLINE],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SPECIALMOVEMENT_CZ],
		stg.[SysRowId]	
	FROM [staging_fo].[PURCHLINE_INTRASTAT] stg
		LEFT JOIN [synapse_fo].[PURCHLINE_INTRASTAT] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

CREATE     PROCEDURE [synapse_fo].[usp_Insert_NGPCODESTABLE_FR]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:55
	Description: Insert stored procedure for NGPCODESTABLE_FR from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[NGPCODESTABLE_FR]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		[FileName],
		[LastProcessedChange_DateTime],
		[LSN],
		[NGPCODE],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SysRowId]
	)
	SELECT 
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		stg.[FileName],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[NGPCODE],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId]	
	FROM [staging_fo].[NGPCODESTABLE_FR] stg
		LEFT JOIN [synapse_fo].[NGPCODESTABLE_FR] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

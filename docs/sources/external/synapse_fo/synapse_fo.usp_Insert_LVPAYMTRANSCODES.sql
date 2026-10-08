CREATE     PROCEDURE [synapse_fo].[usp_Insert_LVPAYMTRANSCODES]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:54
	Description: Insert stored procedure for LVPAYMTRANSCODES from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[LVPAYMTRANSCODES]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		[FileName],
		[LastProcessedChange_DateTime],
		[LSN],
		[MODIFIEDBY],
		[PARTITION],
		[PAYMTRANSCODE],
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
		stg.[MODIFIEDBY],
		stg.[PARTITION],
		stg.[PAYMTRANSCODE],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId]	
	FROM [staging_fo].[LVPAYMTRANSCODES] stg
		LEFT JOIN [synapse_fo].[LVPAYMTRANSCODES] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

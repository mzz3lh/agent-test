CREATE     PROCEDURE [synapse_fo].[usp_Insert_VENDEXCEPTIONGROUP]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:02
	Description: Insert stored procedure for VENDEXCEPTIONGROUP from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[VENDEXCEPTIONGROUP]
	(
		[CREATEDBY],
		[CREATEDDATETIME],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[FileName],
		[LastProcessedChange_DateTime],
		[LSN],
		[NAME],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SysRowId],
		[VENDEXCEPTIONGROUP]
	)
	SELECT 
		stg.[CREATEDBY],
		stg.[CREATEDDATETIME],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[FileName],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[NAME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId],
		stg.[VENDEXCEPTIONGROUP]	
	FROM [staging_fo].[VENDEXCEPTIONGROUP] stg
		LEFT JOIN [synapse_fo].[VENDEXCEPTIONGROUP] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

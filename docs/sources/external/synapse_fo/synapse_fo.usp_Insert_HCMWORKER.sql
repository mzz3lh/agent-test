CREATE     PROCEDURE [synapse_fo].[usp_Insert_HCMWORKER]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:50
	Description: Insert stored procedure for HCMWORKER from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[HCMWORKER]
	(
		[CREATEDBY],
		[CREATEDDATETIME],
		[DataLakeModified_DateTime],
		--[FileName],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[PARTITION],
		[PERSON],
		[PERSONNELNUMBER],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[CREATEDBY],
		stg.[CREATEDDATETIME],
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[PARTITION],
		stg.[PERSON],
		stg.[PERSONNELNUMBER],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[HCMWORKER] stg
		LEFT JOIN [synapse_fo].[HCMWORKER] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

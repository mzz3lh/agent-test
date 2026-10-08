CREATE     PROCEDURE [synapse_fo].[usp_Insert_CUSTPAYMFORMAT]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:41
	Description: Insert stored procedure for CUSTPAYMFORMAT from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[CUSTPAYMFORMAT]
	(
		[BANKFORMAT],
		[CLASSID],
		[CLASSNAME],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[FileName],
		[FORMAT],
		[LastProcessedChange_DateTime],
		[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SysRowId]
	)
	SELECT 
		stg.[BANKFORMAT],
		stg.[CLASSID],
		stg.[CLASSNAME],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[FileName],
		stg.[FORMAT],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId]	
	FROM [staging_fo].[CUSTPAYMFORMAT] stg
		LEFT JOIN [synapse_fo].[CUSTPAYMFORMAT] tgt
			ON stg.[bankFormat] = tgt.[bankFormat] 
			AND stg.[classId] = tgt.[classId] 
			AND stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
	WHERE tgt.[RECID] IS NULL
END

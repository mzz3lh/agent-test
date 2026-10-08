CREATE     PROCEDURE [synapse_fo].[usp_Insert_LOGISTICSLOCATIONROLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:53
	Description: Insert stored procedure for LOGISTICSLOCATIONROLE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[LOGISTICSLOCATIONROLE]
	(
		[DataLakeModified_DateTime],
		[DISABLEADDOREDITINEMPLOYEESELFSERVICE],
		--[FileName],
		[ISCONTACTINFO],
		[ISPOSTALADDRESS],
		[LastProcessedChange_DateTime],
		--[LSN],
		[NAME],
		[PARTITION],
		[RECID],
		[RECVERSION],
		--[SysRowId],
		[TYPE]
	)
	SELECT 
		stg.[DataLakeModified_DateTime],
		stg.[DISABLEADDOREDITINEMPLOYEESELFSERVICE],
		--stg.--[FileName],
		stg.[ISCONTACTINFO],
		stg.[ISPOSTALADDRESS],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[NAME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		--stg.--[SysRowId],
		stg.[TYPE]	
	FROM [staging_fo].[LOGISTICSLOCATIONROLE] stg
		LEFT JOIN [synapse_fo].[LOGISTICSLOCATIONROLE] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

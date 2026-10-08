CREATE     PROCEDURE [synapse_fo].[usp_Insert_LOGISTICSLOCATION]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:53
	Description: Insert stored procedure for LOGISTICSLOCATION from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[LOGISTICSLOCATION]
	(
		[CREATEDDATETIME],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		[DUNSNUMBERRECID],
		--[FileName],
		[ISPOSTALADDRESS],
		[LastProcessedChange_DateTime],
		[LOCATIONID],
		--[LSN],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[PARENTLOCATION],
		[PARTITION],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[CREATEDDATETIME],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		stg.[DUNSNUMBERRECID],
		--stg.--[FileName],
		stg.[ISPOSTALADDRESS],
		stg.[LastProcessedChange_DateTime],
		stg.[LOCATIONID],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[PARENTLOCATION],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[LOGISTICSLOCATION] stg
		LEFT JOIN [synapse_fo].[LOGISTICSLOCATION] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

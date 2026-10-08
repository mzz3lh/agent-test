CREATE     PROCEDURE [synapse_fo].[usp_Insert_ECORESTRACKINGDIMENSIONGROUP]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:48
	Description: Insert stored procedure for ECORESTRACKINGDIMENSIONGROUP from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[ECORESTRACKINGDIMENSIONGROUP]
	(
		[CAPTURESERIAL],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		--[FileName],
		[ISSERIALATCONSUMPTIONENABLED],
		[ISSERIALNUMBERCONTROLENABLED],
		[LastProcessedChange_DateTime],
		--[LSN],
		[NAME],
		[PARTITION],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[CAPTURESERIAL],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		--stg.--[FileName],
		stg.[ISSERIALATCONSUMPTIONENABLED],
		stg.[ISSERIALNUMBERCONTROLENABLED],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[NAME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[ECORESTRACKINGDIMENSIONGROUP] stg
		LEFT JOIN [synapse_fo].[ECORESTRACKINGDIMENSIONGROUP] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

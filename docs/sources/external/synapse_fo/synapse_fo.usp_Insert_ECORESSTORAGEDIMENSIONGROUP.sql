CREATE     PROCEDURE [synapse_fo].[usp_Insert_ECORESSTORAGEDIMENSIONGROUP]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:47
	Description: Insert stored procedure for ECORESSTORAGEDIMENSIONGROUP from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[ECORESSTORAGEDIMENSIONGROUP]
	(
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		--[FileName],
		[ISWAREHOUSEMANDATORYENABLED],
		[ISWAREHOUSEPRIMARYSTOCKINGENABLED],
		[ISWAREHOUSEWHSENABLED],
		[LastProcessedChange_DateTime],
		--[LSN],
		[NAME],
		[PARTITION],
		[RECID],
		[RECVERSION]
		--[SysRowId]
	)
	SELECT 
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		--stg.--[FileName],
		stg.[ISWAREHOUSEMANDATORYENABLED],
		stg.[ISWAREHOUSEPRIMARYSTOCKINGENABLED],
		stg.[ISWAREHOUSEWHSENABLED],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[NAME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[ECORESSTORAGEDIMENSIONGROUP] stg
		LEFT JOIN [synapse_fo].[ECORESSTORAGEDIMENSIONGROUP] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

CREATE     PROCEDURE [synapse_fo].[usp_Insert_ECORESPRODUCTDIMENSIONGROUP]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:47
	Description: Insert stored procedure for ECORESPRODUCTDIMENSIONGROUP from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[ECORESPRODUCTDIMENSIONGROUP]
	(
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		--[FileName],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDBY],
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
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[NAME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION]
		--stg.--[SysRowId]	
	FROM [staging_fo].[ECORESPRODUCTDIMENSIONGROUP] stg
		LEFT JOIN [synapse_fo].[ECORESPRODUCTDIMENSIONGROUP] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

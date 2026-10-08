CREATE     PROCEDURE [synapse_fo].[usp_Insert_TMSINVENTENABLED]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:01
	Description: Insert stored procedure for TMSINVENTENABLED from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[TMSINVENTENABLED]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[FileName],
		[ITEMID],
		[LastProcessedChange_DateTime],
		[LSN],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SysRowId]
	)
	SELECT 
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[FileName],
		stg.[ITEMID],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId]	
	FROM [staging_fo].[TMSINVENTENABLED] stg
		LEFT JOIN [synapse_fo].[TMSINVENTENABLED] tgt
			ON stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[ItemId] = tgt.[ItemId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
	WHERE tgt.[RECID] IS NULL
END

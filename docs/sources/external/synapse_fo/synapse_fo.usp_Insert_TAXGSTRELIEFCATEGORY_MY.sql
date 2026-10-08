CREATE     PROCEDURE [synapse_fo].[usp_Insert_TAXGSTRELIEFCATEGORY_MY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:00
	Description: Insert stored procedure for TAXGSTRELIEFCATEGORY_MY from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[TAXGSTRELIEFCATEGORY_MY]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[FileName],
		[LastProcessedChange_DateTime],
		[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[RELIEFCATEGORYENTITYKEY],
		[RELIEFCATEGORYID],
		[RELIEFITEMNUMBER],
		[RELIEFSCHEDULE],
		[SysRowId]
	)
	SELECT 
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[FileName],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[RELIEFCATEGORYENTITYKEY],
		stg.[RELIEFCATEGORYID],
		stg.[RELIEFITEMNUMBER],
		stg.[RELIEFSCHEDULE],
		stg.[SysRowId]	
	FROM [staging_fo].[TAXGSTRELIEFCATEGORY_MY] stg
		LEFT JOIN [synapse_fo].[TAXGSTRELIEFCATEGORY_MY] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

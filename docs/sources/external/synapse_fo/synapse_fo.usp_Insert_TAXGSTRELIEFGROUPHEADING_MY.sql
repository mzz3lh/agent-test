CREATE     PROCEDURE [synapse_fo].[usp_Insert_TAXGSTRELIEFGROUPHEADING_MY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:00
	Description: Insert stored procedure for TAXGSTRELIEFGROUPHEADING_MY from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[TAXGSTRELIEFGROUPHEADING_MY]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[DESCRIPTION],
		[FileName],
		[LastProcessedChange_DateTime],
		[LSN],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[RELIEFGROUPID],
		[SysRowId]
	)
	SELECT 
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[DESCRIPTION],
		stg.[FileName],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[RELIEFGROUPID],
		stg.[SysRowId]	
	FROM [staging_fo].[TAXGSTRELIEFGROUPHEADING_MY] stg
		LEFT JOIN [synapse_fo].[TAXGSTRELIEFGROUPHEADING_MY] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

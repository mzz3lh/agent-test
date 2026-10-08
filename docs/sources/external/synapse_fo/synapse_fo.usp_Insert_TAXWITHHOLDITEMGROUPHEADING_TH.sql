CREATE     PROCEDURE [synapse_fo].[usp_Insert_TAXWITHHOLDITEMGROUPHEADING_TH]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:01
	Description: Insert stored procedure for TAXWITHHOLDITEMGROUPHEADING_TH from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[TAXWITHHOLDITEMGROUPHEADING_TH]
	(
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[FileName],
		[LastProcessedChange_DateTime],
		[LSN],
		[NAME],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[SysRowId],
		[TAXWITHHOLDITEMGROUP],
		[TAXWITHHOLDREVENUETABLE_TH]
	)
	SELECT 
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[FileName],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[NAME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[SysRowId],
		stg.[TAXWITHHOLDITEMGROUP],
		stg.[TAXWITHHOLDREVENUETABLE_TH]	
	FROM [staging_fo].[TAXWITHHOLDITEMGROUPHEADING_TH] stg
		LEFT JOIN [synapse_fo].[TAXWITHHOLDITEMGROUPHEADING_TH] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END

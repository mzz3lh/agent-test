CREATE     PROCEDURE [synapse_fo].[usp_Update_TAXGSTRELIEFGROUPHEADING_MY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:52
	Description: Update stored procedure for TAXGSTRELIEFGROUPHEADING_MY from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[RELIEFGROUPID] = stg.[RELIEFGROUPID],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[TAXGSTRELIEFGROUPHEADING_MY] tgt
		INNER JOIN [staging_fo].[TAXGSTRELIEFGROUPHEADING_MY] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

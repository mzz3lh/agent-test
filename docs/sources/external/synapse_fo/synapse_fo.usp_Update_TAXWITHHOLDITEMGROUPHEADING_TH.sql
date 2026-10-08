CREATE     PROCEDURE [synapse_fo].[usp_Update_TAXWITHHOLDITEMGROUPHEADING_TH]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:53
	Description: Update stored procedure for TAXWITHHOLDITEMGROUPHEADING_TH from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TAXWITHHOLDITEMGROUP] = stg.[TAXWITHHOLDITEMGROUP],
		tgt.[TAXWITHHOLDREVENUETABLE_TH] = stg.[TAXWITHHOLDREVENUETABLE_TH]
	 FROM [synapse_fo].[TAXWITHHOLDITEMGROUPHEADING_TH] tgt
		INNER JOIN [staging_fo].[TAXWITHHOLDITEMGROUPHEADING_TH] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

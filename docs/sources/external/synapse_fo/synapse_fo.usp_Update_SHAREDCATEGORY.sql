CREATE     PROCEDURE [synapse_fo].[usp_Update_SHAREDCATEGORY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:51
	Description: Update stored procedure for SHAREDCATEGORY from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CATEGORYID] = stg.[CATEGORYID],
		tgt.[CATEGORYNAME] = stg.[CATEGORYNAME],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[SHAREDCATEGORY] tgt
		INNER JOIN [staging_fo].[SHAREDCATEGORY] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

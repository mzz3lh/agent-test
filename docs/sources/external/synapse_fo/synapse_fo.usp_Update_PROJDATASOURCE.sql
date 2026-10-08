CREATE     PROCEDURE [synapse_fo].[usp_Update_PROJDATASOURCE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:48
	Description: Update stored procedure for PROJDATASOURCE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SOURCEID] = stg.[SOURCEID],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[PROJDATASOURCE] tgt
		INNER JOIN [staging_fo].[PROJDATASOURCE] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

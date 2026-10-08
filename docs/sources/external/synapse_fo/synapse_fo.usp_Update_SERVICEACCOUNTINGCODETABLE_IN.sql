CREATE     PROCEDURE [synapse_fo].[usp_Update_SERVICEACCOUNTINGCODETABLE_IN]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:51
	Description: Update stored procedure for SERVICEACCOUNTINGCODETABLE_IN from synapse finops datalake to BI
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
		tgt.[SAC] = stg.[SAC],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[SERVICEACCOUNTINGCODETABLE_IN] tgt
		INNER JOIN [staging_fo].[SERVICEACCOUNTINGCODETABLE_IN] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

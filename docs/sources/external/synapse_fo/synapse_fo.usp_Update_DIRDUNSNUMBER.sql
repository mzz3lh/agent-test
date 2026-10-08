CREATE     PROCEDURE [synapse_fo].[usp_Update_DIRDUNSNUMBER]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:37
	Description: Update stored procedure for DIRDUNSNUMBER from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DUNSNUMBER] = stg.[DUNSNUMBER],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[DIRDUNSNUMBER] tgt
		INNER JOIN [staging_fo].[DIRDUNSNUMBER] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

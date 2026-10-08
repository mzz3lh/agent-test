CREATE     PROCEDURE [synapse_fo].[usp_Update_CUSTDEFAULTLOCATION]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:33
	Description: Update stored procedure for CUSTDEFAULTLOCATION from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[ACCOUNTNUM] = stg.[ACCOUNTNUM],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PARTYLOCATIONROLE] = stg.[PARTYLOCATIONROLE],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[CUSTDEFAULTLOCATION] tgt
		INNER JOIN [staging_fo].[CUSTDEFAULTLOCATION] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

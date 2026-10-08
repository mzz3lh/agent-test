CREATE     PROCEDURE [synapse_fo].[usp_Update_DIRPARTYLOCATIONROLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:38
	Description: Update stored procedure for DIRPARTYLOCATIONROLE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LOCATIONROLE] = stg.[LOCATIONROLE],
		--tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PARTYLOCATION] = stg.[PARTYLOCATION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[DIRPARTYLOCATIONROLE] tgt
		INNER JOIN [staging_fo].[DIRPARTYLOCATIONROLE] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

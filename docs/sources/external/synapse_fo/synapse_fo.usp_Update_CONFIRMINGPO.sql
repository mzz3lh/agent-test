CREATE     PROCEDURE [synapse_fo].[usp_Update_CONFIRMINGPO]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:33
	Description: Update stored procedure for CONFIRMINGPO from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CONFIRMINGPOID] = stg.[CONFIRMINGPOID],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		tgt.[FileName] = stg.[FileName],
		tgt.[LANGUAGEID] = stg.[LANGUAGEID],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[CONFIRMINGPO] tgt
		INNER JOIN [staging_fo].[CONFIRMINGPO] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

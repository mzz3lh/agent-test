CREATE     PROCEDURE [synapse_fo].[usp_Update_REASONTABLEREF]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:50
	Description: Update stored procedure for REASONTABLEREF from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[REASON] = stg.[REASON],
		tgt.[REASONCOMMENT] = stg.[REASONCOMMENT],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[REASONTABLEREF] tgt
		INNER JOIN [staging_fo].[REASONTABLEREF] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

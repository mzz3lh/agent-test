CREATE     PROCEDURE [synapse_fo].[usp_Update_INVENTCOUNTINGREASONCODEPOLICY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:42
	Description: Update stored procedure for INVENTCOUNTINGREASONCODEPOLICY from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[FileName] = stg.[FileName],
		tgt.[INVENTCOUNTINGREASONCODETYPE] = stg.[INVENTCOUNTINGREASONCODETYPE],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[INVENTCOUNTINGREASONCODEPOLICY] tgt
		INNER JOIN [staging_fo].[INVENTCOUNTINGREASONCODEPOLICY] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

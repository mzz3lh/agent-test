CREATE     PROCEDURE [synapse_fo].[usp_Update_ERFORMATMAPPINGTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:40
	Description: Update stored procedure for ERFORMATMAPPINGTABLE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[BASE] = stg.[BASE],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		--tgt.[FileName] = stg.[FileName],
		tgt.[FORMAT] = stg.[FORMAT],
		tgt.[GUID] = stg.[GUID],
		tgt.[ISDEFAULT] = stg.[ISDEFAULT],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PRIORBASE] = stg.[PRIORBASE],
		tgt.[PUBLICOBJECTREFERENCES] = stg.[PUBLICOBJECTREFERENCES],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SOLUTION] = stg.[SOLUTION]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[ERFORMATMAPPINGTABLE] tgt
		INNER JOIN [staging_fo].[ERFORMATMAPPINGTABLE] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

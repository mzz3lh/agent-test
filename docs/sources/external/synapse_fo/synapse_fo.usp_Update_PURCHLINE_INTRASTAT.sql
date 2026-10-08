CREATE     PROCEDURE [synapse_fo].[usp_Update_PURCHLINE_INTRASTAT]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:49
	Description: Update stored procedure for PURCHLINE_INTRASTAT from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PURCHLINE] = stg.[PURCHLINE],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SPECIALMOVEMENT_CZ] = stg.[SPECIALMOVEMENT_CZ],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[PURCHLINE_INTRASTAT] tgt
		INNER JOIN [staging_fo].[PURCHLINE_INTRASTAT] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

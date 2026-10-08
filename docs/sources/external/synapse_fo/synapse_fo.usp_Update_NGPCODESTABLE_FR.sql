CREATE     PROCEDURE [synapse_fo].[usp_Update_NGPCODESTABLE_FR]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:47
	Description: Update stored procedure for NGPCODESTABLE_FR from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[NGPCODE] = stg.[NGPCODE],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[NGPCODESTABLE_FR] tgt
		INNER JOIN [staging_fo].[NGPCODESTABLE_FR] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END

CREATE     PROCEDURE [synapse_fo].[usp_Update_LVPAYMTRANSCODES]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:46
	Description: Update stored procedure for LVPAYMTRANSCODES from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DESCRIPTION] = stg.[DESCRIPTION],
		tgt.[FileName] = stg.[FileName],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PAYMTRANSCODE] = stg.[PAYMTRANSCODE],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[LVPAYMTRANSCODES] tgt
		INNER JOIN [staging_fo].[LVPAYMTRANSCODES] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
